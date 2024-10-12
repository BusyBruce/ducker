.DEFAULT_GOAL := run

DUCKDB_VERSION=v1.1.1
EXTENSIONS="fts httpfs icu json parquet mysql postgres sqlite substrait iceberg arrow spatial"
COMMUNITY_EXTENSIONS="prql scrooge evalexpr_rhai"
IMAGE_NAME := flyskype2021/ducker:$(DUCKDB_VERSION)
LATEST_IMAGE_NAME := flyskype2021/ducker:latest

build:
	@docker build \
		--build-arg DUCKDB_VERSION=$(DUCKDB_VERSION) \
		--build-arg EXTENSIONS=$(EXTENSIONS) \
                --build-arg COMMUNITY_EXTENSIONS=$(COMMUNITY_EXTENSIONS) \
		-t $(IMAGE_NAME) \
		-t $(LATEST_IMAGE_NAME) \
		.

run:
	@docker run --rm -it $(IMAGE_NAME)

push: build
	docker push $(IMAGE_NAME)
	docker push $(LATEST_IMAGE_NAME)
