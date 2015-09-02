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
	@echo "make devise: Installs devise"
	@echo "make routes: Gets application routes"
	@echo "make annotate: Creates annotations for models"
	@echo "make run-dev: Debugging Environment"

build:
	docker-compose build

no-cahe-build:
	docker-compose build --no-cache

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

devise:
	docker-compose run --rm web rails g devise:install

devise-users:
	docker-compose run --rm	web rails g devise user

devise-views:
	docker-compose run --rm	web rails g devise:views

routes:
	docker-compose run --rm web rake routes

annotate:
	docker-compose run --rm web annotate

run-dev:
	docker-compose run --rm --service-ports web

clean-assets:
	docker-compose run --rm web rake assets:clean

precompile-assets:
	docker-compose run --rm web rake assets:precompile

precompile-assets-dev:
	docker-compose run -e RAILS_ENV=development --rm web rake assets:precompile
