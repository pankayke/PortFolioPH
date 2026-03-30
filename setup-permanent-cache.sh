#!/usr/bin/env bash
# ============================================================================
# Permanent Flutter Package Cache Setup - Linux/Mac Version
# Run this once to ensure all Flutter packages are cached permanently
# ============================================================================

echo ""
echo "============================================"
echo "  Flutter Permanent Cache Setup"
echo "============================================"
echo ""

# Set cache path
CACHE_PATH="$HOME/.flutter_pub_cache"

# Step 1: Create cache directory
echo "[1/3] Creating cache directory..."
mkdir -p "$CACHE_PATH"
echo "   ✓ Directory created: $CACHE_PATH"

# Step 2: Set environment variable in shell profile
echo ""
echo "[2/3] Setting PUB_CACHE in shell profile..."

# Detect shell
if [ -n "$ZSH_VERSION" ]; then
    PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    PROFILE="$HOME/.bashrc"
else
    PROFILE="$HOME/.profile"
fi

# Add to profile
if ! grep -q "export PUB_CACHE" "$PROFILE"; then
    echo "export PUB_CACHE=\"$CACHE_PATH\"" >> "$PROFILE"
    echo "   ✓ Added to $PROFILE"
else
    echo "   ✓ Already configured in $PROFILE"
fi

# Step 3: Source the profile
echo ""
echo "[3/3] Activating environment..."
source "$PROFILE"
echo "   ✓ PUB_CACHE=$PUB_CACHE"

# Summary
echo ""
echo "============================================"
echo "  Setup Complete!"
echo "============================================"
echo ""
echo "Your Flutter package cache is now permanent:"
echo "  Location: $CACHE_PATH"
echo "  Variable: PUB_CACHE"
echo ""
echo "For future Flutter projects:"
echo "  1. Create: flutter create my_app"
echo "  2. Get dependencies: flutter pub get"
echo "  3. Run: flutter run"
echo ""
echo "All packages will be instantly cached! ⚡"
echo ""
