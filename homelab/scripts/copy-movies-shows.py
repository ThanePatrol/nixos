import json
import os
from typing import Any

from dataclasses import dataclass
from types import SimpleNamespace
import requests
import sys
import shutil
import hashlib
from pathlib import Path
import re


@dataclass
class Mapping:
    old_name: str
    new_name: str


@dataclass
class State:
    mappings: list[Mapping]


state_dir = os.environ.get("STATE_DIRECTORY")
if not state_dir or state_dir == "":
    sys.exit(1)
state_file = Path(state_dir)
state_file = state_file.joinpath("state.json")

if not state_file.exists():
    state_file.touch()

global_state = json.loads(state_file.read_bytes(), object_hook=SimpleNamespace)

torrent_dir = Path("/var/lib/qBittorrent/qBittorrent/downloads/")
jellyfin_movie_dir = Path("/var/lib/jellyfin/Movies")
jellyfin_show_dir = Path("/var/lib/jellyfin/Shows")
filetype_pattern = re.compile(r".*\.(mp4|mkv|srt)$")
ignore_tmp_parts = re.compile("(temp|.*parts)")


def populate_jellyfin_state(state: State):
    populate_state_from_dir(jellyfin_movie_dir, state)
    populate_state_from_dir(jellyfin_show_dir, state)


def populate_state_from_dir(dir: Path, state: State):
    for maybe_duplicate in dir.rglob("*"):
        if not maybe_duplicate.is_file():
            continue
        found_old = False
        for mapping in state.mappings:
            if mapping.new_name == str(maybe_duplicate.resolve()):
                found_old = True
                break
        if not found_old:
            state.mappings.append(
                Mapping(new_name=str(maybe_duplicate.resolve()), old_name="")
            )


def get_file_hash(filepath: Path, algorithm="sha256", chunk_size=65536):
    h = hashlib.new(algorithm)
    with open(filepath, "rb") as f:
        while chunk := f.read(chunk_size):
            h.update(chunk)
    return h.hexdigest()


def is_in_jellyfin(file: Path, state: State) -> bool:
    for s in state.mappings:
        if file.resolve() == Path(s.new_name).resolve():
            return True
    return False


def move_file(dst_path: Path, src_path: Path):
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    src_path.rename(dst_path)


def make_llm_call(prompt: dict) -> list[Any]:
    response = requests.post("http://localhost:9000/v1/chat/completions", json=prompt)
    body = response.json()
    if (
        response.status_code != 200
        or not body
        or not body["choices"]
        or len(body["choices"]) != 1
        or not body["choices"][0]["message"]
        or not body["choices"][0]["message"]["content"]
    ):
        print(
            f"llm call failed with response code: {response.status_code} or body was None or malformed."
        )
        if response.status_code == 200:
            print(f"Bad body with 200 response code: {body}")
            return []

    content = body["choices"][0]["message"]["content"]

    if "```" in content:
        content = content.replace("```json", "")
        content = content.replace("```", "")

    # TODO: Implement retries.
    if (out := json.loads(content)) is not None:
        print(f"body: {out}")
        return out["body"]
    print(f"failed to deserialize json: {content}")

    return []


def chown_recursive(path: Path, user: str, group: str):
    # Change ownership of the top-level directory first
    shutil.chown(path.resolve(), user=user, group=group)

    # Walk through all subdirectories and files
    for root, dirs, files in os.walk(path):
        for d in dirs:
            shutil.chown(os.path.join(root, d), user=user, group=group)
        for f in files:
            shutil.chown(os.path.join(root, f), user=user, group=group)


# TODO: some check to see if it's already present in the jellyfin lib.
# TODO: Ensure we transfer srt files as well as any media files associated with it.
jellyfin_hashes = populate_jellyfin_state(state=global_state)
new_mappings = []
for file_path in torrent_dir.glob("*"):
    if ignore_tmp_parts.match(file_path.name):
        print("skipping temp directory")
        continue

    # If we have a directory, add all the filenames within there.
    # This helps confusion in the case of the top level folder being
    # named without Season/Episode.
    llm_provided_msg = file_path.name

    found_one_not_copied = False
    if file_path.is_file() and is_in_jellyfin(file_path, global_state):
        print(f"skipping {file_path} as already in jellyfin")
        continue
    elif file_path.is_file():
        new_mappings.append(Mapping(old_name=str(file_path.resolve()), new_name=""))
        found_one_not_copied = True

    if file_path.is_dir():
        # TODO: need to record all as old_name
        llm_provided_msg = llm_provided_msg + ",,,".join(
            filter(
                lambda y: filetype_pattern.match(y),
                map(lambda x: str(x.name), file_path.rglob("*")),
            )
        )

        for f in file_path.rglob("*"):
            if f.is_file() and is_in_jellyfin(f, state=global_state):
                print(f"skipping {file_path} as already in jellyfin")
                continue
            elif f.is_file():
                new_mappings.append(
                    Mapping(old_name=str(file_path.resolve()), new_name="")
                )
                found_one_not_copied = True

    if not found_one_not_copied:
        continue
    print(f"skipping copying, would have asked about: {llm_provided_msg}")
    # TODO: Finish setup
    continue

    categorize_prompt = {
        "messages": [
            {
                "role": "system",
                "content": 'You are a specialized media management assistant. Identify whether the provided file is a Movie or a TV show. Output ONLY {"body": ["movie"] } or {"body": ["show"] } No explanations or chatter.',
            },
            {"role": "user", "content": f"{llm_provided_msg}"},
        ],
        "temperature": 0,
        "max_tokens": 64,
    }
    print(f"checking {llm_provided_msg}")
    body = make_llm_call(categorize_prompt)
    if len(body) != 1:
        print(f"body not of expected length 1: {body}")
        continue

    is_show = body[0] == "show"

    rename_show_prompt = {
        "messages": [
            {
                "role": "system",
                "content": 'You are a specialized media management assistant. You are given an input of .mkv or .mp4 or .srt files, separated by a ,,, Output the file names in the format "Series Name A (year)/Season 01/SeriesNameA S01E01.<file-extension>" Note srt files should share the same name as the episode they come from. Output ONLY {"body": [{"old": "old_name", "Series Name A (year)/Season 01/SeriesNameA S01E01.<file-extension>"}, {<other-elements>...}] } No explanations or chatter, only valid json.',
            },
            {"role": "user", "content": f"{llm_provided_msg}"},
        ],
        "temperature": 0,
        "max_tokens": 4096,
    }
    rename_movie_prompt = {
        "messages": [
            {
                "role": "system",
                "content": 'You are a specialized media management assistant. You are given an input of .mkv or .mp4 or .srt movie files, potentially separated by a ,,, Output the file names in the format "Movie Name (year)/Movie Name (year).<file-extension>" Note srt files should share the same name as the Movie they come from. Output ONLY {"body": [{"old": "old_name", "new": "Movie Name (year)/Movie Name (year).<file-extension>"}, {<other-elements>...}] } No explanations or chatter, only valid json.',
            },
            {"role": "user", "content": f"{llm_provided_msg}"},
        ],
        "temperature": 0,
        "max_tokens": 4096,
    }

    paths = []

    if is_show:
        renamed_paths = make_llm_call(rename_show_prompt)
        paths = map(
            lambda p: (
                jellyfin_show_dir.joinpath(p["new"]),
                torrent_dir.joinpath(p["old"]),
            ),
            renamed_paths,
        )
    else:
        renamed_paths = make_llm_call(rename_movie_prompt)
        paths = map(
            lambda p: (
                jellyfin_movie_dir.joinpath(p["new"]),
                torrent_dir.joinpath(p["old"]),
            ),
            renamed_paths,
        )

    print(f"got movement: {paths}")
    continue
    for p in paths:
        move_file(p[0], p[1])

    chown_recursive(jellyfin_show_dir, "jellyfin", "jellyfin")
    chown_recursive(jellyfin_movie_dir, "jellyfin", "jellyfin")

    print()

out = json.dumps(global_state, indent=4)
state_file.write_text(out)
