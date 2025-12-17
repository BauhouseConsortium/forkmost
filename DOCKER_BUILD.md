# Docker Build Guide

This guide explains how to build Docker images for Linux deployment, especially when building from macOS (ARM64).

## Problem

When building Docker images on macOS (Apple Silicon/ARM64) and deploying to Linux servers (AMD64), you may encounter:

```
exec /usr/local/bin/docker-entrypoint.sh: exec format error
```

This happens because the image was built for the wrong CPU architecture.

## Solution

Use Docker Buildx to build images for the correct platform (Linux AMD64).

## Quick Start

### Using Make (Recommended)

```bash
# Build for Linux AMD64 (default)
make build

# Push to GitLab registry
make login
make push

# Build and push both latest and version tags
make build-push-all

# Build and push multi-platform image (AMD64 + ARM64)
make build-multiplatform
```

### Using Docker Buildx Directly

```bash
# Build for Linux AMD64
docker buildx build --platform linux/amd64 -t registry.gitlab.com/codemiproject/codemi-internal-tools/forkmost:latest --load .

# Build and push multi-platform
docker buildx build --platform linux/amd64,linux/arm64 -t registry.gitlab.com/codemiproject/codemi-internal-tools/forkmost:latest --push .
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make build` | Build Docker image for Linux AMD64 |
| `make push` | Push image to GitLab registry |
| `make build-push` | Build and push image |
| `make build-push-all` | Build and push both latest and version tags |
| `make build-multiplatform` | Build and push multi-platform image (AMD64 + ARM64) |
| `make login` | Login to GitLab container registry |
| `make tag-version` | Tag image with version from package.json |
| `make clean` | Remove local Docker images |
| `make info` | Display build configuration |

## Configuration Variables

You can override these variables when running make:

```bash
# Custom registry
REGISTRY=docker.io make build

# Custom project path
PROJECT_PATH=myorg/myapp make build

# Custom tag
TAG=v1.2.3 make build

# Custom platform
PLATFORM=linux/arm64 make build
```

### Example: Build for custom registry

```bash
REGISTRY=docker.io PROJECT_PATH=myusername/forkmost TAG=dev make build
```

## Docker Compose

The `docker-compose.yml` file now includes platform specification:

```yaml
services:
  forkmost:
    image: ghcr.io/vito0912/forkmost:latest
    platform: linux/amd64  # Ensures Linux AMD64 is used
```

This ensures the correct architecture is used even when pulling pre-built images.

## Prerequisites

### 1. Enable Docker Buildx

Docker Buildx should be available by default on Docker Desktop. Verify:

```bash
docker buildx version
```

### 2. Create a builder instance (optional)

For multi-platform builds:

```bash
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap
```

## Common Scenarios

### Scenario 1: Local Development on Mac, Deploy to Linux

```bash
# Build for Linux AMD64
make build

# Push to registry
make login
make push
```

### Scenario 2: CI/CD Pipeline

In your GitLab CI or GitHub Actions:

```yaml
# .gitlab-ci.yml
build:
  script:
    - make build
    - make push
```

### Scenario 3: Multi-Platform Support

For supporting both AMD64 and ARM64 servers:

```bash
# Build and push for both platforms
make build-multiplatform
```

## Troubleshooting

### Error: "exec format error"

**Cause**: Running an image built for wrong CPU architecture

**Solution**:
1. Rebuild with correct platform: `make build`
2. Or specify platform in docker-compose.yml (already done)

### Error: "multiple platforms feature is currently not supported"

**Cause**: Docker Buildx not enabled or old Docker version

**Solution**:
- Update Docker Desktop to latest version
- Or use `--load` flag for single platform builds (already in Makefile)

### Error: "failed to solve with frontend dockerfile.v0"

**Cause**: Buildx trying to push multi-platform but no registry specified

**Solution**:
- For local builds: Use `make build` (uses `--load`)
- For multi-platform: Use `make build-multiplatform` (uses `--push`)

## Build Process Flow

1. **Base Stage**: Uses `node:22-alpine` as foundation
2. **Builder Stage**:
   - Installs dependencies
   - Runs branding script (if prebuild hook is configured)
   - Builds application with `pnpm build`
3. **Installer Stage**:
   - Copies built artifacts
   - Installs production dependencies only
   - Sets up volumes and permissions

## Platform Details

- **Default Platform**: `linux/amd64` (most common for Linux servers)
- **Multi-platform**: `linux/amd64,linux/arm64` (supports both Intel/AMD and ARM servers)
- **Mac Native**: `linux/arm64` (Apple Silicon)

## Registry Configuration

### GitLab Container Registry

```bash
# Login
make login
# or
docker login registry.gitlab.com

# Build and push
make build-push-all
```

### Docker Hub

```bash
REGISTRY=docker.io PROJECT_PATH=username/forkmost make build push
```

### GitHub Container Registry

```bash
REGISTRY=ghcr.io PROJECT_PATH=username/forkmost make build push
```

## Best Practices

1. **Always specify platform** when building for deployment
2. **Test locally** with `docker-compose.yml` before pushing
3. **Use version tags** for production deployments
4. **Build multi-platform images** if deploying to different architectures
5. **Use make targets** instead of raw docker commands for consistency

## References

- [Docker Buildx Documentation](https://docs.docker.com/buildx/working-with-buildx/)
- [Multi-platform Images](https://docs.docker.com/build/building/multi-platform/)
- [Docker Compose Platform](https://docs.docker.com/compose/compose-file/compose-file-v3/#platform)
