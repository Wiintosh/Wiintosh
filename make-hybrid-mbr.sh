#!/bin/bash

#
# Creates MBR based on first FAT32 partiton on an APM disk.
#
diskutil list
echo "Enter disk number to create APM-MBR on (may be destructive):"
read -r N

#
# Find the first FAT32 partition entry
#
diskEntry=$(diskutil list disk"${N}" | awk '/DOS_FAT_32/ {print; exit}')
if [ -z "$diskEntry" ]; then
    echo "No FAT32 partition found."
    exit 1
fi
disk=$(echo "$diskEntry" | awk '{print $NF}')

#
# Save plist info
#
diskutil info -plist "$disk" > diskutil.plist

#
# Get partition info
#
blockSize=$(/usr/libexec/PlistBuddy -c "Print :DeviceBlockSize" diskutil.plist)
partOffsetRaw=$(/usr/libexec/PlistBuddy -c "Print :PartitionMapPartitionOffset" diskutil.plist)
partSizeRaw=$(/usr/libexec/PlistBuddy -c "Print :Size" diskutil.plist)
sudo rm -f diskutil.plist

partOffset=$((partOffsetRaw / blockSize))
partSize=$((partSizeRaw / blockSize))
echo "FAT32 at block $partOffset size $partSize"

#
# Unmount all volumes.
#
echo "Unmounting disk$N..."
sudo diskutil unmountDisk force disk"${N}"

#
# Get first sector
#
sudo dd if=/dev/disk"${N}" of=disksector.bin bs=1 count=512 conv=notrunc

#
# Create MBR partition record
#
echo "Writing FAT32 MBR partition..."
printf '\x00\xFE\xFF\xFF\x0B\xFE\xFF\xFF' | sudo dd of=disksector.bin bs=1 seek=446 conv=notrunc
printf "$(printf '\\x%02x\\x%02x\\x%02x\\x%02x' \
  $(( partOffset & 0xFF )) \
  $(( (partOffset >> 8) & 0xFF )) \
  $(( (partOffset >> 16) & 0xFF )) \
  $(( (partOffset >> 24) & 0xFF )) ))" \
| sudo dd of=disksector.bin bs=1 seek=454 conv=notrunc
printf "$(printf '\\x%02x\\x%02x\\x%02x\\x%02x' \
  $(( partSize & 0xFF )) \
  $(( (partSize >> 8) & 0xFF )) \
  $(( (partSize >> 16) & 0xFF )) \
  $(( (partSize >> 24) & 0xFF )) ))" \
| sudo dd of=disksector.bin bs=1 seek=458 conv=notrunc

printf '\x00\x00\x00\x00\x00\x00\x00\x00' | sudo dd of=disksector.bin bs=1 seek=462 conv=notrunc

#
# Write MBR signature
#
echo "Writing MBR signature..."
printf '\x55\xAA' | sudo dd of=disksector.bin bs=1 seek=510 conv=notrunc

#
# Write sector back
#
sudo dd if=disksector.bin of=/dev/disk"${N}" bs=1 conv=notrunc
sudo rm -f disksector.bin

#
# Remount all volumes.
#
diskutil mountDisk disk"${N}"
