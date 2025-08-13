# Odoo 17 | Docker

> Repository per avviare **Odoo 17** in pochi minuti tramite **Docker**, con configurazioni pronte all’uso sia per sviluppo locale che per deploy su AWS.  
> Include [Docker | Mini Guida](readme/docs-docker.md) per le conoscenze di base.

---

## 🚀 Quick Run

```bash
# Clona la repo
git clone git@github.com:cyberfolk/odoo-17-docker.git
cd odoo-17-docker

# Cambia il contenuto di /secrets/db_password
# Cambia admin_passwd dentro /config/odoo.conf

# Avvia i container
docker compose build
docker compose up -d

# Accedi a Odoo
# URL: http://localhost:8069
```

---

## 📌 Obbiettivi del progetto

- **Orchestrare** due container Docker:
    1. **PostgreSQL 15** → come database di backend
    2. **Odoo 17** → come server applicativo
- **Parametrizzare** la password del DB tramite `secrets/`
- **Gestire** una cartella `./addons` per caricare moduli custom.

---

## 🛠️ Sviluppi

Gli sviluppi futuri e le versioni intermedie sono documentati nei file all’interno della cartella `readme/`:

- **Step 0** → Versione base, eseguibile sia in locale che su AWS.  
  *(Il README principale fa riferimento a questa versione.)*
- [**Step 2**](readme/step-2.md) → *(in sviluppo)* SSM Parameter Store, Nginx, CI/CD
- [**Step 3**](readme/step-3.md) → *(in sviluppo)* versione avanzata con ottimizzazioni aggiuntive
- [**Step 4**](readme/step-4.md) → *(in sviluppo)* versione avanzata con ulteriori servizi

---

## ⚠️ Attenzione - PC Windows

Se stai eseguendo il codice in ambiente **Windows**, assicurati di:

- Avere **Docker Desktop** configurato per usare WSL2
- Avere **WSL2** installato e attivo → [vedi guida](readme/docs-wsl.md)
- Utilizzare il **Terminale Ubuntu** per seguire quata guida.

---

## Struttura della repo

```bash
├── .env.example        # Template variabili (committato)
├── .env                # Valori reali (non committato)
├── docker-compose.yml  # Orchestrazione servizi
├── Dockerfile          # Per build custom di Odoo (non necessario se usi l'immagine ufficiale)
├── secrets             # Password per configurare docker
├── config/
│   └── odoo.conf       # Configurazione Odoo parametrizzata
├── addons/             # Moduli custom
└── requirements.txt    # Dipendenze Python extra usate nel Dockerfile
```

---

## 📚 Indice

- [🚀 Quick Run](#-quick-run)
- [📌 Obbiettivi del progetto](#-obbiettivi-del-progetto)
- [🛠️ 4 Branch disponibili](#️-4-branch-disponibili)
- [⚠️ Attenzione - PC Windows](#️-attenzione-pc-windows)
- [WSL2 | Mini Guida](readme/docs-wsl.md)
- [Docker | Mini Guida](readme/docs-docker.md)
- [FAQ](readme/docs-faq.md)

---
