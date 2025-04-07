# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
# Also install waitress for running the Flask app in production
RUN pip install --no-cache-dir -r requirements.txt waitress

# Copy the rest of the application code into the container at /app
# key.txt will be mounted as a volume at runtime
COPY gemini_key_manager.py .
# COPY key.txt . # Removed: key.txt should be mounted by the user

# Make port 5000 available to the world outside this container
# This should match the LISTEN_PORT in gemini_key_manager.py
EXPOSE 5000

# Define environment variable (optional, can be overridden)
# ENV NAME World

# Run gemini_key_manager.py when the container launches using waitress
# Use 0.0.0.0 to listen on all interfaces within the container
CMD ["waitress-serve", "--host=0.0.0.0", "--port=5000", "gemini_key_manager:app"]
