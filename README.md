# clock-app

## File Structure
```
clock-app/
├── .github/
│   └── workflows/
│       └── deploy.yml           # CI/CD pipeline
├── scripts/
│   └── setup-ec2.sh            # EC2 setup script
├── terraform/                   # Optional IaC
│   ├── main.tf
│   └── variables.tf
├── index.html                   # Your app
├── style.css                    # Your styles
├── Dockerfile                   # Docker image definition
├── nginx.conf                   # Nginx configuration
├── .dockerignore               # Docker ignore rules
└── README.md                    # Documentation
```
## How this workflows behaves
```
| Action             | Build | Staging | Prod |
| ------------------ | ----- | ------- | ---- |
| Push to `develop`  | ✅     | ✅       | ❌    |
| Push to `main`     | ✅     | ❌       | ✅    |
| Tag `v1.0.0`       | ✅     | ❌       | ✅    |
| README-only change | ❌     | ❌       | ❌    |
```

