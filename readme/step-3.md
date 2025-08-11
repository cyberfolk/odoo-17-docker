# Migrazione a Step 3 (HA/Scalabilità)

- **EFS** per filestore condiviso (o S3 + modulo)
- **ALB** + 2+ istanze Odoo (ECS/Fargate o più EC2)
- **Observability**: CloudWatch Logs/metrics, o stack ELK; healthcheck ALB
- **Deploy**: GitHub Actions → ECR → ECS roll‑out