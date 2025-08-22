#!/bin/bash

# Force Git Update Script
# This script forces git to pull latest changes, overwriting local changes

set -e

echo "🔄 Force Git Update"
echo "==================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if [[ ! -d ".git" ]]; then
    print_error "Not in a git repository. Please run this from the project root."
    exit 1
fi

print_warning "This will OVERWRITE all local changes and force pull from remote!"
echo ""

# Show current status
print_status "Current git status:"
git status --porcelain

echo ""
read -p "Are you sure you want to continue? This will lose all local changes! (y/N): " confirm

if [[ $confirm != "y" && $confirm != "Y" ]]; then
    print_warning "Operation cancelled."
    exit 0
fi

# Force reset to match remote
print_status "Fetching latest from remote..."
git fetch origin

print_status "Force resetting to match remote main branch..."
git reset --hard origin/main

print_status "Cleaning up any untracked files..."
git clean -fd

print_success "Git repository now matches remote exactly!"
print_status "All local changes have been overwritten."

# Show final status
echo ""
print_status "Final git status:"
git status
