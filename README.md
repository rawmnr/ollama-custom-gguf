# Ollama Custom GGUF Docker Setup

This repository provides a custom Docker image for running Ollama with locally downloaded GGUF models. The setup is designed to create models based on configuration files (modelfiles) without deleting the large GGUF model files after model creation.

## Folder Structure

Place your models in the following directory structure:

```
models/
├── ggufs/
│   └── mymodel.gguf
└── modelfiles/
    └── Modelfile.mymodel
```

- **ggufs/**  
  Contains the large GGUF model files (e.g., `mymodel.gguf`).

- **modelfiles/**  
  Contains the corresponding model configuration files (e.g., `Modelfile.mymodel`). These files instruct Ollama how to create the model from the GGUF file.

## How It Works

1. **Volume Mounting:**  
   At runtime, you mount both the `ggufs` and `modelfiles` directories into the container. The container uses these files to create models.

2. **Model Creation:**  
   The entrypoint script performs the following steps:
   - Ensures that the `/models/ggufs` and `/models/modelfiles` directories exist.
   - Starts the Ollama server (`ollama serve`) in the background.
   - Waits for a short period to allow the server to initialize.
   - Iterates over each file in `/models/modelfiles` that matches the pattern `Modelfile.*`.
   - Extracts the model name from the filename.
   - Checks for the corresponding GGUF file in `/models/ggufs` (expected to be named `<model_name>.gguf`).
   - Creates the model using the command:
     ```bash
     ollama create <model_name> -f <modelfile>
     ```
   - *Note:* The step that previously deleted the GGUF file after model creation has been removed to preserve the file on the host.

3. **Ollama Server:**  
   Once all models are processed, the script waits on the Ollama server process, which remains active to handle inference requests.

## Prerequisites

- Docker with NVIDIA GPU support (if GPU acceleration is desired)
- PowerShell (or another shell) on Windows

## Building the Image

Build your custom Docker image using the provided Dockerfile:

```powershell
docker build -t ollama-custom .
```

This command builds the image and tags it as `ollama-custom`.

## Running the Container

### PowerShell Command

Below is an example PowerShell command to run the container with the appropriate volume mounts. The `ggufs` directory is mounted as read-write (allowing for future modifications if needed), while the `modelfiles` directory is mounted as read-only.

```powershell
docker run -d --gpus=all `
  -p 11434:11434 `
  -v ${PWD}\models\ggufs:/models/ggufs `
  -v ${PWD}\models\modelfiles:/models/modelfiles:ro `
  --name ollama-container `
  ollama-custom
```

### Explanation of the Command

- **`--gpus=all`**  
  Allocates all available GPUs to the container.

- **`-p 11434:11434`**  
  Maps port 11434 on the host to port 11434 in the container (default Ollama port).

- **`-v ${PWD}\models\ggufs:/models/ggufs`**  
  Mounts the local `models\ggufs` folder into the container at `/models/ggufs` as read-write.

- **`-v ${PWD}\models\modelfiles:/models/modelfiles:ro`**  
  Mounts the local `models\modelfiles` folder into the container at `/models/modelfiles` as read-only.

- **`--name ollama-container`**  
  Names the container `ollama-container`.

- **`ollama-custom`**  
  Specifies the Docker image to run.

## Logging and Troubleshooting

- **Server Logs:**  
  You can view container logs using:
  ```powershell
  docker logs ollama-container
  ```

- **Model Creation Issues:**  
  Ensure that for every `Modelfile.<model_name>` in `/models/modelfiles`, there is a corresponding `<model_name>.gguf` file in `/models/ggufs`. The entrypoint script will exit with an error if a GGUF file is missing.

## Summary

This setup provides a modular and efficient method to load GGUF models into the Ollama container:
- **Modelfiles** drive the model creation process.
- **GGUF files** provide the heavy model data and are preserved after model creation.
- The Ollama server starts to handle inference requests once all models are processed.

Enjoy using your custom Ollama container for fast model inference!
