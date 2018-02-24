cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


build_prometheus: ## Build prometheus
	docker build -t $(USER_NAME)/prometheus:$(DOCKER_TAG) monitoring/prometheus

build_mongodb_exporter: ## Build mongodb_exporter
	docker build -t $(USER_NAME)/mongodb_exporter:$(DOCKER_TAG) monitoring/mongodb_exporter

build_blackbox_exporter: ## Build blackbox_exporter
	docker build -t $(USER_NAME)/blackbox_exporter:$(DOCKER_TAG) monitoring/blackbox_exporter

build_all: build_prometheus build_mongodb_exporter build_blackbox_exporter ## Build all images

publish_prometheus: ## Publish prometheus image
	docker push $(USER_NAME)/prometheus:$(DOCKER_TAG)

publish_mongodb_exporter: ## Publish mongodb_exporter image
	docker push $(USER_NAME)/mongodb_exporter:$(DOCKER_TAG)

publish_blackbox_exporter: ## Publish blackbox_exporter image
	docker push $(USER_NAME)/blackbox_exporter:$(DOCKER_TAG)

# Docker publish
publish_all: publish_prometheus publish_mongodb_exporter publish_blackbox_exporter ## Publish all images
