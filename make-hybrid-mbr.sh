#!/bin/bash

#
# Creates MBR based on first FAT32 partiton on an APM disk.
#
diskutil list
echo "Enter disk number to create hybrid APM-MBR on (may be destructive):"
read -r diskNumber

#
# Unmount all volumes.
#
echo "Unmounting disk$diskNumber..."
sudo diskutil unmountDisk force disk"${diskNumber}"

#
# Find the first FAT32 partition entry.
#
partEntry=$(sudo pdisk "/dev/rdisk$diskNumber" -dump | awk '$2=="DOS_FAT_32" {print; exit}')
if [ -z "$partEntry" ]; then
    echo "No FAT32 partition found."
    exit 1
fi

#
# Get partition info.
#
partNumber=$(echo "$partEntry" | awk '{print $1}' | sed 's/://')
partSize=$(echo "$partEntry" | awk '{print $4}')
partOffset=$(echo "$partEntry" | awk '{print $6}')
echo "FAT32 on part $partNumber at block $partOffset size $partSize"

#
# Read first sector from disk.
#
sudo dd if=/dev/disk"${diskNumber}" of=disksector.bin bs=1 count=512 conv=notrunc

#
# Create MBR partition record.
#
echo "Writing FAT32 MBR partition..."

printf '\x00\xFE\xFF\xFF\x0B\xFE\xFF\xFF' | sudo dd of=disksector.bin bs=1 seek=446 conv=notrunc
b0=$((partOffset & 0xFF))
b1=$(((partOffset >> 8) & 0xFF))
b2=$(((partOffset >> 16) & 0xFF))
b3=$(((partOffset >> 24) & 0xFF))
printf "$(printf '\\x%02x\\x%02x\\x%02x\\x%02x' "$b0" "$b1" "$b2" "$b3")" \
  | sudo dd of=disksector.bin bs=1 seek=454 conv=notrunc

b0=$((partOfpartSizefset & 0xFF))
b1=$(((partSize >> 8) & 0xFF))
b2=$(((partSize >> 16) & 0xFF))
b3=$(((partSize >> 24) & 0xFF))
printf "$(printf '\\x%02x\\x%02x\\x%02x\\x%02x' "$b0" "$b1" "$b2" "$b3")" \
  | sudo dd of=disksector.bin bs=1 seek=458 conv=notrunc

printf '\x00\x00\x00\x00\x00\x00\x00\x00' | sudo dd of=disksector.bin bs=1 seek=462 conv=notrunc

#
# Set MBR signature.
#
echo "Writing MBR signature..."
printf '\x55\xAA' | sudo dd of=disksector.bin bs=1 seek=510 conv=notrunc

#
# Write first sector back to disk.
#
sudo dd if=disksector.bin of=/dev/disk"${diskNumber}" bs=1 conv=notrunc
sudo rm -f disksector.bin

#
# Remount all volumes.
#
diskutil mountDisk disk"${diskNumber}"
