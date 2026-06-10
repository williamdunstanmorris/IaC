# In your Makefile
IMAGE=europe-west3-docker.pkg.dev/project-2b40a90c-1a89-477e-894/main/bluejay

push:
	docker buildx build --platform linux/amd64 -t $(IMAGE):v1.0.1 --push .