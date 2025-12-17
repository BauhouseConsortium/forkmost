# Makefile for Forkmost

# Variables
REGISTRY ?= registry.gitlab.com
PROJECT_PATH ?= bauhouseconsortium/forkmost
TAG ?= latest
VERSION := $(shell node -p "require('./package.json').version")
PLATFORM ?= linux/amd64

# Full image reference
IMAGE := $(REGISTRY)/$(PROJECT_PATH)

# GitHub Container Registry
GHCR_REGISTRY := ghcr.io
GHCR_ORG := bauhouseconsortium
GHCR_REPO := forkmost
GHCR_IMAGE := $(GHCR_REGISTRY)/$(GHCR_ORG)/$(GHCR_REPO)

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the Docker image for Linux AMD64
	@echo "Building Docker image: $(IMAGE):$(TAG) for $(PLATFORM)"
	docker buildx build --platform $(PLATFORM) -t $(IMAGE):$(TAG) --load .

.PHONY: push
push: ## Push the Docker image to GitLab registry
	@echo "Pushing Docker image: $(IMAGE):$(TAG)"
	docker push $(IMAGE):$(TAG)

.PHONY: build-push
build-push: build push ## Build and push the Docker image to GitLab registry

.PHONY: login
login: ## Login to GitLab container registry
	@echo "Logging in to $(REGISTRY)"
	@docker login $(REGISTRY)

.PHONY: tag-version
tag-version: ## Tag the image with version from package.json
	@echo "Tagging image with version: $(VERSION)"
	docker tag $(IMAGE):$(TAG) $(IMAGE):$(VERSION)

.PHONY: push-version
push-version: tag-version ## Push version-tagged image to registry
	@echo "Pushing version-tagged image: $(IMAGE):$(VERSION)"
	docker push $(IMAGE):$(VERSION)

.PHONY: build-push-all
build-push-all: build push push-version ## Build and push both latest and version-tagged images

.PHONY: build-multiplatform
build-multiplatform: ## Build and push multi-platform image (AMD64 + ARM64)
	@echo "Building multi-platform Docker image: $(IMAGE):$(TAG)"
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE):$(TAG) --push .
	@echo "Building multi-platform version tag: $(IMAGE):$(VERSION)"
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE):$(VERSION) --push .

.PHONY: clean
clean: ## Remove local Docker images
	@echo "Removing local images"
	-docker rmi $(IMAGE):$(TAG)
	-docker rmi $(IMAGE):$(VERSION)

.PHONY: info
info: ## Display build information
	@echo "Registry:      $(REGISTRY)"
	@echo "Project Path:  $(PROJECT_PATH)"
	@echo "Full Image:    $(IMAGE)"
	@echo "Tag:           $(TAG)"
	@echo "Version:       $(VERSION)"
	@echo "Platform:      $(PLATFORM)"
	@echo ""
	@echo "GitHub Container Registry:"
	@echo "GHCR Image:    $(GHCR_IMAGE)"

# GitHub Container Registry targets
.PHONY: ghcr-login
ghcr-login: ## Login to GitHub Container Registry
	@echo "Logging in to $(GHCR_REGISTRY)"
	@docker login $(GHCR_REGISTRY)

.PHONY: ghcr-build
ghcr-build: ## Build the Docker image for GitHub Container Registry
	@echo "Building Docker image: $(GHCR_IMAGE):$(TAG) for $(PLATFORM)"
	docker buildx build --platform $(PLATFORM) -t $(GHCR_IMAGE):$(TAG) --load .

.PHONY: ghcr-push
ghcr-push: ## Push the Docker image to GitHub Container Registry
	@echo "Pushing Docker image: $(GHCR_IMAGE):$(TAG)"
	docker push $(GHCR_IMAGE):$(TAG)

.PHONY: ghcr-build-push
ghcr-build-push: ghcr-build ghcr-push ## Build and push the Docker image to GitHub Container Registry

.PHONY: ghcr-tag-version
ghcr-tag-version: ## Tag the image with version from package.json for GHCR
	@echo "Tagging image with version: $(VERSION)"
	docker tag $(GHCR_IMAGE):$(TAG) $(GHCR_IMAGE):$(VERSION)

.PHONY: ghcr-push-version
ghcr-push-version: ghcr-tag-version ## Push version-tagged image to GitHub Container Registry
	@echo "Pushing version-tagged image: $(GHCR_IMAGE):$(VERSION)"
	docker push $(GHCR_IMAGE):$(VERSION)

.PHONY: ghcr-build-push-all
ghcr-build-push-all: ghcr-build ghcr-push ghcr-push-version ## Build and push both latest and version-tagged images to GHCR

.PHONY: ghcr-multiplatform
ghcr-multiplatform: ## Build and push multi-platform image to GHCR (AMD64 + ARM64)
	@echo "Building multi-platform Docker image: $(GHCR_IMAGE):$(TAG)"
	docker buildx build --platform linux/amd64,linux/arm64 -t $(GHCR_IMAGE):$(TAG) --push .
	@echo "Building multi-platform version tag: $(GHCR_IMAGE):$(VERSION)"
	docker buildx build --platform linux/amd64,linux/arm64 -t $(GHCR_IMAGE):$(VERSION) --push .
