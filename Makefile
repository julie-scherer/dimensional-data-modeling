CONTAINER_NAME=my-postgres-container

.PHONY: up
up:
	chmod +x setup.sh 
	/bin/bash setup.sh

.PHONY: start
start:
	docker start ${CONTAINER_NAME}
	docker exec -it ${CONTAINER_NAME} psql -U postgres

.PHONY: down
down:
	docker stop ${CONTAINER_NAME}
	docker rm ${CONTAINER_NAME}
	docker rmi postgres
