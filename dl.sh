#!/bin/bash

echo "Downloading the firmware updater..."
curl -sSL https://github.com/lesserkuma/JoeyJr_FWUpdater/archive/refs/heads/main.zip -o /tmp/JoeyJr_FWUpdater.zip

echo "Extracting files..."
mkdir -p /tmp/JoeyJr_FWUpdater
unzip -qqjo /tmp/JoeyJr_FWUpdater.zip -d /tmp/JoeyJr_FWUpdater

echo "Running the firmware updater..."
chmod +x /tmp/JoeyJr_FWUpdater/fwupdater.sh
sudo /tmp/JoeyJr_FWUpdater/fwupdater.sh
