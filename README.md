# Odoo 17 | Docker

> Repository per avviare **Odoo 17** in pochi minuti tramite **Docker**, con configurazioni pronte all’uso sia per sviluppo locale che per deploy su AWS.

---

## 🚀 Quick Run

### 1. Parte Comune

```bash
# Clona la repo
git clone git@github.com:cyberfolk/odoo-17-docker.git
cd odoo-17-docker

# [Opzionale] Recupero i sottomoduli odoo-cyberfolk
git submodule sync --recursive
git submodule update --init --recursive

# CONFIGURAZIONI
# Cambia il contenuto di /secrets/db_password
# Cambia admin_passwd dentro /config/odoo.conf
```

### 2.1 Avvio in Locale

```bash
# Avvia i container
docker compose build
docker compose up -d

# Accedi a Odoo da: http://localhost:8069
```

### 2.2 Avvio su AWS

```bash
# CONFIGURAZIONI 2
cp .env.template .env
# Cambia CADDY_DOMAIN e CADDY_EMAIL su .env

# Avvia i container
docker docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
docker compose up -d

# Accedi a Odoo da: https://<CADDY_DOMAIN>
```

---

## 📌 Obbiettivi del progetto

1. **Orchestrare** Tre container Docker:
   - **PostgreSQL 15** → come database di backend
   - **Odoo 17** → come **server applicativo**
   - **Caddy** → come **web server** e **reverse proxy**
2. **Parametrizzare** la password del DB tramite `secrets/`
3. **Aggiungere** una cartella `./cyberfolk` contenenti i sottomoduli di altre repo.
4. **Gestire** una cartella `./addons` per caricare moduli custom.
5. **Propagare** i `requirements.txt` dentro **docker** tramite **Dockerfile** e
6. **Certificare** il domio https tramite **caddy** e `docker-compose.prod.yml`

---

## ⚠️ Attenzione - PC Windows

Se stai eseguendo il codice in ambiente **Windows**, assicurati di:

- Avere **Docker Desktop** configurato per usare WSL2
- Avere **WSL2** installato e attivo → [vedi guida](readme/docs-wsl.md)
- Utilizzare il **Terminale Ubuntu** per seguire quata guida.

---

## 📚 Mini Guide

- [Docker | Basi](readme/docs-docker.md)
- [WSL2 | Basi](readme/docs-wsl.md)
- [Attivare Caddy](readme/docs-caddy.md)
- [Confronto tra Caddy e Nginx](readme/docs-caddy-vs-nginx.md)
- [FAQ](readme/docs-faq.md)

### Docs Sviluppi Futuri
- [(wip) Sviluppi Futuri](readme/sviluppi-futuri.md)
- [(wip) CI/CD | Basi](readme/docs-ci-cd.md)
- [(wip) Docker | Secrets | SSM](readme/docs-faq.md)


---

## Struttura della repo

```bash
├── addons/                  # Moduli custom
├── cyberfolk/               # Contiene Sottomoduli contenenti moduli custom
├── config/
│   └── odoo.conf            # Configurazione Odoo parametrizzata
├── reverse-proxy/Caddyfile  # Configurazione per Caddy   
├── secrets/                 # Password per configurare docker
├── .env.template            # Template variabili (committato)
├── .env                     # Valori reali (non committato)
├── docker-compose.yml       # Orchestrazione servizi
├── docker-compose.prod.yml  # Orchestrazione servizi aggiuntivi: [Caddy]
├── Dockerfile               # Per build custom di Odoo (non necessario se usi l'immagine ufficiale)
└── requirements.txt         # Dipendenze Python extra usate nel Dockerfile
```

---
