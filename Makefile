cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build_ui: ## Build ui
	cd src/ui && bash docker_build.sh

build_comment: ## Build comment
	cd src/comment && bash docker_build.sh

build_post: ## Build post
	cd src/post-py && bash docker_build.sh

build_prometheus: ## Build prometheus
	docker build -t $(USER_NAME)/prometheus:$(DOCKER_TAG) monitoring/prometheus

build_mongodb_exporter: ## Build mongodb_exporter
	docker build -t $(USER_NAME)/mongodb_exporter:$(DOCKER_TAG) monitoring/mongodb_exporter

build_blackbox_exporter: ## Build blackbox_exporter
	docker build -t $(USER_NAME)/blackbox_exporter:$(DOCKER_TAG) monitoring/blackbox_exporter

build_alertmanager: ## Build alertmanager
	docker build -t $(USER_NAME)/prometheus:$(DOCKER_TAG) monitoring/alertmanager

build_all: build_ui build_comment build_post build_prometheus build_mongodb_exporter build_blackbox_exporter build_alertmanager ## Build all images

publish_ui: ## Publish ui image
	docker push $(USER_NAME)/ui:$(DOCKER_TAG)

publish_comment: ## Publish comment image
	docker push $(USER_NAME)/comment:$(DOCKER_TAG)

publish_post: ## Publish post image
	docker push $(USER_NAME)/post:$(DOCKER_TAG)

publish_prometheus: ## Publish prometheus image
	docker push $(USER_NAME)/prometheus:$(DOCKER_TAG)

publish_mongodb_exporter: ## Publish mongodb_exporter image
	docker push $(USER_NAME)/mongodb_exporter:$(DOCKER_TAG)

publish_blackbox_exporter: ## Publish blackbox_exporter image
	docker push $(USER_NAME)/blackbox_exporter:$(DOCKER_TAG)

publish_alertmanager: ## Publish alertmanager image
	docker push $(USER_NAME)/alertmanager:$(DOCKER_TAG)

# Docker publish
publish_all: publish_ui publish_comment publish_post publish_prometheus publish_mongodb_exporter publish_blackbox_exporter publish_alertmanager ## Publish all images
