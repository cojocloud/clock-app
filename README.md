# 🕒 Clock App

A simple, visually appealing **web-based clock application** with analog and digital display.
This project is Dockerized and can be deployed to **Ubuntu EC2 with Nginx** using a fully automated GitHub Actions CI/CD pipeline.

# CI/CD Deployment Flow
```
    A[Commit / Tag] --> [GitHub Actions Workflow]
    B --> [Build Docker Image]
    C --> {Branch / Tag?}
    D -->|develop| [Push Docker Image:develop]
    D -->|main| F[Push Docker Image:latest]
    D -->|vX.Y.Z tag| [Push Docker Image:vX.Y.Z, vX.Y, vX, latest]
    E --> [Staging EC2 via SSH]
    F --> [Production EC2 via SSH]
    G --> I
    H --> [Run container, Nginx already configured]
    I --> [Run container, Nginx already configured]
    J --> [App accessible at staging URL]
    K --> [App accessible at production URL]
```

## How it works:

Commits / tags trigger the workflow

Docker images are built with semantic versioning

Deployment happens via SSH to EC2

Nginx is already configured by setup-ec2.sh

Staging and production environments are separate

## File Structure
```
clock-app/
├── .github/
│   └── workflows/
│       └── deploy.yml       # CI/CD workflow
├── scripts/
│   └── setup-ec2.sh         # EC2 setup (Docker + Nginx)
├── terraform/                # Optional IaC
│   ├── main.tf
│   └── variables.tf
├── index.html                # Clock app HTML
├── style.css                 # Clock CSS
├── Dockerfile                # Docker image definition
├── .dockerignore             # Files to ignore for Docker build
└── README.md                 # Project documentation
```

# Features

- Real-time analog and digital clock

- Styled with modern CSS effects

- Dockerized for easy deployment

- Semantic versioning for Docker images (v1.0.0, v1.0, v1, latest)

- Automated staging & production deployment via GitHub Actions

- Minimal dependencies — no Java, Maven, or Node required


## Setup & Deployment
EC2 Preparation (one-time)

Run once per EC2 instance to install Docker and Nginx:

```
ssh ubuntu@<EC2_PUBLIC_IP>
chmod +x scripts/setup-ec2.sh
./scripts/setup-ec2.sh
```
- Installs Docker, Docker Compose, and Nginx

- Configures firewall and log rotation

- Prepares instance for CI/CD deployments

## GitHub Secrets

Add the following secrets to your repository:

```
| Secret               | Purpose                  |
| -------------------- | ------------------------ |
| `DOCKERHUB_USERNAME` | Docker Hub username      |
| `DOCKERHUB_TOKEN`    | Docker Hub access token  |
| `EC2_HOST`           | Production EC2 public IP |
| `EC2_STAGING_HOST`   | Staging EC2 public IP    |
| `EC2_USER`           | EC2 SSH user (`ubuntu`)  |
| `EC2_SSH_KEY`        | SSH private key for EC2  |

```

## Workflow Trigger

- Develop branch → builds image (develop) → deploys to staging EC2

- Main branch → builds image (latest) → deploys to production EC2

- Tag vX.Y.Z → builds semantic versioned images → deploys to production EC2

- README-only updates do not trigger workflow

## Docker Image Tags
```
Git Event              |       Docker tag
---------------------------------------------------------------------
Push develop           | clock-app:develop    

Push main              | clock-app:latest

Tag v1.0.0             | clock-app:v1.0.0, clock-app:v1.0, clock-app:v1, 
clock-app:latest
--------------------------------------------------------------------------
```


## Manual Deployment (Optional)

If needed, manually pull and run the Docker image on EC2:

```
docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_TOKEN
docker pull clock-app:latest
docker stop clock-app || true
docker rm clock-app || true
docker run -d --name clock-app -p 8080:80 clock-app:latest
```
## Usage

Visit your EC2 public IP in a browser:
```
http://<EC2_PUBLIC_IP>
```
- Analog and digital clock should display in real-time

- Styling handled by CSS only, no JavaScript frameworks required

## Development

- Modify index.html or style.css locally

- Commit changes to develop → workflow builds Docker image and deploys to staging

- Merge to main or create a tag vX.Y.Z → production deploy

# Docker

## Build locally (optional):
```
docker build -t clock-app:local .
docker run -d -p 8080:80 clock-app:local
```

- The app runs in Nginx inside Docker

- Port 8080 mapped to host


## Future Enhancements

- HTTPS with Let’s Encrypt

- Blue/green or canary deployments

- Health checks and monitoring endpoints

- Multiple app support on same EC2

