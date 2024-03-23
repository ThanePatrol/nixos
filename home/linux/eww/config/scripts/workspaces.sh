#!/usr/bin/env bash
#
#
#
function get_active_workspace_id() {
	echo $(hyprctl activewindow -j | jq '.workspace.id')
}

function get_workspaces(){
	workspace_config_string=$(cat << EOM 
	(box    :class "workspace"
	        :orientation "horizontal"
			:spacing "5"
			:space-evenly "false"
EOM
)
	workspaces=$(hyprctl workspaces -j | jq -r '.[].id' | sort)
	workspace_array=($workspaces)
	active_workspace="$(get_active_workspace_id)"
	for workspace in "${workspace_array[@]}"; do
		workspace_config_string+="(button :halign \"center\" :onclick \"hyprctl dispatch workspace $workspace\""$'\n'
		if [ "$workspace" = "$active_workspace" ]; then
			workspace_config_string+=":class \" workspace workspace-button-active\" "$'\n'
		else
			workspace_config_string+=":class \" workspace workspace-button-inactive\" "$'\n'
		fi
		workspace_config_string+=" \"$workspace\" )"$'\n'
	done	
	workspace_config_string+=")"$'\n'
	
	echo $workspace_config_string
}

function get_active_window() {
	echo $(hyprctl activewindow -j | jq '.title' | sed 's/"//g')
}

function get_workspaces_as_json() {
	active_workspace=$(get_active_workspace_id)
	echo $active_workspace

	echo $(hyprctl workspaces -j | jq --arg active_ws "$active_workspace" 'map({id, active: (.id == ($active_ws | tonumber ))})' )
}

argument=$1

if [ "$argument" = "get-workspaces" ]; then 
	get_workspaces
	socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do 
		get_workspaces
	done
elif [ "$argument" = "get-active-window" ]; then
	get_active_window
elif [ "$argument" = "get-workspaces-as-json" ]; then
	get_workspaces_as_json
fi



