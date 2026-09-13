#!/bin/bash

set -e

clear

echo "╔══════════════════════════════════╗"
echo "║        S A N D R O N E           ║"
echo "║       Installation Setup         ║"
echo "╚══════════════════════════════════╝"
echo


# ─────────────────────────────────────────────
# Check Sandrone directory
# ─────────────────────────────────────────────

echo "Checking Sandrone directory..."
echo

required_files=(
    "install.sh"
    "main.py"
    "actions.py"
    "response.py"
    "start.sh"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "  ✗ $file not found."
        echo
        echo "  Please run this installer from the Sandrone directory."
        echo
        echo "  Example:"
        echo "    cd Sandrone"
        echo "    ./install.sh"
        exit 1
    fi
done

echo "  ✓ Sandrone directory confirmed"
echo


# ─────────────────────────────────────────────
# 1. Dependencies
# ─────────────────────────────────────────────

echo "[1/7] Checking dependencies..."
echo

dependencies=(
    python
    curl
    tar
    unzip
)

for dependency in "${dependencies[@]}"; do
    if command -v "$dependency" &>/dev/null; then
        echo "  ✓ Found $dependency"
    else
        echo "  ✗ $dependency is missing."
        exit 1
    fi
done

echo


# ─────────────────────────────────────────────
# 2. Python environment
# ─────────────────────────────────────────────

echo "[2/7] Setting up Python environment..."
echo

if [ ! -d ".venv" ]; then
    python -m venv .venv
    echo "  ✓ Created .venv"
else
    echo "  ✓ .venv already exists"
fi

source .venv/bin/activate

echo "  Installing Python dependencies..."

pip install --upgrade pip
pip install sounddevice vosk

echo "  ✓ Python dependencies installed"
echo


# ─────────────────────────────────────────────
# 3. Directory structure
# ─────────────────────────────────────────────

echo "[3/7] Creating directories..."
echo

mkdir -p models
mkdir -p models/piper
mkdir -p voice_cache
mkdir -p piper

echo "  ✓ Directory structure ready"
echo


# ─────────────────────────────────────────────
# 4. Vosk model
# ─────────────────────────────────────────────

echo "[4/7] Setting up speech recognition..."
echo

echo "Choose a Vosk model:"
echo

echo "  1) vosk-model-small-en-us-0.15  [Recommended]"
echo "     40 MB — Lightweight US English model"
echo

echo "  2) vosk-model-en-us-0.22-lgraph"
echo "     128 MB — Larger US English model with dynamic graph"
echo

echo "  3) vosk-model-en-us-0.22"
echo "     1.8 GB — Accurate generic US English model"
echo

echo "  4) vosk-model-en-us-0.42-gigaspeech"
echo "     2.3 GB — Accurate model trained on GigaSpeech"
echo

read -rp "Choice [1]: " choice
choice=${choice:-1}

case "$choice" in
    1)
        VOSK_MODEL="vosk-model-small-en-us-0.15"
        VOSK_URL="https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip"
        ;;

    2)
        VOSK_MODEL="vosk-model-en-us-0.22-lgraph"
        VOSK_URL="https://alphacephei.com/vosk/models/vosk-model-en-us-0.22-lgraph.zip"
        ;;

    3)
        VOSK_MODEL="vosk-model-en-us-0.22"
        VOSK_URL="https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip"
        ;;

    4)
        VOSK_MODEL="vosk-model-en-us-0.42-gigaspeech"
        VOSK_URL="https://alphacephei.com/vosk/models/vosk-model-en-us-0.42-gigaspeech.zip"
        ;;

    *)
        echo
        echo "  ✗ Invalid choice."
        exit 1
        ;;
esac

echo
echo "  Selected: $VOSK_MODEL"
echo
echo "  Downloading..."

curl -fL "$VOSK_URL" -o /tmp/vosk-model.zip

echo "  Extracting..."

unzip -q /tmp/vosk-model.zip -d models/

rm /tmp/vosk-model.zip

echo "  ✓ Vosk model installed"
echo


# ─────────────────────────────────────────────
# 5. Piper executable
# ─────────────────────────────────────────────

echo "[5/7] Installing Piper..."
echo

PIPER_VERSION="1.2.0"
PIPER_URL="https://github.com/rhasspy/piper/releases/download/v${PIPER_VERSION}/piper_amd64.tar.gz"

echo "  Downloading Piper v${PIPER_VERSION}..."

curl -fL "$PIPER_URL" -o /tmp/piper.tar.gz

echo "  Extracting Piper..."

tar -xzf /tmp/piper.tar.gz -C piper --strip-components=1

rm /tmp/piper.tar.gz

chmod +x piper/piper

echo "  ✓ Piper executable installed"
echo


# ─────────────────────────────────────────────
# 6. Piper voice model
# ─────────────────────────────────────────────

echo "[6/7] Setting up Piper voice..."
echo

echo "Would you like to install the recommended Piper voice?"
echo

echo "  1) en_US-amy-medium  [Recommended]"
echo "     Medium-quality US English female voice"
echo

echo "  2) Skip"
echo "     Manually install a Piper voice later"
echo

echo "  Browse voices:"
echo "    https://rhasspy.github.io/piper-samples/"
echo

read -rp "Choice [1]: " piper_choice
piper_choice=${piper_choice:-1}

case "$piper_choice" in
    1)
        PIPER_MODEL="en_US-amy-medium"

        PIPER_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/medium/en_US-amy-medium.onnx?download=true"
        PIPER_CONFIG_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/medium/en_US-amy-medium.onnx.json?download=true"

        echo
        echo "  Selected: $PIPER_MODEL"
        echo
        echo "  Downloading voice model..."

        curl -fL "$PIPER_URL" \
            -o "models/piper/en_US-amy-medium.onnx"

        curl -fL "$PIPER_CONFIG_URL" \
            -o "models/piper/en_US-amy-medium.onnx.json"

        echo "  ✓ Piper voice installed"
        ;;

    2)
        PIPER_MODEL=""

        echo
        echo "  ✓ Skipped Piper voice installation"
        ;;

    *)
        echo
        echo "  ✗ Invalid choice."
        exit 1
        ;;
esac

echo


# ─────────────────────────────────────────────
# 7. Configuration
# ─────────────────────────────────────────────

echo "[7/7] Creating configuration..."
echo

if [ -n "$PIPER_MODEL" ]; then
    PIPER_MODEL_PATH="./models/piper/${PIPER_MODEL}.onnx"
else
    PIPER_MODEL_PATH="./models/piper/en_US-amy-medium.onnx"
fi

cat > config.py << EOF
PIPER_EXE = "./piper/piper"
PIPER_MODEL = "$PIPER_MODEL_PATH"

SAMPLE_RATE = 16000
BLOCK_SIZE = 8000
MODEL_PATH = "models/$VOSK_MODEL"
EOF

echo "  ✓ config.py created"
echo


# ─────────────────────────────────────────────
# Finalizing
# ─────────────────────────────────────────────

echo "Finalizing installation..."

chmod +x start.sh 2>/dev/null || true

echo
echo "╔══════════════════════════════════╗"
echo "║      Installation complete!      ║"
echo "╚══════════════════════════════════╝"
echo

echo "Installed:"
echo "  ✓ Python environment"
echo "  ✓ Vosk speech recognition"
echo "  ✓ Piper executable"

if [ -n "$PIPER_MODEL" ]; then
    echo "  ✓ Piper voice: $PIPER_MODEL"
else
    echo "  ! Piper voice: Not installed"
fi

echo

if [ -z "$PIPER_MODEL" ]; then
    echo "Before running Sandrone, install a Piper voice."
    echo
    echo "Browse available voices:"
    echo "  https://rhasspy.github.io/piper-samples/"
    echo
    echo "Then update PIPER_MODEL in config.py."
    echo
fi

echo "To start Sandrone:"
echo
echo "  ./start.sh"
echo
echo "Tip: For quick access, you can:"
echo "  • Bind ./start.sh to a keyboard shortcut"
echo "  • Add Sandrone to your autostart"
echo