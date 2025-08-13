# Docker

> Piattaforma per eseguire applicazioni in **container**, ambienti isolati e portabili che includono tutto il necessario (codice, librerie, configurazioni).

---

## Concetti chiave

- **Immagine**: template immutabile (es. `odoo:17`)
- **Container**: istanza in esecuzione dell’immagine
- **Volume**: spazio persistente (DB, filestore)
- **Bind mount**: mappa cartella locale nel container (`./addons:/mnt/extra-addons`)
- **Network**: rete interna tra servizi (`db` ↔︎ `odoo`)
- **Compose**: orchestra più servizi (`docker compose up`)
- **image** VS **build**:
    - `image: odoo:17` → immagine precompilata
    - `build: .` → compila immagine personalizzata con `Dockerfile`

---

## Struttura dei docker-compose.yml


- **docker-compose.yml** → configurazione comune a tutti gli ambienti (dev, staging, prod).
- **docker-compose.override.yml** → se presente verrà sempre caricato di default assieme a **docker-compose.yml** (senza specificare `-f`).
- **docker-compose.prod.yml** → override esplicito per produzione (passato con `-f`).

**Esecuzione con merge**

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

Docker fa il **merge in ordine**:

1. Carica `docker-compose.yml`
2. Carica `docker-compose.prod.yml` sovrascrivendo o aggiungendo chiavi
3. Risultato = configurazione finale eseguita

---

## Comandi base

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
docker compose down -v --remove-orphans
docker volume rm -f odoo-17-docker_odoo-data
```

---

## Dove finiscono i file di Odoo

- **Il codice base di Odoo** (core) non sta nel PC, ma **dentro il container** Docker di Odoo.
- L’unica cartella di codice che **mappata dal PC** al container è `./addons`, dove ci vanno i moduli custom.
- I dati del database Postgres sono salvati nel volume Docker `db-data`.
- I file caricati da Odoo (allegati, immagini, ecc.) sono salvati nel volume Docker `odoo-data`.

**Questo significa che:**

- Se vuoi modificare Odoo core → devi entrare **dentro il container**.
- Se vuoi sviluppare moduli custom → li metti in `./addons` sul tuo PC.
- Se vuoi fare backup DB o filestore → devi esportare i volumi `db-data` e `odoo-data`. 

**Per vedere il core dentro il container:**

```bash
docker exec -it <nome_container_odoo> bash
cd /usr/lib/python3/dist-packages/odoo
ls
```

---
