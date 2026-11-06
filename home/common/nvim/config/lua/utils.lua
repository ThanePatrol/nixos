local M = {}

function M.is_cloudtop() return os.getenv("CORP_WORK_ENV") == "true" end

-- TODO: In markdown files have a util function to preview currently selected mermaid blocks in visual mode
-- by:
-- 1. Generate a svg somewhere in /tmp
-- 2. Serve the svg in a web server Something like python3 -m http.server <path-to-svg>
-- Also have another binding to save it as a png.
-- Also include mmdc in nvvim required packages + python3 so guaranteed to work.
--
--
-- TODO: Make generic function for this as it's used in a few places
function M.get_text_in_visual_mode() end

function M.preview_svg() end
function M.preview_svg() end

return M
