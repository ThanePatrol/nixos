#!/usr/bin/env bash
#
#
#
function get_active_workspace() {
	echo $(hyprctl activeworkspace -j | jq '.id')
}

function get_workspaces(){
	workspace_config_string=$(cat << EOM 
	(box    :class "workspace"
	        :orientation "h"
	        :spacing "5"  
EOM
)
	workspaces=$(hyprctl workspaces -j | jq -r '.[].id' | sort)
	workspace_array=($workspaces)
	active_workspace="$(get_active_workspace)"
	for workspace in "${workspace_array[@]}"; do
		workspace_config_string+="(button :onclick \"hyprctl dispatch workspace $workspace\""$'\n'
		if [ "$workspace" = "$active_workspace" ]; then
			workspace_config_string+=":class \"workspace-button-active\")"$'\n'
		else
			workspace_config_string+=":class \"workspace-button-inactive\")"$'\n'
		fi
	done	
	workspace_config_string+=")"$'\n'
	echo $workspace_config_string
}


get_workspaces
