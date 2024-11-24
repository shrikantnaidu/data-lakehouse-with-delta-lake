build:
	docker compose build
	
up:
	docker compose up -d

down:
	docker compose down	

restart:
	make down && make up

copy_jars:
	./update_jars.sh

