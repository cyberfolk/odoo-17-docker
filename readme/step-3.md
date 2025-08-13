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
