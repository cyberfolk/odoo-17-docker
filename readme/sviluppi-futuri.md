# Sviluppi Futuri — Roadmap Didattica (incrementale)

> Questo progetto è un percorso di apprendimento a step brevi e verificabili.

---

## 🔎 Mappa rapida

- ✅  **Step 1** → HTTPS facile con **Caddy** (gratis, veloce).
- 📝  **Step 2** → Alternativa: **Nginx + Certbot**.
- 📝  **Step 3** → **Secrets** da **AWS SSM/Secrets Manager** via `entrypoint`.
- 📝  **Step 4** → **Backup & Log** di base.
- 📝  **Step 5** → (?) **RDS Postgres**.
- 📝  **Step 6** → **CI/CD** (GitHub Actions → build & deploy).
- 📝  **Step 7** → (?) **HA/Scalabilità** (ALB, 2+ app, EFS/S3, osservabilità).

---

## ✅ Step 1 — HTTPS in 15 minuti (Caddy, budget ~0€)

**Learn**: reverse proxy, terminazione TLS, rete Docker.  
**Prerequisiti**: subdominio (es. `duckdns.org`).

### **Passaggi**

- Aggiungi **Caddy** al `docker-compose` come reverse proxy.
- Termina TLS su `:443` (Let’s Encrypt automatico).
- Proxy verso `odoo:8069` e longpolling `odoo:8072`.
- Esponi solo il proxy (app rimane in rete interna).

### **Output**

- Odoo disponibile in **HTTPS** con certificato valido.
- Niente gestione manuale dei certificati.

### **Pro e Contro**

- ❌ Non copre Sicurezza credenziali,
- ❌ Non copre backup,
- ❌ Non copre HA.

---

## 📝 Step 2 — Nginx + Certbot (più manuale, più didattico)

**Learn**: virtual host, challenge ACME, rinnovo cert.

### **Passaggi**

- Sostituisci o affianca Caddy con **Nginx**.
- Usa **Certbot** per ottenere/rinnovare i certificati.
- Configura server block per `/:443` → proxy a Odoo.

### **Pro e Contro**

- ✅ Massimo controllo, utile per imparare Nginx.
- ❌ Più manutenzione (rinnovi, config).

---

## 📝 Step 3 — Secrets da AWS (SSM/Secrets Manager) via `entrypoint`

**Learn**: secret management, iniezione runtime, principle of least privilege.

### **Passaggi**

- Crea parametri **SSM** o **Secrets Manager** (es. `/odoo/db_password`).
- Nel container, `entrypoint` che **legge i secrets** e li **esporta** come env/`odoo.conf`.
- Evita file in chiaro nel repo e sul disco della VM.
- IAM role/instance profile con permessi **read-only** a quel path.

### **Output**

- ✅ Nessuna password hardcoded nei file.
- ✅ Rotazione più semplice.

### **Pro e Contro**

- ❌ Affidabilità DB, ❌ backup gestiti.

---

## 📝 Step 4 — Backup & Log di base + separazione proxy/app

**Learn**: operabilità minima, recovery, visibilità.

### **Passaggi**

- **Backup DB** (se locale): `pg_dump` giornaliero su volume + sync su S3.
- **Backup filestore**: tar + upload su S3.
- **Log**: centralizza stdout/stderr (es. file log del proxy, rotazione).
- App dietro proxy solo su rete interna; esponi pubblicamente **solo il proxy**.

### **Output**

- ✅ Snapshot minimi di DB + filestore.
- ✅ Log consultabili/ruotati.

### **Pro e Contro**

- ❌ RPO/RTO seri, ❌ ripristini point-in-time.

---

## 📝 Step 5 — Spostare DB su **RDS Postgres**

**Learn**: servizio gestito, snapshot automatiche, security groups.

### **Passaggi**

- Crea **RDS Postgres** con backup automatici e **PITR** abilitato.
- Security Group: **solo** EC2/ECS ↔ RDS su **5432**.
- In `odoo.conf`: `db_host=<endpoint RDS>`.
- In Compose: **rimuovi** il servizio `db`.
- Backup: snapshot RDS + (opzionale) export su S3.

### **Output**

- ✅ Affidabilità DB (patching, snapshot).
- ✅ Miglior **RPO/RTO**.

### **Pro e Contro**

- ❌ HA dell’app (resta 1 istanza).
- ❌ Filestore condiviso / scaling orizzontale.
- ❌ Zero-downtime deploy.

---

## 📝 Step 6 — CI/CD (GitHub Actions → build & deploy)

**Learn**: pipeline, registry, deploy ripetibili.

### **Passaggi**

- Workflow **GitHub Actions**: build immagine Odoo → push su **registry** (Docker Hub o **ECR**).
- Deploy:
    - Variante semplice: **EC2** via SSH + `docker compose pull && up -d`.
    - Variante cloud-native: **ECS/Fargate** con task definition aggiornate.
- Conserva artefatti (immagini versionate) e fai **tagging** coerente.

### **Output**

- ✅ Deploy da Git con un click/merge.
- ✅ Build ripetibili/versionate.

---

## 📝 Step 7 — HA/Scalabilità

**Learn**: Bilanciamento, stato condiviso, osservabilità.

### **Passaggi**

- **ALB** davanti a 2+ istanze Odoo (su **ECS/Fargate** o più **EC2**).
- **Filestore condiviso**: **EFS** (semplice) oppure **S3** + modulo.
- **Observability**: CloudWatch Logs/Metrics (o ELK), healthcheck ALB.
- **Deploy**: GitHub Actions → ECR → ECS **rolling/blue-green**.

### **Output**

- ✅ Alta disponibilità base.
- ✅ Scaling orizzontale dell’app.

---
