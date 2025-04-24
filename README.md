# Gemini Key Manager

[简体中文](README_zh.md) | English

A simple Python Flask proxy server designed to manage multiple Google Gemini API keys effectively. It allows clients to interact with the Gemini API using a single placeholder token, while the proxy handles key rotation, daily usage tracking, and rate limit management behind the scenes.

This is particularly useful when you have multiple API keys and want to distribute the load, track usage per key, and automatically handle keys that hit their daily rate limits (429 errors).

## Core Features

*   **API Key Rotation:** Cycles through a list of provided Gemini API keys (`key.txt`) for each incoming request.
*   **Placeholder Token:** Clients use a predefined placeholder token (`PLACEHOLDER_GEMINI_TOKEN`) for authentication against the proxy, keeping the real keys secure on the server.
*   **Daily Usage Tracking:** Monitors and logs the number of times each API key is used per day.
*   **Persistent Usage Data:** Saves daily usage counts and the list of exhausted keys to a local file (`key_usage.txt`) in JSON format, allowing state to be preserved across server restarts.
*   **Automatic Rate Limit (429) Handling:** Detects when a key receives a 429 "Resource Exhausted" error from the Gemini API.
    *   Marks the exhausted key as unusable for the rest of the current day.
    *   Automatically retries the request with the next available key in the pool.
    *   Returns a 503 "Service Unavailable" error if all keys become exhausted for the day.
*   **Daily Reset:** Automatically resets usage counts and the list of exhausted keys at the beginning of each new day.
*   **OpenAI API Compatibility:** Acts as an adapter for the `/v1/chat/completions` endpoint. Accepts requests in OpenAI format (including streaming) and translates them to/from the Gemini API format. Tested with CherryStudio and Cline.
*   **Configurable Logging:** Provides detailed logging to both console and rotating log files (written to the current working directory by default) for debugging and monitoring.

## Prerequisites

*   **Python:** Version 3.7 or higher is recommended.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/bamboo-pan/gemini_key_manager.git
    cd gemini_key_manager
    ```
2.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
    *Alternatively, if you prefer not to clone, ensure you have `requests` and `flask` installed (`pip install requests flask`).*

## Configuration and Usage

1.  **Create Key File:** Create a file named `key.txt` in the project directory.
2.  **Add API Keys:** Add your Google Gemini API keys to `key.txt`, placing one key per line.
3.  **Configure Placeholder (Optional):** Review and optionally change the `PLACEHOLDER_GEMINI_TOKEN` value within the `gemini_key_manager.py` script. This is the token your clients will use.
4.  **Run the Proxy Server:**
    ```bash
    python gemini_key_manager.py
    ```
    The server will start listening on `http://0.0.0.0:5000` by default.
5.  **Configure Clients:**
    *   **For Direct Gemini API Usage:** Update your client applications to send requests to the proxy server's address (`http://<proxy_server_ip>:5000/<gemini_path>`, e.g., `http://localhost:5000/v1beta/models/gemini-pro:generateContent`). Clients may optionally include the configured `PLACEHOLDER_GEMINI_TOKEN` in the `x-goog-api-key` header for authentication against the proxy. If omitted, the proxy will still process the request.
    *   **For OpenAI API Compatibility:** Configure your client (like CherryStudio, etc.) to use the proxy server's address as the base URL and target the `/v1/chat/completions` endpoint (e.g., `http://localhost:5000/v1/chat/completions`). The client should use the `PLACEHOLDER_GEMINI_TOKEN` as the API Key (typically sent as a Bearer token in the `Authorization` header). The proxy will handle the translation to and from the Gemini API.

## Deployment Note

*   **Production Considerations:** The built-in Flask development server (`app.run()`) is primarily for development and testing. For production environments, it's generally recommended to run Flask applications behind a more robust WSGI server (like Gunicorn or uWSGI) for better performance and stability. If you choose to use this proxy in production, consider deploying it behind a production-grade WSGI server.
*   **Network Accessibility:** The default configuration `LISTEN_HOST = "0.0.0.0"` makes the proxy server accessible from other devices on your local network. Ensure your network environment is secure or change `LISTEN_HOST` to `"127.0.0.1"` (localhost) if you only need to access it from the same machine.

## Using Docker

You can use Docker to build and run this proxy server, simplifying deployment and environment management.

### Building the Local Image

If you prefer to build the Docker image yourself:

1.  Ensure you have Docker installed.
2.  In the project root directory (where the `Dockerfile` is located), run:
    ```bash
    docker build -t gemini-key-manager .
    ```
    This builds a local image named `gemini-key-manager` using the `Dockerfile` in the current directory.

### Using the Pre-built Image

A pre-built Docker image is available for direct use:

```bash
docker pull bamboo2019/gemini-key-manager:latest # Or specify a particular tag
```
*(Replace `latest` with the specific tag you need)*

### Running the Docker Container

Whether you built the image locally or pulled the pre-built one, the command to run the container is similar. **Before running, ensure you have created a `key.txt` file locally and placed your Gemini API keys inside it.**

Here's an example command to run the container:

```bash
# Replace <your_local_key_file_path> with the **absolute or relative path** to your local key.txt file (e.g., ./key.txt)
# Replace <your_local_usage_data_file_path> with the local **file path** where you want to store persistent usage data (e.g., ./key_usage.txt)
# Replace <image_name> with your local image name (e.g., gemini-key-manager) or the pre-built image name (e.g., bamboo2019/gemini-key-manager:latest)
# (Optional) If you want to persist log files, you can add -v "<your_local_app_dir>:/app" to mount the entire /app directory

docker run -d \
  -p 5000:5000 \
  -v "<your_local_key_file_path>:/app/key.txt" \
  -v "<your_local_usage_data_file_path>:/app/key_usage.txt" \
  --name gemini-proxy \
  <image_name>
```

**Parameter Explanation:**

*   `-d`: Run the container in detached mode (in the background).
*   `-p 5000:5000`: Map port 5000 on the host to port 5000 in the container.
*   `-v "<your_local_key_file_path>:/app/key.txt"`: **(Required)** Mount your local `key.txt` file to `/app/key.txt` inside the container. This is essential for the application to read the API keys. Ensure you provide the correct local file path.
*   `-v "<your_local_usage_data_file_path>:/app/key_usage.txt"`: **(Recommended)** Mount a local **file** to `/app/key_usage.txt` inside the container. This persists the key usage counts and exhausted list across container restarts. Provide the full path to a local file (e.g., `/path/to/my/usage_data.txt` or `c:\data\usage_data.txt`). Docker will typically create this file if it doesn't exist (but creating an empty file beforehand is advised).
*   `--name gemini-proxy`: Assign a convenient name to the container.
*   `<image_name>`: Specify the Docker image to use.
*   **Log Files:** Log files (e.g., `proxy_debug_YYYYMMDD_HHMMSS.log`) are now written directly to the script's current working directory. Inside the Docker container, the default working directory is `/app`. If you wish to access or persist these logs outside the container, you can optionally mount a local directory to the container's `/app` directory (e.g., add `-v "<your_local_app_dir>:/app"`). Note that this replaces the entire `/app` directory content with your local directory, so ensure your local directory contains the necessary `gemini_key_manager.py` and `requirements.txt` if dependencies need rebuilding. A simpler approach is to use `docker logs gemini-proxy` to view live logs or `docker cp gemini-proxy:/app/proxy_debug_....log .` to copy specific log files out.

**Important Notes:**

*   Ensure the local file paths provided for the `-v` flags are correct. Relative paths are relative to your current directory when running `docker run`.
*   Mounting the `key_usage.txt` file is crucial for preserving state across container restarts or updates. Log files are stored inside the container by default (in the `/app` directory).
