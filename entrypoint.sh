#!/bin/bash
set -e

echo 'Starting Ollama with custom gguf model processing...'

# Ensure model directories exist
mkdir -p /models/ggufs /models/modelfiles

# Start Ollama serve in the background
ollama serve &
OLLAMA_PID=$!

# Wait for the Ollama server to initialize (adjust sleep duration as needed)
echo "Waiting for Ollama server to initialize..."
sleep 10

# Process each modelfile to create models
for modelfile in /models/modelfiles/Modelfile.*; do
    # Skip if no modelfile is found.
    if [ ! -f "$modelfile" ]; then
        echo "No modelfile found in /models/modelfiles; skipping..."
        continue
    fi

    # Extract model name
    model_name=$(basename "$modelfile" | cut -d. -f2-)
    gguf_file="/models/ggufs/${model_name}.gguf"

    echo "Processing model: ${model_name}"

    if [ -f "$gguf_file" ]; then
        echo "Creating model '${model_name}' using ${modelfile}..."
        ollama create "$model_name" -f "$modelfile"
    else
        echo "Error: Expected gguf file not found: ${gguf_file}"
        exit 1
    fi
done

# Wait for the background server process to finish (if needed)
wait $OLLAMA_PID
