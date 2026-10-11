#!/usr/bin/env bash

PLIST=$(find ~/Library/LaunchAgents -maxdepth 1 -iname '*nanoclaw*.plist' | head -n 1)
LABEL=$(plutil -extract Label raw "$PLIST")

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true

launchctl list | grep "$LABEL"