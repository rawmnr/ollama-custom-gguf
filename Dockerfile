# Use the official Ollama image as the base.
FROM ollama/ollama:latest

# Install required packages.
# (Since the base image isn’t Alpine, use apt-get)
RUN apt-get update && \
    apt-get install -y dos2unix bash && \
    rm -rf /var/lib/apt/lists/*

# Create the directories where models will be available.
RUN mkdir -p /models/ggufs /models/modelfiles

# Copy the entrypoint script into the container and ensure proper permissions.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN dos2unix /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
