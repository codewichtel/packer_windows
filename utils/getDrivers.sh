#!/bin/bash

# Variables
ISO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"       # URL to download the VirtIO ISO
DESTINATION="../drivers/"   # Destination directory
SOFTWARE_DESTINATION="../software/"
# Check if both arguments are provided
if [ -z "$ISO_URL" ] || [ -z "$DESTINATION" ]; then
  echo "Usage: $0 <url-to-virtio-iso> <destination-folder>"
  exit 1
fi

# Extract the ISO file name from the URL
ISO_FILE=$(basename "$ISO_URL")

# Download the ISO if not already present
if [ ! -f "$ISO_FILE" ]; then
  echo "Downloading VirtIO ISO from '$ISO_URL'..."
  wget -O "$ISO_FILE" "$ISO_URL" || { echo "Failed to download ISO"; exit 1; }
else
  echo "ISO file '$ISO_FILE' already exists. Skipping download."
fi

# Check if the destination folder exists, create if not
if [ ! -d "$DESTINATION" ]; then
  echo "Destination folder '$DESTINATION' does not exist. Creating it..."
  mkdir -p "$DESTINATION"
fi

# Create a temporary mount point
MOUNT_POINT=$(mktemp -d)

# Mount the ISO
sudo mount -o loop "$ISO_FILE" "$MOUNT_POINT" || { echo "Failed to mount ISO"; exit 1; }

# Copy the amd64 folder
if [ -d "$MOUNT_POINT/amd64" ]; then
  echo "Copying 'amd64' folder to '$DESTINATION'..."
  cp -r "$MOUNT_POINT/amd64" "$DESTINATION"
  echo "Copy completed."
else
  echo "Error: 'amd64' folder not found in the ISO."
fi

# Unmount the ISO and clean up
sudo umount "$MOUNT_POINT"
sudo rmdir "$MOUNT_POINT"
rm virtio-win.iso
echo "Script completed."
