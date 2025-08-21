build:
	docker compose -f docker/docker-compose.yml build

up:
	docker compose -f docker/docker-compose.yml up -d

down:
	docker compose -f docker/docker-compose.yml down

logs:
	docker compose -f docker/docker-compose.yml logs -f

ssh-base:
	ssh developer@localhost -p 2220

ssh-project1:
	ssh developer@localhost -p 2221

ssh-project2:
	ssh developer@localhost -p 2222

ssh-playwright:
	ssh developer@localhost -p 2223

# Build and push base images to registry
build-base:
	docker build -t dev-base:latest docker/base-image
	docker build -t dev-playwright:latest docker/playwright-image

# Push to GitHub Container Registry (free)
push-ghcr:
	docker tag dev-base:latest ghcr.io/$(shell git config user.name)/dev-base:latest
	docker tag dev-playwright:latest ghcr.io/$(shell git config user.name)/dev-playwright:latest
	docker push ghcr.io/$(shell git config user.name)/dev-base:latest
	docker push ghcr.io/$(shell git config user.name)/dev-playwright:latest

# Setup local registry (alternative to GHCR)
setup-local-registry:
	docker run -d --name registry -p 5000:5000 registry:2

push-local:
	docker tag dev-base:latest localhost:5000/dev-base:latest
	docker tag dev-playwright:latest localhost:5000/dev-playwright:latest
	docker push localhost:5000/dev-base:latest
	docker push localhost:5000/dev-playwright:latest
