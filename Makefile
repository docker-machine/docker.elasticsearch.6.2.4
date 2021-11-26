# The running the containers of the docker compose.
.PHONY: run
run:
	docker-compose -p docker-elasticsearch624 -f docker-compose.yaml up -d

# The stopped the containers of the docker compose.
.PHONY: stop
stop:
	docker-compose -p docker-elasticsearch624 -f docker-compose.yaml down