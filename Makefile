.PHONY: up
up:
	chmod +x setup.sh 
	/bin/bash setup.sh

.PHONY: run
run:
	docker exec -it my-postgres-container psql -U postgres

.PHONY: start
start:
	docker start my-postgres-container

.PHONY: stop
stop:
	docker stop my-postgres-container

.PHONY: logs
logs:
	docker logs my-postgres-container

.PHONY: down
down:
	docker rm my-postgres-container
