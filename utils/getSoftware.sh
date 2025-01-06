#!/bin/bash

# Define the URLs for the MSI files
QEMU_GA_URL="https://fedorapeople.org/groups/virt/virt/virtio-win/direct-downloads/latest-qemu-ga/qemu-ga-x86_64.msi"
VIRTIO_WIN_GT_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win-gt-x64.msi"
CLOUDBASE_INIT_URL="https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi"

# Define the output folder
OUTPUT_FOLDER="../software"

# Create the folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

# Download the files
echo "Downloading qemu-ga-x86_64.msi..."
curl -o "$OUTPUT_FOLDER/qemu-ga-x86_64.msi" "$QEMU_GA_URL"

echo "Downloading virtio-win-gt-x64.msi..."
curl -o "$OUTPUT_FOLDER/virtio-win-gt-x64.msi" "$VIRTIO_WIN_GT_URL"

echo "Downloading CloudbaseInitSetup_x64.msi..."
curl -o "$OUTPUT_FOLDER/CloudbaseInitSetup_x64.msi" "$CLOUDBASE_INIT_URL"

echo "Downloads completed. Files are saved in $OUTPUT_FOLDER."
