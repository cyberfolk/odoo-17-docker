# Odoo 17 | Docker

> Repository per avviare **Odoo 17** in pochi minuti tramite **Docker**, con configurazioni pronte all’uso sia per sviluppo locale che per deploy su AWS.  
> Include [Docker | Mini Guida](readme/docs-docker.md) per le conoscenze di base.

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

## 📌 Obbiettivi del progetto

- **Orchestrare** due container Docker:
    1. **PostgreSQL 15** → come database di backend
    2. **Odoo 17** → come server applicativo
- **Parametrizzare** le credenziali e la configurazione tramite variabili d’ambiente (`.env`)
- **Gestire** una cartella `./addons` per caricare moduli custom.
- **Personalizzare** la configurazione di Odoo tramite `config/odoo.conf`

---

## 🛠️ 4 Branch disponibili

La repo ha **4 branch** (diversi livelli di setup) documentati nella cartella `readme/`.  
Il contenuto di `readme/` è identico in tutti i branch; cambia solo il **codice** (YAML, Dockerfile, ecc.).  
Gli step 2 e 3, per ora, contengono solo la descrizione dell’idea: il branch sarà sviluppato in seguito.

- [**local**](readme/step-1.md) → esecuzione in locale su PC
- [**AWS 1**](readme/step-1.md) → primo deploy AWS (configurazione base su EC2)
- [**AWS 2**](readme/step-2.md) → *(in sviluppo)* versione avanzata con ottimizzazioni aggiuntive
- [**AWS 3**](readme/step-3.md) → *(in sviluppo)* versione avanzata con ulteriori servizi

---

## ⚠️ Attenzione - PC Windows

Se stai eseguendo il codice in ambiente **Windows**, assicurati di:

- Avere **Docker Desktop** configurato per usare WSL2
- Avere **WSL2** installato e attivo → [vedi guida](LINK-PLACEHOLDER)
- Utilizzare il **Terminale Ubuntu** per seguire quata guida.

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

## 📚 Indice

- [🚀 Quick Run](#-quick-run)
- [📌 Obbiettivi del progetto](#-obbiettivi-del-progetto)
- [🛠️ 4 Branch disponibili](#️-4-branch-disponibili)
- [⚠️ Attenzione - PC Windows](#️-attenzione-pc-windows)
- [WSL2 | Mini Guida](readme/docs-wsl.md)
- [Docker | Mini Guida](readme/docs-docker.md)
- [FAQ](readme/docs-faq.md)

---
