# CI/CD

> **TODO** - Da rivedere e da implementare.


**CI/CD** sta per *Continuous Integration* e *Continuous Deployment* (o *Delivery*).  
L'idea è automatizzare il processo che porta il codice dallo sviluppo alla produzione:

1. **Continuous Integration (CI)**
    - Unisci il codice nel branch principale il più spesso possibile
    - Automatizzi test, linting, build
    - Garantisci che il codice integrato sia sempre stabile

2. **Continuous Deployment (CD)**
    - Ogni volta che il codice passa la CI, viene *automaticamente* distribuito in un ambiente (staging o produzione)
    - Il deploy è ripetibile e tracciabile

---

## Come funziona la CI/CD in un ambiente self-hosted (es. AWS EC2 + Docker)

### Flusso tipico

1. **Push del codice** su GitHub/GitLab
2. **Pipeline CI** (es. GitHub Actions, GitLab CI, Jenkins):
    - Costruisce l'immagine Docker (`docker build`)
    - Tagga l'immagine (es. `myapp:<commit_sha>` e `myapp:latest`)
    - Fa il **push** dell'immagine in un registro (Docker Hub, ECR, GHCR)
3. **Server di produzione**:
    - Esegue `docker pull` per scaricare la nuova immagine
    - Riavvia i container con la nuova versione
    - Esegue `docker image prune -f` per eliminare immagini vecchie non più usate

**Nota importante**:  
L'immagine *non* viene presa dalla produzione. Si crea sempre in CI, per garantire tracciabilità e coerenza.

---

## Come funziona su Odoo.sh

Odoo.sh nasconde tutta la complessità della CI/CD dietro un'interfaccia semplice:

- **Repo Git collegata**: ogni branch ha un ambiente associato (staging, produzione, sviluppo)
- **Push su branch**:
    1. Odoo.sh fa il build dell'ambiente con il nuovo codice
    2. Aggiorna automaticamente l'istanza
    3. Esegue migrazioni di database se necessario
    4. Riavvia Odoo
- Non serve creare Dockerfile, configurare pipeline o gestire server
- I secret e la configurazione sono gestiti automaticamente

**In pratica**: Odoo.sh implementa CI/CD in modo trasparente.

---

## Differenze chiave: Odoo.sh vs Self-Hosted su AWS

| Aspetto             | Odoo.sh            | Self-Hosted AWS (Docker)              |
|---------------------|--------------------|---------------------------------------|
| Build dell'ambiente | Automatica su push | Definita in CI (GitHub Actions, ecc.) |
| Deploy              | Automatico         | Manuale o automatizzato via pipeline  |
| Gestione secret     | Integrata          | Da fare (AWS SSM, Secrets Manager)    |
| Gestione server     | Non necessaria     | A carico tuo                          |
| Pulizia immagini    | Automatica         | Manuale (`docker image prune`)        |
| Backup              | Integrati          | Da implementare                       |
| Scalabilità         | Limitata a Odoo.sh | Illimitata ma complessa               |

---

## Quando scegliere self-hosted

- Vuoi **più controllo** su configurazioni, scaling, e costi
- Devi integrare Odoo con altri servizi in container
- Vuoi usare infrastruttura personalizzata (es. più servizi oltre Odoo)

**Svantaggi**: più manutenzione, più competenze richieste.

---

## Esempio di workflow CI/CD su AWS EC2

1. **Pipeline CI (GitHub Actions)**:

```yaml
name: Build and Push
on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Log in to Docker Hub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} -t myapp:latest .
      - name: Push image
        run: |
          docker push myapp:${{ github.sha }}
          docker push myapp:latest
```

## Server EC2:

```bash
docker compose pull
docker compose up -d
docker image prune -f
```

## Concetto chiave

La CI/CD serve a portare codice nuovo in produzione in modo sicuro, veloce e tracciabile.  
Su Odoo.sh lo fa il servizio per te.  
Su AWS o altre infrastrutture lo devi implementare e gestire tu.

