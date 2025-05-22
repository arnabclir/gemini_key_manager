#!/bin/bash

# Script to activate the Python virtual environment and run gemini_key_manager.py

# Define the virtual environment directory
VENV_DIR=".venv"
PYTHON_SCRIPT="gemini_key_manager.py"

echo "Checking for virtual environment in '$VENV_DIR'..."

# Check if the virtual environment directory exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Error: Virtual environment directory '$VENV_DIR' not found."
    echo "Please ensure it exists or create it using 'python -m venv $VENV_DIR'."
    exit 1
fi

# Determine the activation script path based on OS (Windows for Git Bash/WSL)
ACTIVATION_SCRIPT="$VENV_DIR/Scripts/activate"

echo "Attempting to activate virtual environment from '$ACTIVATION_SCRIPT'..."

# Activate the virtual environment
if [ -f "$ACTIVATION_SCRIPT" ]; then
    source "$ACTIVATION_SCRIPT"
    if [ $? -eq 0 ]; then
        echo "Virtual environment activated successfully."
    else
        echo "Error: Failed to activate virtual environment."
        exit 1
    fi
else
    echo "Error: Activation script '$ACTIVATION_SCRIPT' not found."
    echo "Please ensure the virtual environment is correctly set up for your shell."
    exit 1
fi

echo "Running the main Python script: '$PYTHON_SCRIPT'..."

# Run the main Python script
python "$PYTHON_SCRIPT"

# Deactivate the virtual environment (optional, but good practice if not needed afterwards)
# deactivate
# echo "Virtual environment deactivated."

echo "Script finished."