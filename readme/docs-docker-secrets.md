# Gestione Secrets | AWS Parameter

> **TODO** - Da rivedere e da implementare.

## Entry Point personalizzati

> Sono script che vengono eseguiti all’avvio del container prima del processo principale.

**Usati generalmente per**

- Recuperare segreti da servizi sicuri (AWS SSM / Secrets Manager)
- Controllare readiness di servizi esterni (es. DB)
- Applicare migrazioni o setup iniziali

### Esempio

```bash
#!/usr/bin/env bash
set -euo pipefail

# Recupero segreti da AWS
export DB_PASSWORD=$(aws ssm get-parameter \
  --name /odoo-17-docker/db_password \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)
```

**docker-compose.prod.yml**

```yaml
services:
  odoo:
    image: my-odoo:prod
    entrypoint: [ "/scripts/entrypoint.sh" ]
```

---

## Gestione dei Secret

**Regole base**:

- **In produzione non devi avere file `.env` con password o chiavi sul server.**
- Invece, configuri l’istanza EC2 con un **IAM role**: un profilo di permessi che permette alla macchina di leggere i secret da AWS senza usare credenziali statiche.
- I secret li memorizzi in modo sicuro in **AWS SSM Parameter Store** o **AWS Secrets Manager**.
- Al momento dell’avvio (runtime), il tuo entrypoint o l’app stessa chiede ad AWS i valori e li usa come variabili d’ambiente, senza mai scriverli su disco.

**Esempio fetch da SSM in entrypoint**

```bash
export DB_PASSWORD=$(aws ssm get-parameter \
  --name /odoo-17-docker/db_password \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)
```

---

**AWS SSM Parameter Store (Standard)**

- Scopo principale → Configurazioni e secret **semplici**
- Costo → Gratis

**AWS Secrets Manager**

- Scopo principale → Gestione secret sensibili e **complessi**
- Costo → ~0,40 USD/mese per secret
- Funzioni avanzate

---

## Installazione AWS CLI v2 su Ubuntu

Su Amazon Linux di solito la CLI è già presente.  
Su Ubuntu/Debian la installi così:

```bash
sudo snap install aws-cli --classic
aws --version
```

---

## Creare IAM Role per EC2 con accesso a SSM/Secrets Manager

1. In AWS Console → IAM → Roles → Create Role
2. Tipo di trusted entity: **AWS Service** → **EC2**
3. Aggiungi permessi:
    - Per Parameter Store: `AmazonSSMReadOnlyAccess` (o policy personalizzata)
    - Per Secrets Manager: `SecretsManagerReadWrite` (o policy personalizzata)
4. Dai un nome e crea il ruolo
5. In **EC2 Console** → seleziona istanza → **Actions** → **Security** → **Modify IAM role** → assegna il ruolo creato

---

# Docker Secrets + AWS SSM

> Il modo **più sicuro** è leggere i segreti da **AWS SSM Parameter Store a runtime**, con **IAM Role**, scrivendo la password su **tmpfs** (niente file su disco, niente env con la password).  
> Quello **più diffuso** in Compose “spiccio” è pre-popolare un **file** locale e montarlo come secret.

---

## Scelte

- ✅ **Produzione sicura (consigliato)**: fetch da SSM nell’entrypoint di **ogni** container che ne ha bisogno, scrittura su `tmpfs`, nessuna variabile d’ambiente con la password.
- 👍 **Semplice e comune**: scrivi `./secrets/db_password` prima del `compose up` e montalo come secret/file.
- ❌ **Da evitare**: passare la password in env (`POSTGRES_PASSWORD`, `PASSWORD`, ecc.): finisce in `docker inspect`/log.

---

## Prerequisiti

- **Parametro SSM** (SecureString) creato, es. `/odoo-17-docker/db_password`.
- **Permessi IAM** (su istanza EC2 via Instance Profile, o su utente che lancia `aws`):
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {"Effect": "Allow","Action":["ssm:GetParameter"],"Resource":"arn:aws:ssm:<REGION>:<ACCOUNT_ID>:parameter/odoo-17-docker/db_password"},
      {"Effect": "Allow","Action":["kms:Decrypt"],"Resource":"arn:aws:kms:<REGION>:<ACCOUNT_ID>:key/<KMS_KEY_ID>"}
    ]
  }
  ```
- **Region** impostata (`AWS_DEFAULT_REGION` o `aws configure set region ...`).

---

## Opzione A — **Standard più sicuro** (SSM a runtime + tmpfs)

### 1) Struttura file

```
.
├─ docker-compose.yml
├─ config/
├─ addons/
└─ scripts/
   ├─ odoo-entrypoint.sh
   └─ pg-entrypoint.sh
```

### 2) Script entrypoint

`scripts/odoo-entrypoint.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

: "${AWS_DEFAULT_REGION:?Set AWS_DEFAULT_REGION}"
PARAM_NAME="${PARAM_NAME:-/odoo-17-docker/db_password}"

mkdir -p /run/secrets
aws ssm get-parameter   --name "$PARAM_NAME"   --with-decryption   --query 'Parameter.Value'   --output text > /run/secrets/db_password

chmod 0400 /run/secrets/db_password
DB_PASSWORD="$(cat /run/secrets/db_password)"

# Avvia Odoo senza lasciare la pw in env
exec odoo -c /etc/odoo/odoo.conf   --db_host="${DB_HOST:-db}"   --db_port="${DB_PORT:-5432}"   --db_user="${DB_USER:-odoo}"   --db_password="${DB_PASSWORD}"
```

`scripts/pg-entrypoint.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

: "${AWS_DEFAULT_REGION:?Set AWS_DEFAULT_REGION}"
PARAM_NAME="${PARAM_NAME:-/odoo-17-docker/db_password}"

mkdir -p /run/secrets
aws ssm get-parameter   --name "$PARAM_NAME"   --with-decryption   --query 'Parameter.Value'   --output text > /run/secrets/db_password

chmod 0400 /run/secrets/db_password
export POSTGRES_PASSWORD_FILE="/run/secrets/db_password"

# Passa al vero entrypoint Postgres
exec /usr/local/bin/docker-entrypoint.sh postgres
```

> Nota: Postgres usa `POSTGRES_PASSWORD_FILE` **solo al primo bootstrap** del cluster. Ai riavvii successivi ignora la variabile (normale).

### 3) `docker-compose.yml`

```yaml
version: "3.8"

services:
  db:
    image: postgres:15
    entrypoint: [ "/bin/bash", "/scripts/pg-entrypoint.sh" ]
    environment:
      AWS_DEFAULT_REGION: "eu-central-1"
      POSTGRES_USER: "odoo"
      POSTGRES_DB: "postgres"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ./scripts:/scripts:ro
      - odoo-db-data:/var/lib/postgresql/data/pgdata
    tmpfs:
      - /run/secrets

  web:
    image: odoo:17
    depends_on:
      - db
    entrypoint: [ "/bin/bash", "/scripts/odoo-entrypoint.sh" ]
    environment:
      AWS_DEFAULT_REGION: "eu-central-1"
      DB_HOST: "db"
      DB_USER: "odoo"
      DB_PORT: "5432"
      PARAM_NAME: "/odoo-17-docker/db_password"
    ports:
      - "8069:8069"
    volumes:
      - ./scripts:/scripts:ro
      - ./config:/etc/odoo
      - ./addons:/mnt/extra-addons
      - odoo-web-data:/var/lib/odoo
    tmpfs:
      - /run/secrets

volumes:
  odoo-web-data:
  odoo-db-data:
```

**Perché è sicuro**

- La password vive solo in **RAM** (`tmpfs`), mai su disco.
- Non resta in env → non finisce in `docker inspect`.
- Accesso controllato via **IAM Role**.

---

## Opzione B — **Semplice e comune** (file locale come secret)

### 1) Pre-popolare

```bash
mkdir -p secrets
aws ssm get-parameter   --name /odoo-17-docker/db_password   --with-decryption   --query "Parameter.Value"   --output text > ./secrets/db_password
chmod 0400 ./secrets/db_password
echo "secrets/db_password" >> .gitignore
```

### 2) Compose (estratto)

```yaml
services:
  web:
    image: odoo:17
    environment:
      HOST: db
      USER: odoo
      PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    # ... (volumi/porte come preferisci)

  db:
    image: postgres:15
    environment:
      POSTGRES_USER: odoo
      POSTGRES_DB: postgres
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
      PGDATA: /var/lib/postgresql/data/pgdata
    secrets:
      - db_password
    volumes:
      - odoo-db-data:/var/lib/postgresql/data/pgdata

secrets:
  db_password:
    file: ./secrets/db_password
```

> Facile, ma **il file sta su disco**. Permessi stretti e host protetto.

---

## Da evitare (se puoi)

```yaml
environment:
  POSTGRES_PASSWORD: ${DB_PASSWORD}
```

Comodo → sì. Sicuro → no (ispezionabile, loggabile).

---

## Troubleshooting

- **`You must specify a region`** → imposta `AWS_DEFAULT_REGION` o `aws configure set region ...`.
- **`AccessDeniedException`** → policy IAM + KMS.
- **`ParameterNotFound`** → nome parametro sbagliato o permessi mancanti.
- **Postgres chiede ancora la pw ai riavvii** → è normale: usa quella salvata nel cluster; `POSTGRES_PASSWORD_FILE` serve solo al **primissimo** avvio.

---

## Extra: ECS/Fargate

Su ECS:

- **Task Role** con permessi SSM/KMS.
- Secret injection da **Secrets Manager/SSM** (meglio come file/volume o sidecar), **evita env**.
- Stesso principio: no persistenza, no env in chiaro.

---

## Comandi rapidi

```bash
# Avvio (Opzione A)
docker compose up -d

# Log
docker compose logs -f web
docker compose logs -f db

# Pulizia
docker compose down
```
