# 🚀 Node.js Express App --- Full CI/CD Pipeline

This project demonstrates a complete end-to-end CI/CD pipeline using:

-   **Node.js + Express**
-   **Docker & Docker Compose**
-   **GitHub Actions (Build & Push Docker Images)**
-   **Docker Hub (Image Registry)**
-   **Watchtower (Auto-deploy updated images)**

With this setup, every time you push changes to the `main` branch:

1.  GitHub Actions builds a new Docker image\
2.  The image is pushed to Docker Hub\
3.  Watchtower automatically updates the running container\
4.  Your app restarts with the new version automatically

------------------------------------------------------------------------

## 📁 Project Structure

    express-app/
    │
    ├── index.js
    ├── Dockerfile
    ├── docker-compose.yml
    └── .github/
        └── workflows/
            └── main.yml

------------------------------------------------------------------------

## 🛠️ 1. Application Code (index.js)

``` js
const express = require('express')
const app = express()

app.get('/', (req, res) => {
  res.send('<h1>Hello World!</h1>')
})

const PORT = 8080
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
```

------------------------------------------------------------------------

## 🐳 2. Dockerfile

``` dockerfile
FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8080

CMD ["node", "index.js"]
```

------------------------------------------------------------------------

## 🔧 3. Docker Compose (App + Watchtower)

``` yaml
services:
  nodeapp:
    image: YOUR_DOCKERHUB_USERNAME/node-express-app:latest
    container_name: nodeapp
    ports:
      - "8080:8080"
    restart: always

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WATCHTOWER_POLL_INTERVAL=60
    restart: always
```

Replace `YOUR_DOCKERHUB_USERNAME`.

------------------------------------------------------------------------

## 🔑 4. Add GitHub Secrets

Go to:

**Repository → Settings → Secrets and Variables → Actions**

Add:

  -----------------------------------------------------------------------
  Secret Name              Value
  ------------------------ ----------------------------------------------
  `DOCKERHUB_USERNAME`     Docker Hub username

  `DOCKERHUB_TOKEN`        Docker Hub Access Token
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## ⚙️ 5. GitHub Actions Workflow

``` yaml
name: Build and push Docker image

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to registry (Docker Hub)
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/node-express-app:latest,${{ secrets.DOCKERHUB_USERNAME }}/node-express-app:${{ github.sha }}
```

------------------------------------------------------------------------

## 🔄 6. Run Locally

``` bash
docker compose up -d
```

App: http://localhost:8080

------------------------------------------------------------------------

## 🚀 7. Test CI/CD

``` bash
git add .
git commit -m "update"
git push
```

Watchtower updates the container automatically.

------------------------------------------------------------------------

## ✔️ CI/CD Flow Summary

  Step   Action               Automated By
  ------ -------------------- ----------------
  1      Push code            You
  2      Build Docker image   GitHub Actions
  3      Push image           GitHub Actions
  4      Pull new image       Watchtower
  5      Restart container    Watchtower

------------------------------------------------------------------------
