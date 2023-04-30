include example.env

.PHONY: up
up:
	chmod +x scripts/run-docker.sh
	./scripts/run-docker.sh

.PHONY: down
down:
	docker stop my-postgres-container \
    && docker rm my-postgres-container \
    && docker rmi my-postgres-image

.PHONY: homework
homework: up
	chmod +x scripts/run-homework.sh
	./scripts/run-homework.sh