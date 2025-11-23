# Sviluppi Futuri — Roadmap Didattica (incrementale)

> Obiettivo: trasformare il setup Odoo in un percorso di apprendimento a step brevi, ognuno con uno scopo chiaro e un risultato verificabile.  
> Assunzione: **Step 0** (Odoo in Docker su una singola macchina, rete Docker interna, no HTTPS) è già operativo.

---

## 🔎 Mappa rapida
- **Step 1** → HTTPS facile con **Caddy** (gratis, veloce).
- **Step 2** → Alternativa didattica: **Nginx + Certbot**.
- **Step 3** → **Secrets** da **AWS SSM/Secrets Manager** via `entrypoint`.
- **Step 4** → **Backup & Log** di base (DB + filestore) e rete proxy → app.
- **Step 5** → **RDS Postgres** (“Quando i dati contano”).
- **Step 6** → **CI/CD** (GitHub Actions → build & deploy).
- **Step 7** → **HA/Scalabilità** (ALB, 2+ app, EFS/S3, osservabilità).

> Mappatura dal documento originale:
> - “Step 2 (entrypoint + SSM) / Nginx / CI/CD” → ora **Step 2–3–6** separati.  
> - “Step 3 — Quando i dati contano” → ora **Step 5**.  
> - “Migrazione a Step 4 (HA/Scalabilità)” → ora **Step 7**.

---

## Step 1 — HTTPS in 15 minuti (Caddy, budget ~0€)

**Impari**: reverse proxy, terminazione TLS, rete Docker.  
**Prerequisiti**: subdominio (es. `duckdns.org`).

**Fai**
- [ ] Aggiungi **Caddy** al `docker-compose` come reverse proxy.
- [ ] Termina TLS su `:443` (Let’s Encrypt automatico).
- [ ] Proxy verso `odoo:8069` e longpolling `odoo:8072`.
- [ ] Esponi solo il proxy (app rimane in rete interna).

**Output atteso**
- ✅ Odoo disponibile in **HTTPS** con certificato valido.
- ✅ Niente gestione manuale dei certificati.

**Non copre**
- ❌ Sicurezza credenziali, ❌ backup, ❌ HA.

> Alternative: **Traefik** (auto-HTTPS via labels), più “devopsy”.

---

## Step 2 — Nginx + Certbot (più manuale, più didattico)

**Impari**: virtual host, challenge ACME, rinnovo cert.  
**Fai**
- [ ] Sostituisci o affianca Caddy con **Nginx**.
- [ ] Usa **Certbot** per ottenere/rinnovare i certificati.
- [ ] Configura server block per `/:443` → proxy a Odoo.

**Pro**
- ✅ Massimo controllo, utile per imparare Nginx.  
**Contro**
- ❌ Più manutenzione (rinnovi, config).

---

## Step 3 — Secrets da AWS (SSM/Secrets Manager) via `entrypoint`

**Impari**: secret management, iniezione runtime, principle of least privilege.

**Fai**
- [ ] Crea parametri **SSM** o **Secrets Manager** (es. `/odoo/db_password`).
- [ ] Nel container, `entrypoint` che **legge i secrets** e li **esporta** come env/`odoo.conf`.
- [ ] Evita file in chiaro nel repo e sul disco della VM.
- [ ] IAM role/instance profile con permessi **read-only** a quel path.

**Output atteso**
- ✅ Nessuna password hardcoded nei file.  
- ✅ Rotazione più semplice.

**Non copre**
- ❌ Affidabilità DB, ❌ backup gestiti.

---

## Step 4 — Backup & Log di base + separazione proxy/app

**Impari**: operabilità minima, recovery, visibilità.

**Fai**
- [ ] **Backup DB** (se locale): `pg_dump` giornaliero su volume + sync su S3.  
- [ ] **Backup filestore**: tar + upload su S3.  
- [ ] **Log**: centralizza stdout/stderr (es. file log del proxy, rotazione).  
- [ ] App dietro proxy solo su rete interna; esponi pubblicamente **solo il proxy**.

**Output atteso**
- ✅ Snapshot minimi di DB + filestore.  
- ✅ Log consultabili/ruotati.

**Non copre**
- ❌ RPO/RTO seri, ❌ ripristini point-in-time.

---

## Step 5 — Quando i dati contano: sposta il DB su **RDS Postgres**

**Impari**: servizio gestito, snapshot automatiche, security groups.

**Cosa fai**
- [ ] Crea **RDS Postgres** con backup automatici e **PITR** abilitato.
- [ ] Security Group: **solo** EC2/ECS ↔ RDS su **5432**.
- [ ] In `odoo.conf`: `db_host=<endpoint RDS>`.
- [ ] In Compose: **rimuovi** il servizio `db`.
- [ ] Backup: snapshot RDS + (opzionale) export su S3.

**Cosa ottieni**
- ✅ Affidabilità DB (patching, snapshot).  
- ✅ Miglior **RPO/RTO**.

**Cosa NON risolve**
- ❌ HA dell’app (resta 1 istanza).  
- ❌ Filestore condiviso / scaling orizzontale.  
- ❌ Zero-downtime deploy.

---

## Step 6 — CI/CD (GitHub Actions → build & deploy)

**Impari**: pipeline, registry, deploy ripetibili.

**Fai**
- [ ] Workflow **GitHub Actions**: build immagine Odoo → push su **registry** (Docker Hub o **ECR**).  
- [ ] Deploy:  
  - Variante semplice: **EC2** via SSH + `docker compose pull && up -d`.  
  - Variante cloud-native: **ECS/Fargate** con task definition aggiornate.
- [ ] Conserva artefatti (immagini versionate) e fai **tagging** coerente.

**Output atteso**
- ✅ Deploy da Git con un click/merge.  
- ✅ Build ripetibili/versionate.

---

## Step 7 — HA/Scalabilità

**Impari**: bilanciamento, stato condiviso, osservabilità.

**Fai**
- [ ] **ALB** davanti a 2+ istanze Odoo (su **ECS/Fargate** o più **EC2**).  
- [ ] **Filestore condiviso**: **EFS** (semplice) oppure **S3** + modulo.  
- [ ] **Observability**: CloudWatch Logs/Metrics (o ELK), healthcheck ALB.  
- [ ] **Deploy**: GitHub Actions → ECR → ECS **rolling/blue-green**.

**Output atteso**
- ✅ Alta disponibilità base.  
- ✅ Scaling orizzontale dell’app.

---

## Appendix — Checklist veloci per ogni step

- **Step 1 (Caddy)**  
  - [ ] DNS → IP pubblico  
  - [ ] `docker-compose` con `caddy` + mount per state  
  - [ ] Proxy `:443` → `odoo:8069/8072`

- **Step 2 (Nginx+Certbot)**  
  - [ ] Certbot HTTP-01/ALPN-01  
  - [ ] vhost `server_name` + `proxy_pass`

- **Step 3 (Secrets)**  
  - [ ] Parametri in SSM/Secrets  
  - [ ] `entrypoint` che esporta env/`odoo.conf`  
  - [ ] IAM limitato read-only

- **Step 4 (Backup/Log)**  
  - [ ] `pg_dump` + tar filestore + upload S3  
  - [ ] Rotazione log  
  - [ ] App non esposta pubblicamente

- **Step 5 (RDS)**  
  - [ ] RDS con backup/PITR  
  - [ ] SG 5432 ristretto  
  - [ ] `db_host` aggiornato

- **Step 6 (CI/CD)**  
  - [ ] GH Actions: build + push  
  - [ ] Deploy EC2/ECS  
  - [ ] Tagging/versioning

- **Step 7 (HA)**  
  - [ ] ALB + target group  
  - [ ] EFS/S3 per filestore  
  - [ ] Logs/metrics centralizzati

---

## Note pratiche

- **Caddy vs Nginx**  
  - Caddy = veloce, auto-HTTPS.  
  - Nginx = più controllo, più lavoro; ottimo per imparare.

- **SSM vs Secrets Manager**  
  - SSM (Parameter Store) è sufficiente e costa meno; Secrets Manager ha rotazione nativa.

- **Ordine consigliato**  
  - Se vuoi imparare “per layer”: 1 → 3 → 4 → 5 → 6 → 7 (2 opzionale).  
  - Se punti presto al deploy automatizzato: 1 → 2/3 → 6 → 5 → 7.

---
