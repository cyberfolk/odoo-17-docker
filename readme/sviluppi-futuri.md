# Sviluppi Futuri

> **TODO** - Da rivedere e da implementare.

## Step 2

- Recuperare i secrets tramite **entrypoint** e **AWS SSM Parameter Store**
- Nginx
- [CI/CD](docs-ci-cd.md)

# Step 3 - Quando i dati contano

**Mettere in sicurezza i dati e le credenziali senza complicare troppo l’infrastruttura.**

**Cosa fare**

- Spostare il DB da Docker a **RDS** (gestito, backup automatici, ripristino point-in-time)
- Togliere i segreti dal disco usando **Secrets Manager/Parameter Store**, con **Security Group** stretti.

**Cosa ottieni**

- Affidabilità DB più alta (backup, patching, restore).
- Miglior **RPO/RTO** (snapshot + PITR).
- Niente password in chiaro sulla VM.
- Superficie d’attacco ridotta (5432 solo EC2↔RDS).

**Cosa NON risolve**

- Niente **HA** dell’app (resta 1 EC2).
- Niente filestore condiviso/scaling orizzontale.
- Niente zero-downtime deploy.

**Impatto operativo minimo**

- Cambi `db_host` → endpoint RDS.
- Rimuovi il servizio `db` dal Compose.
- Sposti i segreti in Secrets/SSM.
- Backup: snapshot RDS + export su S3.

*Modifiche principali*

- In `odoo.conf`: `db_host=<endpoint RDS>`
- In Compose: rimuovi il servizio `db`.
- **Backup**: usa snapshot RDS + export periodico su S3.

# Migrazione a Step 4 (HA/Scalabilità)

- **EFS** per filestore condiviso (o S3 + modulo)
- **ALB** + 2+ istanze Odoo (ECS/Fargate o più EC2)
- **Observability**: CloudWatch Logs/metrics, o stack ELK; healthcheck ALB
- **Deploy**: GitHub Actions → ECR → ECS roll‑out

## Step 2 — HTTPS facile (budget ~0€)

Opzione **più semplice**: **Caddy** davanti a Odoo (auto-HTTPS Let’s Encrypt).

- Prendi un **subdominio gratuito** (es. `mio-nome.duckdns.org`).
- Aggiungi **Caddy** nel `docker-compose` come reverse proxy:
    - Termina TLS su **:443** (Caddy fa i certificati da solo).
    - Proxy → `odoo:8069` e `longpolling:8072`.
- **Pro**: niente sbattimento certificati, tutto automatico.
- **Contro**: devi usare un subdominio free (va benissimo per te e gli amici).

> Alternative equivalenti:
>
> - **Nginx** + **Certbot** (più manuale, più didattico).
> - **Traefik** (ottimo con Docker labels, auto-HTTPS; un filo più “devopsy”).

## Step 3 — Ammodernare e preparare alla CI/CD

- Sposta la terminazione TLS su proxy (Caddy/Nginx/Traefik), **Odoo dietro** su rete Docker interna.
- Aggiungi **backup** (DB + filestore) e log decenti.
- Più avanti: **GitHub Actions** → build/push immagine → deploy su EC2/ECS.