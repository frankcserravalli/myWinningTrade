help:
	@echo "make build: Builds the project."
	@echo "make up: Starts the project's server"
	@echo "make con: Starts the project's console server"
	@echo "make migrate: Executes db migration process"
	@echo "make migrate: Executes db migration process on Test Env"
	@echo "make db-setup: Executes db setup process"
	@echo "make test-db-setup: Executes db setup process on Test Env"
	@echo "make db-create: Creates the database"
	@echo "make test-db-create: Creates the database on Test Env"
	@echo "make testit: Runs all tests"

build:
	docker-compose build

up:
	docker-compose up

con:
	docker-compose run --rm web rails c

migrate:
	docker-compose run --rm	web	rake db:migrate

migrate-test:
	docker-compose run -e RAILS_ENV=test --rm	web	rake db:migrate

db-setup:
	docker-compose run --rm	web	rake db:setup

test-db-setup:
	docker-compose run -e RAILS_ENV=test --rm	web	rake db:setup

db-create:
	docker-compose run --rm web rake db:create

test-db-create:
	docker-compose run -e RAILS_ENV=test --rm web rake db:create

testit:
	docker-compose run --rm web rspec 
