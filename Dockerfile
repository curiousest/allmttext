# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY app/ .

# Expose any necessary ports (if applicable)
# EXPOSE 8080

# Set environment variables (if any)

# Command to run your application
CMD ["python", "update_embeddings.py"]
