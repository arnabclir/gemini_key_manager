# Stage 1: Builder
# Use a full Python image to install dependencies
FROM python:3.9-slim-buster AS builder

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt, including Gunicorn
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Stage 2: Runtime
# Use a slimmer Python image for the final application
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy only the installed packages from the builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Copy the application code into the container at /app
# key.txt will be mounted as a volume at runtime
COPY gemini_key_manager.py .
COPY key.txt .
# Make port 5000 available to the world outside this container
# This should match the LISTEN_PORT in gemini_key_manager.py
EXPOSE 5000

# Run gemini_key_manager.py when the container launches using Gunicorn
# Use 0.0.0.0 to listen on all interfaces within the container
CMD ["gunicorn", "-b", "0.0.0.0:5000", "gemini_key_manager:app"]
