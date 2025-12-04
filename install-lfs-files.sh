#!/bin/bash
# Script to install Git LFS files during Vercel build

echo "Installing Git LFS..."

# Install git-lfs if not already installed
if ! command -v git-lfs &> /dev/null; then
    echo "Git LFS not found, installing..."
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
    apt-get install git-lfs -y
fi

# Initialize Git LFS
git lfs install

# Pull LFS files
echo "Pulling LFS files..."
git lfs pull

echo "LFS files installed successfully!"
