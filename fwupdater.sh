#!/bin/bash
# Joey Jr Firmware Updater for FlashGBX
# by Lesserkuma

echo -e "\nJoey Jr Firmware Updater for FlashGBX\nby Lesserkuma\n"

if [[ $EUID -ne 0 ]]; then
   echo -e "Warning: This script must be run with root privileges in order to access the raw sectors of your Joey Jr device.\n"
else
   echo -e "Note: Please only use this tool with a real Joey Jr.\nDo not connect any other BennVenn devices including the older Joey Gen 3.\n\nPress ENTER to continue."
   read
fi

FIRMWARE_FILE="FIRMWARE.JR"
if [[ ! -f $FIRMWARE_FILE ]]; then
    echo "Error: Firmware file $FIRMWARE_FILE not found in same directory.\n"
    exit 1
fi

device_found=false
for device in /dev/rdisk*; do
    if [[ $device =~ ^/dev/rdisk[0-9]+$ ]]; then
        if dd if="$device" bs=512 count=1 2>/dev/null | grep -q "BENNVENN"; then
            device_found=true
            echo "A Joey Jr device was found at $device!"

            echo "Setting UPDATE mode..."
            printf "UPDATE\0%.0s" {1..250} | dd of="$device" bs=512 seek=$((0x2094A00 / 512)) conv=notrunc 2>/dev/null

            sleep 3

            for (( attempt=1; attempt<=10; attempt++ )); do
                if [[ -e "$device" ]]; then
                    break
                fi
                echo "Waiting for your Joey Jr to reconnect... ($attempt)"
                sleep 1
            done

            if [[ ! -e "$device" ]]; then
                echo "The firmware update timed out. Please try again."
                continue
            fi

            echo "Now writing firmware update to your Joey Jr..."
            dd if="$FIRMWARE_FILE" of="$device" bs=512 seek=$((0x2074A00 / 512)) conv=notrunc

            sleep 3

            if [[ -e "$device" ]]; then
                echo "The firmware update timed out. Please try again."
                continue
            fi

            echo -e "\nFirmware update successfully written to $device!\n"
        fi
    fi
done

# Check if no devices were found
if [[ $device_found == false ]]; then
    echo -e "No Joey Jr devices running the Drag'n'Drop firmware were found.\n"
fi
