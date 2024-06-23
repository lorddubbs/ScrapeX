FROM python:3.12-slim AS builder

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Set environment variables
ENV CONFIG_FILE=/app/config/config.json

# Run the main script
CMD ["python", "src/main.py"]
