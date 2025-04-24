# Documentation Plan

**I. Introduction**

*   Brief overview of the Gemini Key Manager project.
*   Purpose of the documentation.
*   Target audience.

**II. Core Features (from README.md)**

*   API Key Rotation
*   Placeholder Token
*   Daily Usage Tracking
*   Persistent Usage Data
*   Automatic Rate Limit (429) Handling
*   Daily Reset
*   OpenAI API Compatibility
*   Configurable Logging

**III. API Key Rotation and Usage Tracking Logic (Detailed Documentation with Mermaid Flowcharts and Sequence Diagram)**

*   **A. API Key Loading:**
    *   Explanation of the `load_api_keys` function, including error handling and file path resolution.
    *   Mermaid flowchart illustrating the key loading process from `key.txt`.
*   **B. API Key Cycling:**
    *   Explanation of the `cycle` iterator and how it's used for key rotation, including how the iterator is initialized and used.
    *   Mermaid flowchart illustrating the key cycling process.
*   **C. Usage Tracking:**
    *   Explanation of the `key_usage_counts` dictionary and how it's updated, including details on thread safety and potential race conditions.
    *   Explanation of the `load_usage_data` and `save_usage_data` functions, including file locking and data consistency.
    *   Mermaid flowchart illustrating the usage tracking process, including loading, updating, and saving usage data.
*   **D. Rate Limit Handling:**
    *   Explanation of how 429 errors are detected and handled, including the logic for determining when all keys are exhausted.
    *   Explanation of the `exhausted_keys_today` set and how it's used, including details on how keys are added and removed from the set.
    *   Mermaid flowchart illustrating the rate limit handling process.
*   **E. Daily Reset:**
    *   Explanation of how the usage counts and exhausted keys are reset daily, including the scheduling mechanism and potential issues with time zones.
    *   Mermaid flowchart illustrating the daily reset process.
*   **F. Sequence Diagram:**
    *   Mermaid sequence diagram illustrating the interaction between the different components involved in API key rotation and usage tracking.

**IV. Configuration**

*   Explanation of the configuration variables in `gemini_key_manager.py`, including default values and potential security implications.
*   Instructions on how to configure the proxy server, including how to set the API keys, placeholder token, and logging level.

**V. Usage**

*   Instructions on how to use the proxy server with different clients, including code examples and best practices.
*   Examples of API requests, including both direct Gemini API requests and OpenAI API compatible requests.

**VI. Deployment**

*   Instructions on how to deploy the proxy server using Docker, including details on how to configure the Docker image and run the container.
*   Explanation of the Docker configuration, including how to mount the `key.txt` and `key_usage.txt` files.

**VII. Troubleshooting**

*   Common issues and solutions, including how to diagnose and resolve rate limit errors, configuration issues, and deployment problems.

**Mermaid Flowcharts:**

*   **API Key Loading:**
    ```mermaid
    graph LR
    A[Start] --> B{key.txt exists?};
    B -- Yes --> C[Read keys from key.txt];
    B -- No --> D[Log error];
    C --> E{Keys loaded successfully?};
    E -- Yes --> F[Initialize key_cycler];
    E -- No --> G[Log error];
    F --> H[End];
    D --> H;
    G --> H;
    ```
*   **API Key Cycling:**
    ```mermaid
    graph LR
    A[Start] --> B[Get next key from key_cycler];
    B --> C{Key in exhausted_keys_today?};
    C -- Yes --> B;
    C -- No --> D[Use key for request];
    D --> E[End];
    ```
*   **Usage Tracking:**
    ```mermaid
    graph LR
    A[Start] --> B[Receive request];
    B --> C[Increment key_usage_counts];
    C --> D[Save usage data to key_usage.txt];
    D --> E[End];
    ```
*   **Rate Limit Handling:**
    ```mermaid
    graph LR
    A[Start] --> B[Send request with key];
    B --> C{429 error?};
    C -- Yes --> D[Add key to exhausted_keys_today];
    C -- No --> E[Request successful];
    D --> F[Save usage data];
    F --> G[Retry with next key];
    E --> H[End];
    G --> B;
    ```
*   **Daily Reset:**
    ```mermaid
    graph LR
    A[Start] --> B[Check if today's date is different from current_usage_date];
    B -- Yes --> C[Reset key_usage_counts and exhausted_keys_today];
    C --> D[Save usage data];
    D --> E[Update current_usage_date];
    E --> F[End];
    B -- No --> F;
    ```

**Mermaid Sequence Diagram:**

```mermaid
sequenceDiagram
    Client->>Proxy: Send API Request
    Proxy->>KeyCycler: Get next API Key
    KeyCycler->>Proxy: Return API Key
    Proxy->>Gemini API: Forward Request with API Key
    Gemini API->>Proxy: Return Response
    Proxy->>Client: Return Response