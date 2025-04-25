#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title TweetToCosense
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🗒️
# @raycast.argument1 { "type": "text", "placeholder": "Take memos" }

cosense_project_name="<your-project-name"
current_date=$(date +"%Y%m%d")
current_time=$(date +"%H:%M:%S")
memo=$(echo "$1" | sed 's/ /%20/g' )

open https://scrapbox.io/$cosense_project_name/$current_date?body=$current_time:$memo

