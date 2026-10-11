#!/usr/bin/env bash

PLIST=$(find ~/Library/LaunchAgents -maxdepth 1 -iname '*nanoclaw*.plist' | head -n 1)
LABEL=$(plutil -extract Label raw "$PLIST")

launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl kickstart -k "gui/$(id -u)/$LABEL"

launchctl list | grep "$LABEL"