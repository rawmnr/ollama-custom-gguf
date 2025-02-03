# Ollama Custom GGUF Docker Setup

This repository provides a custom Docker image for running Ollama with locally downloaded GGUF models. The setup is designed to create models based on configuration files (modelfiles) and remove the large GGUF model files after successful creation to free up space.

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
  Contains the corresponding model configuration files (e.g., `Modelfile.mymodel`). These files tell Ollama how to create the model from the GGUF file.

## How It Works

1. **Volume Mounting:**  
   At runtime, you mount both the `ggufs` and `modelfiles` directories into the container. The container uses these files to create models.

2. **Model Creation and Cleanup:**  
   The entrypoint script scans `/models/modelfiles` for files matching the pattern `Modelfile.*`. For each modelfile found, it:
   - Extracts the model name.
   - Checks that the corresponding GGUF file exists in `/models/ggufs`.
   - Runs the command `ollama create <model_name> -f <modelfile>` to create the model.
   - Deletes the GGUF file (if the volume is mounted read-write) to free up space.

3. **Ollama Server:**  
   After processing the models, the container starts the Ollama server (`ollama serve`) to handle inference requests.

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

Below is an example PowerShell command to run the container with the appropriate volume mounts. Note that the `ggufs` directory is mounted as read-write so that the container can delete the GGUF file after processing.

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
  Mounts the local `models\ggufs` folder into the container at `/models/ggufs` as read-write. This allows the entrypoint script to delete the file after successful model creation.

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

- **Deletion Warning:**  
  Since the `ggufs` directory is mounted as read-write, deleting a GGUF file from the container will remove it from your Windows host. If you wish to preserve the original files, consider copying them to a temporary directory within the container before deletion.

## Summary

This setup provides a modular and efficient method to load GGUF models into the Ollama container:
- **Modelfiles** drive the model creation process.
- **GGUF files** provide the heavy model data and are deleted post-creation to save space.
- The Ollama server starts to handle inference requests once all models are processed.

Enjoy using your custom Ollama container for fast model inference!
