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
# TODO - add numbers to workspace!
	workspaces=$(hyprctl workspaces -j | jq -r '.[].id' | sort)
	workspace_array=($workspaces)
	active_workspace="$(get_active_workspace)"
	for workspace in "${workspace_array[@]}"; do
		workspace_config_string+="(button :onclick \"hyprctl dispatch workspace $workspace\""$'\n'
		if [ "$workspace" = "$active_workspace" ]; then
			workspace_config_string+=":class \" workspace workspace-button-active\" "$'\n'
		else
			workspace_config_string+=":class \" workspace workspace-button-inactive\" "$'\n'
		fi
		workspace_config_string+=" $workspace )"$'\n'
	done	
	workspace_config_string+=")"$'\n'
	echo $workspace_config_string
}


get_workspaces
