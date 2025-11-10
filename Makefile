# Makefile for Forkmost

# Variables
REGISTRY ?= registry.gitlab.com
PROJECT_PATH ?= codemiproject/codemi-internal-tools/forkmost
TAG ?= latest
VERSION := $(shell node -p "require('./package.json').version")

# Full image reference
IMAGE := $(REGISTRY)/$(PROJECT_PATH)

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the Docker image
	@echo "Building Docker image: $(IMAGE):$(TAG)"
	docker build -t $(IMAGE):$(TAG) .

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
