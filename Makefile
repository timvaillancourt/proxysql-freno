all:
	docker-compose up --build -d

logs:
	docker-compose logs -f

clean:
	docker-compose down -v
