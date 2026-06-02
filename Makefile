.PHONY: run test lint tidy clean build swagger migrate-up migrate-down migrate-create

APP_NAME := chirp
BACKEND_DIR := backend
GOENV := GOTMPDIR=/tmp/go-tmp GOCACHE=/tmp/go-cache GONOSUMCHECK='*'

## run: Start the development server
run:
	cd $(BACKEND_DIR) && $(GOENV) go run ./cmd/server/

## test: Run all tests
test:
	cd $(BACKEND_DIR) && go test -v -race -count=1 ./...

## lint: Run golangci-lint
lint:
	cd $(BACKEND_DIR) && golangci-lint run ./...

## clean: Remove build artifacts
clean:
	cd $(BACKEND_DIR) && go clean

## tidy: Tidy Go modules
tidy:
	cd $(BACKEND_DIR) && $(GOENV) go mod tidy

## swagger: Generate OpenAPI docs from source annotations
swagger:
	cd $(BACKEND_DIR) && mkdir -p /tmp/go-tmp /tmp/go-cache && $(GOENV) go run github.com/swaggo/swag/cmd/swag@v1.16.4 init -g cmd/server/main.go -o docs --parseDependency --parseInternal

## build: Build the binary
build:
	cd $(BACKEND_DIR) && mkdir -p /tmp/go-tmp /tmp/go-cache && $(GOENV) go build -o bin/$(APP_NAME) ./cmd/server/

## migrate-up: Run all pending migrations
migrate-up:
	cd $(BACKEND_DIR) && migrate -path migrations -database "$(DATABASE_URL)" up

## migrate-down: Roll back the last migration
migrate-down:
	cd $(BACKEND_DIR) && migrate -path migrations -database "$(DATABASE_URL)" down 1

## migrate-create: Create a new migration file (usage: make migrate-create NAME=add_users)
migrate-create:
	cd $(BACKEND_DIR) && migrate create -ext sql -dir migrations -seq $(NAME)
