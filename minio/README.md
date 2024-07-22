Steps to Run
1. Set environment variables
    - `MINIO_ROOT_USER` (e.g. `admin`)
    - `MINIO_ROOT_PASSWORD` (e.g. `password`)
    - `MINIO_TAG` (e.g. `latest` or `RELEASE.2024-06-28T09-06-49Z`)
2. Run the following command
    ```bash
    envsubst < docker-compose.yaml | docker-compose -f - up -d
    ```
> This repo provides a `default.env` file providing default (dummy) values for these variables. Use it by running
> ```bash
> source default.env; envsubst < docker-compose.yaml | docker-compose -f - up -d
> ```
