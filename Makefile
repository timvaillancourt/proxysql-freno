all:
	docker-compose build
	docker-compose up -d

logs:
	docker-compose logs -f

clean:
	docker-compose down -v
