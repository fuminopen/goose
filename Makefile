.PHONY: up setup

up:
	docker compose -f ./documentation/docs/docker/docker-compose.yml run --rm goose-cli

setup:
	cp ./.env.example ./.env &&
	docker compose -f ./documentation/docs/docker/docker-compose.yml build
