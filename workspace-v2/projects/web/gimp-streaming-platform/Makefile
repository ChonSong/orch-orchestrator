# GIMP Streaming Platform Makefile
# Provides commands for building, testing, and deploying the platform

.PHONY: help build test clean dev deploy lint format docker-build k8s-deploy

# Default target
help:
	@echo "GIMP Streaming Platform - Available Commands:"
	@echo ""
	@echo "Build & Development:"
	@echo "  build          - Build all services and frontend"
	@echo "  dev            - Start development environment"
	@echo "  test           - Run all tests"
	@echo "  lint           - Run linting on all services"
	@echo "  format         - Format code across all services"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build   - Build all Docker images"
	@echo "  docker-push    - Push images to registry"
	@echo "  docker-clean   - Clean Docker images and containers"
	@echo ""
	@echo "Kubernetes:"
	@echo "  k8s-deploy     - Deploy to Kubernetes"
	@echo "  k8s-delete     - Delete Kubernetes deployment"
	@echo "  k8s-status     - Check deployment status"
	@echo ""
	@echo "Database:"
	@echo "  db-migrate     - Run database migrations"
	@echo "  db-seed        - Seed database with test data"
	@echo "  db-reset       - Reset database"
	@echo ""
	@echo "Utilities:"
	@echo "  clean          - Clean build artifacts"
	@echo "  install-deps   - Install all dependencies"
	@echo "  generate-ssl   - Generate SSL certificates"

# Configuration
DOCKER_REGISTRY ?= your-registry.com
IMAGE_TAG ?= latest
K8S_NAMESPACE ?= gimp-streaming

# Build & Development Commands
build: build-backend build-frontend

install-deps:
	@echo "Installing dependencies..."
	cd src/services/auth-service && go mod download
	cd src/services/session-manager && go mod download
	cd src/services/storage-service && go mod download
	cd src/services/billing-service && go mod download
	cd src/frontend/web-client && npm install
	cd src/frontend/dashboard && npm install
	cd src/frontend/admin-panel && npm install

build-backend:
	@echo "Building backend services..."
	cd src/services/auth-service && go build -o ../../bin/auth-service ./cmd/main.go
	cd src/services/session-manager && go build -o ../../bin/session-manager ./cmd/main.go
	cd src/services/storage-service && go build -o ../../bin/storage-service ./cmd/main.go
	cd src/services/billing-service && go build -o ../../bin/billing-service ./cmd/main.go

build-frontend:
	@echo "Building frontend applications..."
	cd src/frontend/web-client && npm run build
	cd src/frontend/dashboard && npm run build
	cd src/frontend/admin-panel && npm run build

dev:
	@echo "Starting development environment..."
	docker-compose -f docker-compose.dev.yml up -d
	@echo "Development environment started!"
	@echo "Frontend: http://localhost:3000"
	@echo "API: http://localhost:8080"
	@echo "Admin: http://localhost:3001"

test:
	@echo "Running all tests..."
	cd src/services/auth-service && go test ./...
	cd src/services/session-manager && go test ./...
	cd src/services/storage-service && go test ./...
	cd src/services/billing-service && go test ./...
	cd src/frontend/web-client && npm test
	cd src/frontend/dashboard && npm test
	cd src/frontend/admin-panel && npm test

lint:
	@echo "Running linters..."
	cd src/services/auth-service && golangci-lint run
	cd src/services/session-manager && golangci-lint run
	cd src/services/storage-service && golangci-lint run
	cd src/services/billing-service && golangci-lint run
	cd src/frontend/web-client && npm run lint
	cd src/frontend/dashboard && npm run lint
	cd src/frontend/admin-panel && npm run lint

format:
	@echo "Formatting code..."
	cd src/services/auth-service && go fmt ./...
	cd src/services/session-manager && go fmt ./...
	cd src/services/storage-service && go fmt ./...
	cd src/services/billing-service && go fmt ./...
	cd src/frontend/web-client && npm run format
	cd src/frontend/dashboard && npm run format
	cd src/frontend/admin-panel && npm run format

# Docker Commands
docker-build:
	@echo "Building Docker images..."
	docker build -t $(DOCKER_REGISTRY)/gimp:$(IMAGE_TAG) -f docker/gimp/Dockerfile .
	docker build -t $(DOCKER_REGISTRY)/streaming-server:$(IMAGE_TAG) -f docker/streaming-server/Dockerfile .
	docker build -t $(DOCKER_REGISTRY)/auth-service:$(IMAGE_TAG) -f docker/auth/Dockerfile src/services/auth-service
	docker build -t $(DOCKER_REGISTRY)/session-manager:$(IMAGE_TAG) -f docker/session-manager/Dockerfile src/services/session-manager
	docker build -t $(DOCKER_REGISTRY)/storage-service:$(IMAGE_TAG) -f docker/storage/Dockerfile src/services/storage-service
	docker build -t $(DOCKER_REGISTRY)/billing-service:$(IMAGE_TAG) -f docker/billing/Dockerfile src/services/billing-service
	docker build -t $(DOCKER_REGISTRY)/web-client:$(IMAGE_TAG) -f docker/frontend/Dockerfile src/frontend/web-client
	docker build -t $(DOCKER_REGISTRY)/dashboard:$(IMAGE_TAG) -f docker/dashboard/Dockerfile src/frontend/dashboard
	docker build -t $(DOCKER_REGISTRY)/admin-panel:$(IMAGE_TAG) -f docker/admin-panel/Dockerfile src/frontend/admin-panel

docker-push:
	@echo "Pushing Docker images..."
	docker push $(DOCKER_REGISTRY)/gimp:$(IMAGE_TAG)
	docker push $(DOCKER_REGISTRY)/streaming-server:$(IMAGE_TAG)
	docker push $(DOCKER_REGISTRY)/auth-service:$(IMAGE_TAG)
	docker push $(DOCKER_REGISTRY)/session-manager:$(IMAGE_TAG)
	docker push $(DOCKER_REGISTRY)/storage-service:$(IMAGE_TAG)
	docker push $(DOCKER_REGISTRY)/billing-service:$(IMAGE_TAG)
	docker push $(DOCKER_REGISTRY)/web-client:$(IMAGE_TAG)
	docker push $(DOCKER_REGISTRY)/dashboard:$(IMAGE_TAG)
	docker push $(DOCKER_REGISTRY)/admin-panel:$(IMAGE_TAG)

docker-clean:
	@echo "Cleaning Docker images..."
	docker system prune -f
	docker volume prune -f

# Kubernetes Commands
k8s-deploy:
	@echo "Deploying to Kubernetes..."
	kubectl apply -f deployments/manifests/namespace.yaml
	kubectl apply -f deployments/manifests/configmaps/
	kubectl apply -f deployments/manifests/secrets/
	helm install gimp-streaming deployments/kubernetes/helm-charts/gimp-streaming/ \
		--namespace $(K8S_NAMESPACE) \
		--set image.tag=$(IMAGE_TAG) \
		--set registry=$(DOCKER_REGISTRY)

k8s-delete:
	@echo "Deleting Kubernetes deployment..."
	helm uninstall gimp-streaming --namespace $(K8S_NAMESPACE) || true
	kubectl delete namespace $(K8S_NAMESPACE) || true

k8s-status:
	@echo "Checking deployment status..."
	kubectl get pods -n $(K8S_NAMESPACE)
	kubectl get services -n $(K8S_NAMESPACE)
	kubectl get ingress -n $(K8S_NAMESPACE)

# Database Commands
db-migrate:
	@echo "Running database migrations..."
	cd src/backend/database && go run cmd/migrate/main.go up

db-seed:
	@echo "Seeding database..."
	cd src/backend/database && go run cmd/seed/main.go

db-reset:
	@echo "Resetting database..."
	cd src/backend/database && go run cmd/migrate/main.go down
	cd src/backend/database && go run cmd/migrate/main.go up
	cd src/backend/database && go run cmd/seed/main.go

# Utility Commands
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	rm -rf src/frontend/*/dist/
	rm -rf src/frontend/*/node_modules/
	rm -f docker-compose.override.yml

generate-ssl:
	@echo "Generating SSL certificates..."
	mkdir -p config/ssl
	openssl req -x509 -newkey rsa:4096 -keyout config/ssl/key.pem -out config/ssl/cert.pem -days 365 -nodes \
		-subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Environment Setup
setup-dev:
	@echo "Setting up development environment..."
	cp .env.example .env
	$(MAKE) install-deps
	$(MAKE) generate-ssl
	@echo "Development environment setup complete!"
	@echo "Please edit .env file with your configuration"

# CI/CD Commands
ci-test:
	@echo "Running CI tests..."
	$(MAKE) lint
	$(MAKE) test

ci-build:
	@echo "Running CI build..."
	$(MAKE) build
	$(MAKE) docker-build

ci-deploy-staging:
	@echo "Deploying to staging..."
	$(MAKE) docker-build
	$(MAKE) k8s-deploy K8S_NAMESPACE=gimp-streaming-staging

ci-deploy-production:
	@echo "Deploying to production..."
	$(MAKE) docker-build
	$(MAKE) docker-push
	$(MAKE) k8s-deploy K8S_NAMESPACE=gimp-streaming

# Monitoring Commands
logs:
	kubectl logs -f -n $(K8S_NAMESPACE) deployment/auth-service

monitor:
	kubectl top pods -n $(K8S_NAMESPACE)
	kubectl top nodes

# Backup Commands
backup-db:
	@echo "Creating database backup..."
	kubectl exec -n $(K8S_NAMESPACE) deployment/postgres -- pg_dump gimp_streaming > backup_$(shell date +%Y%m%d_%H%M%S).sql

restore-db:
	@echo "Restoring database from backup..."
	@read -p "Enter backup file path: " backup_file; \
	kubectl exec -i -n $(K8S_NAMESPACE) deployment/postgres -- psql gimp_streaming < $$backup_file