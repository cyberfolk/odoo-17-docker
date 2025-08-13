# Gestione Secrets | AWS Parameter

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
