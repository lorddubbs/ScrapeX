# Stage1: Builder stage, starts a new build stage named builder using the slim version of the Python 3.12 image.
FROM python:3.12-slim AS builder

# Set the working directory in the container
WORKDIR /app

# Install system dependencies for building Python packages
# Installs the necessary system dependencies without recommended extra packages.
# Cleans up to reduce image size.
# Can only be run by root user
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and group for better security
# All actions frojm here are taken by non root user
RUN groupadd -r appgroup && useradd -r -g appgroup -d /app -s /sbin/nologin appuser

# Copy the requirements file into the container
# This step is done before copying the rest of the code.
# This is done to leverage Docker's caching mechanism.
# Allows this step to be cached if requirements.txt doesn't change
COPY requirements.txt .

# Creates a python virtual env and installs dependencies
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Change ownership of the virtual environment to the non-root user
RUN chown -R appuser:appgroup /opt/venv

# Stage 2: Final Image, Starts the final stage with a clean, slim Python 3.12 image
FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Copy the non-root user and group from the builder stage
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy only the virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Ensure the virtual environment is used for all subsequent commands
ENV PATH="/opt/venv/bin:$PATH"

# Copy the application code into the container
COPY . /app

# Create logs folder and Change ownership of the application code to non-root user
RUN mkdir -p /logs && chown -R appuser:appgroup /logs && chmod 755 /logs
# Switch to the non-root user
USER appuser

# Run the main script
CMD ["python", "src/main.py"]