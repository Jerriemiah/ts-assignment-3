# Assignment 3 – GitHub Actions / Docker / Bash

This project implements a small Bash-based CLI application wired into a Dockerized workflow and automated with GitHub Actions CI. The application provides basic system diagnostics and port-check utilities, while the CI pipeline validates syntax, runs tests, and builds a Docker image on every push and pull request.

***

## Project structure

```text
.
├── README.md
├── app/
│   └── app.sh              # Main CLI entrypoint
├── scripts/
│   ├── lint.sh             # Linting / static checks for scripts
│   └── build.sh            # Optional build / setup helper
├── tests/
│   └── test.sh             # Automated test suite for the app
├── Dockerfile              # Docker image definition
├── compose.yaml            # Docker Compose configuration
├── .dockerignore           # Files/folders excluded from Docker build
└── .github/
    └── workflows/
        └── ci.yml          # GitHub Actions CI workflow
```

***

## Requirements

- Bash (for running scripts locally)
- Docker and Docker Compose (for containerized runs and CI-like tests)
- Git (for version control and CI triggers)

***

## CLI usage

The main application is `app/app.sh`. It is also used as the container entrypoint, so the same commands work both locally and inside Docker.

### General form

```bash
# Local
./app/app.sh <command> [arguments...]

# Docker
docker run --rm <image-name> <command> [arguments...]

# Docker Compose
docker compose run --rm app <command> [arguments...]
```

Replace `<image-name>` with the image you build from the Dockerfile (e.g. `devops-ci-app`).

***

## Available commands

### `help`

Show usage information and available commands.

```bash
./app/app.sh help
docker run --rm <image-name> help
```

**Exit codes:**

- `0` – help displayed successfully.

***

### `system-info`

Display basic Linux system information (hostname, user, kernel, uptime, etc.).

```bash
./app/app.sh system-info
docker run --rm <image-name> system-info
```

**Exit codes:**

- `0` – system information displayed successfully.
- `1` – runtime error while gathering information.

***

### `check-port <host> <port>`

Check TCP connectivity to a given host and port.

```bash
./app/app.sh check-port localhost 80
docker run --rm <image-name> check-port localhost 443
```

**Parameters:**

- `<host>` – hostname or IP (e.g. `localhost`, `example.com`, `8.8.8.8`)
- `<port>` – TCP port number (integer from `1` to `65535`)

**Exit codes:**

- `0` – port is reachable / check succeeded.
- `1` – port is not reachable / check failed.
- `2` – invalid input, such as:
  - missing host or port
  - non-numeric port
  - port outside the range `1–65535`

***

### Invalid or missing commands

Running the app without a command, or with an unknown command, should fail with exit code `2`:

```bash
./app/app.sh
./app/app.sh unknown-command
```

***

## Running with Docker

### Build the image

From the project root:

```bash
docker build -t devops-ci-app .
```

### Run commands in a container

```bash
docker run --rm devops-ci-app help
docker run --rm devops-ci-app system-info
docker run --rm devops-ci-app check-port localhost 80
```

***

## Running with Docker Compose

`compose.yaml` defines an `app` service that builds from the Dockerfile.

```bash
docker compose run --rm app help
docker compose run --rm app system-info
docker compose run --rm app check-port localhost 443
```

***

## Testing

### Local test suite

Run the provided test script to verify basic functionality:

```bash
# If executable
./tests/test.sh

# Or explicitly with Bash
bash tests/test.sh
```

The test suite should cover at least:

- `help` command
- `system-info` command
- `check-port` with valid and invalid inputs
- Invalid/missing command handling (ensuring non-zero exit codes)

***

## Linting

The `scripts/lint.sh` script performs static checks on the Bash scripts (for example, syntax checks with `bash -n`, style checks, or other project-specific rules).

```bash
# If executable
./scripts/lint.sh

# Or explicitly
bash scripts/lint.sh
```

A successful run should exit with `0`; failures should exit non-zero and print details.

***

## GitHub Actions CI

The workflow in `.github/workflows/ci.yml` automates validation on every push and pull request.

### Triggers

- `push` events
- `pull_request` events

### Jobs

- `validate`  
  - Checks Bash syntax for all scripts.
  - Runs linting (`scripts/lint.sh`).
  - Verifies required files and structure.

- `test`  
  - Depends on `validate`.
  - Runs the test suite (`tests/test.sh`).
  - May run basic CLI smoke tests.

- `docker`  
  - Depends on `test`.
  - Builds the Docker image.
  - Runs smoke tests inside the container (e.g. `help`, `system-info`, invalid command).
  - Optionally pushes the image (if configured).

The workflow ensures that code changes are validated, tested, and containerized automatically.

***

## Exit code conventions

Across scripts and the CLI:

- `0` – success
- `1` – operational/runtime failure
- `2` – invalid command or invalid input (bad arguments, missing required arguments)

The grader and CI rely on these conventions to determine pass/fail status.

***

## Development workflow

1. Create a feature branch from `main` (or `master`):

   ```bash
   git checkout -b feature/your-feature
   ```

2. Make changes to `app/app.sh`, scripts, tests, Dockerfile, or workflow.
3. Run locally:

   ```bash
   ./scripts/lint.sh
   ./tests/test.sh
   docker build -t devops-ci-app .
   docker run --rm devops-ci-app help
   ```

4. Commit with meaningful messages and push:

   ```bash
   git add .
   git commit -m "Add check-port validation"
   git push origin feature/your-feature
   ```

5. Open a pull request. GitHub Actions will run the CI workflow automatically.

***

## Notes

- Ensure all scripts (`app/app.sh`, `scripts/lint.sh`, `scripts/build.sh`, `tests/test.sh`) are marked executable:

  ```bash
  chmod +x app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh
  ```

- `.dockerignore` should exclude unnecessary files such as `.git`, logs, and local temporary files to keep the image small.
- The CI workflow expects specific job names (`validate`, `test`, `docker`) and dependencies (`test` needs `validate`, `docker` needs `test`) as checked by the grader.