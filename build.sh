#!/bin/sh
set -e

# Step 1: Install Node.js dependencies and build the Vue/Vite frontend
echo "==> Installing frontend dependencies..."
cd web
npm install -g pnpm@10
pnpm install --frozen-lockfile --shamefully-hoist

echo "==> Building frontend..."
pnpm run build:prod

# Step 2: Copy the built frontend assets into static/secure/
echo "==> Copying frontend build output to static/secure/..."
cd ..
mkdir -p static/secure
cp -r web/dist/. static/secure/

echo "==> Frontend build complete."

# Step 3: Build the Go application
echo "==> Building Go application..."
MODULE_PATH=$(go list -m)
CGO_ENABLED=0 go build -trimpath \
  -ldflags="-X '${MODULE_PATH}/app.Version=${VERSION:-unknown}' -s -w -buildid=" \
  -o bepusdt ./main

echo "==> Build complete."
