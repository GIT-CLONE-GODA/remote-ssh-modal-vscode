#!/bin/bash
# vLLM Installation Script - One file to setup everything
# After running this, you can use: vllm serve <model-name>

set -e

echo "=== Installing vLLM with CUDA fixes ==="
echo ""

# Install system dependencies
echo "[1/4] Installing system dependencies..."
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq python3.10-dev build-essential > /dev/null 2>&1
echo "✓ Dependencies installed"

# Install vLLM globally
echo "[2/4] Installing vLLM..."
pip install -q --upgrade pip > /dev/null 2>&1
pip install -q vllm > /dev/null 2>&1
echo "✓ vLLM installed"

# Fix CUDA environment
echo "[3/4] Fixing CUDA environment..."
# Find libcuda.so.1 and create symlinks
LIBCUDA_PATH=$(find /usr -name "libcuda.so.1" 2>/dev/null | head -1)
if [ -z "$LIBCUDA_PATH" ]; then
    echo "✗ Error: libcuda.so.1 not found!"
    exit 1
fi

# Create symlinks in /usr/local/lib (writable location)
mkdir -p /usr/local/lib/cuda_stubs
ln -sf "$LIBCUDA_PATH" /usr/local/lib/cuda_stubs/libcuda.so
ln -sf "$LIBCUDA_PATH" /usr/local/lib/cuda_stubs/libcuda.so.1

# Configure ldconfig to find the library
echo "/usr/local/lib/cuda_stubs" > /etc/ld.so.conf.d/cuda_stubs.conf
ldconfig

echo "✓ CUDA environment fixed"

# Setup environment permanently
echo "[4/4] Setting up environment..."
cat >> ~/.bashrc << 'ENVEOF'

# vLLM CUDA environment - Auto-setup on shell start
export LIBRARY_PATH=/usr/local/cuda/lib64/stubs:/usr/local/nvidia/lib64:/usr/local/cuda/lib64:$LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/nvidia/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENVEOF

# Also set for current session
export LIBRARY_PATH=/usr/local/cuda/lib64/stubs:/usr/local/nvidia/lib64:/usr/local/cuda/lib64:$LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/nvidia/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

echo "✓ Environment configured"

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "vLLM is ready to use! Example:"
echo "  vllm serve Qwen/Qwen2.5-0.5B-Instruct --api-key mykey"
echo ""
echo "More options:"
echo "  vllm serve Qwen/Qwen2.5-1.5B-Instruct \\"
echo "    --served-model-name mymodel \\"
echo "    --api-key secret123 \\"
echo "    --gpu-memory-utilization 0.9 \\"
echo "    --max-model-len 2048 \\"
echo "    --enforce-eager"
echo ""
echo "RUN        source ~/.bashrc"
echo ""
