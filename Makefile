all:
	docker-compose up --build -d

clean:
	docker-compose down -v
