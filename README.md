# Odoo 17 | Docker | Windows/WSL

> **Scaffolding Docker Compose** per avviare in pochi minuti un’istanza Odoo 17 in locale (Windows + WSL2 + Docker Desktop), con PostgreSQL e supporto per moduli custom e dipendenze extra.

---

## 🚀 Quick Run

```bash
# Clona la repo
git clone git@github.com:cyberfolk/odoo-17-docker.git
cd odoo-17-docker

# Prepara il file .env
cp .env.example .env
code .env # modifica DB_PASSWORD con un valore sicuro

# Avvia i container
docker compose build
docker compose up -d

# Accedi a Odoo
# URL: http://localhost:8069
# Password database manager: admin (vedi config/odoo.conf)
```

---

## 📚 Indice

- [Odoo 17 | Docker | Windows/WSL](#odoo-17--docker--windowswsl)
  - [🚀 Quick Run](#-quick-run)
  - [📚 Indice](#-indice)
  - [📌 Dettagli del progetto](#-dettagli-del-progetto)
  - [Requisiti](#requisiti)
  - [Struttura della repo](#struttura-della-repo)
  - [Docker | Concetti chiave](#docker--concetti-chiave)
  - [WSL2 | Concetti chiave](#wsl2--concetti-chiave)
    - [Git Bash ≠ WSL](#git-bash--wsl)
  - [Docker | Comandi base](#docker--comandi-base)
  - [Dove finiscono i file di Odoo](#dove-finiscono-i-file-di-odoo)
  - [FAQ](#faq)

---

## 📌 Dettagli del progetto

Questa repository fornisce una configurazione pronta all’uso per:

-   **Orchestrare** due container Docker:
    1. **PostgreSQL 15** come database di backend
    2. **Odoo 17** come server applicativo
-   **Parametrizzare** le credenziali e la configurazione tramite variabili d’ambiente (`.env`)
-   **Gestire** una cartella `./addons` per sviluppare e testare moduli personalizzati senza ricostruire l’immagine
-   **Personalizzare** la configurazione di Odoo tramite `config/odoo.conf`

---

## Requisiti

-   **Windows 10/11** con **WSL2** attivo
-   **Docker Desktop** configurato per usare WSL2
-   **Git** per clonare la repo

---

## Struttura della repo

```bash
├── .env.example        # Template variabili (committato)
├── .env                # Valori reali (non committato)
├── docker-compose.yml  # Orchestrazione servizi
├── Dockerfile          # Per build custom di Odoo (non necessario se usi l'immagine ufficiale)
├── config/
│   └── odoo.conf       # Configurazione Odoo parametrizzata
├── addons/             # Moduli custom
└── requirements.txt    # Dipendenze Python extra usate nel Dockerfile
```

---

## Docker | Concetti chiave

-   **Immagine**: template immutabile (es. `odoo:17`)
-   **Container**: istanza in esecuzione dell’immagine
-   **Volume**: spazio persistente (DB, filestore)
-   **Bind mount**: mappa cartella locale nel container (`./addons:/mnt/extra-addons`)
-   **Network**: rete interna tra servizi (`db` ↔︎ `odoo`)
-   **Compose**: orchestra più servizi (`docker compose up`)
-   **image** VS **build**:
    -   `image: odoo:17` → immagine precompilata
    -   `build: .` → compila immagine personalizzata con `Dockerfile`

---

## WSL2 | Concetti chiave

Docker su Windows richiede **WSL2** perché lo usa nel backend.

**Aggiorna/installa WSL2:**

```powershell
# da PowerShell (amministratore)
wsl --update
wsl --set-default-version 2
wsl --install   # se non hai una distro; installerà Ubuntu
```

**Dopo l’installazione:** apri **Ubuntu**, crea un utente e verifica:

```bash
uname -r                       # kernel WSL2 attivo
docker --version               # Docker disponibile
docker run hello-world         # smoke test
```

### Git Bash ≠ WSL

| Git Bash                                   | WSL 2                               |
| ------------------------------------------ | ----------------------------------- |
| Emulatore Bash su Windows                  | Vero ambiente Linux integrato       |
| Esegue tool tipo Unix, ma resta in Windows | Esegue nativamente binari Linux     |
| Non sostituisce WSL per Docker             | Backend usato da **Docker Desktop** |

💡 Mapping dischi: `C:\...` in Windows ↔︎ `/mnt/c/...` in WSL

---

## Docker | Comandi base

```bash
docker ps                     # container attivi
docker ps -a                  # tutti (inclusi spenti)
docker logs -f <nome>         # tail log
docker exec -it <nome> bash   # shell nel container
docker compose up -d          # avvia
docker compose down           # ferma
docker compose down -v        # ferma + rimuove volumi (⚠️ perdi dati)
docker system df              # spazio usato
docker image prune -f         # pulizia immagini inutilizzate
```

---

## Dove finiscono i file di Odoo

-   **Core Odoo** → dentro il container
-   **`./addons`** → unica cartella montata per moduli custom
-   **Volumi**:
    -   `db-data` → database Postgres
    -   `odoo-data` → filestore

Per vedere il core dentro il container:

```bash
docker exec -it <nome_container_odoo> bash
cd /usr/lib/python3/dist-packages/odoo
ls
```

---

## FAQ

-   **Posso usare solo Git Bash?** → No, serve WSL2
-   **I file core Odoo compaiono localmente?** → No, vivono nel container
-   **Posso sviluppare moduli con Docker?** → Sì, montando `./addons`
-   **Dove stanno i dati?** → Nei volumi `db-data` e `odoo-data`
-   **Come resetto tutto?** → `docker compose down -v` (⚠️ perdi dati)
