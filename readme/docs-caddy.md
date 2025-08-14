# Aggiungere Caddy (HTTPS auto)

Aggiungere **Caddy** come reverse proxy davanti a Odoo: ottieni **HTTPS automatico** con Let’s Encrypt e un endpoint pulito su 443.

## Scegli un dominio

> Nota costi AWS IPv4: dal **1 feb 2024** i public IPv4 **costano 0,005 $/h** (~3,6 $/mese).  
> Valuta se usare un solo IP per più servizi dietro al proxy.

### Opzione A — Subdominio gratuito (facile)

- [**DuckDNS**](https://www.duckdns.org/): crea un subdominio gratuito (es. `mioerp.duckdns.org`) e puntalo all’IP pubblico dell’EC2. Prendi il **token** se vuoi aggiornamenti automatici IP.

### Opzione B — Dominio a pagamento (low-cost)

- **Cloudflare Registrar** (a costo di registro), **OVH**, **Namecheap**, **Squarespace Domains** (ex Google Domains).
- Crea un record **A** `erp.tuodominio.it` → IP pubblico dell’EC2.

## Config Odoo dietro proxy

In `config/odoo.conf` (o var. env equivalenti):

```
proxy_mode = True
workers = 2
longpolling_port = 8072
```

## Aggiungere i file alla repo

Nella root della repo aggiungere:
 - `reverse-proxy/Caddyfile`
 - `docker-compose.prod.yml`

## Configura i placeholder

Apri `docker-compose.prod.yml` e sostituisci:

- `__SOSTITUISCI_CON_TUO_DOMINIO__` → es. `mioerp.duckdns.org` (o il tuo dominio)
- `__SOSTITUISCI_CON_TUA_EMAIL__` → tua email (necessaria per Let’s Encrypt)

Se preferisci, puoi mettere i valori in un `.env` e referenziarli come `${DOMAIN}` / `${LETSENCRYPT_EMAIL}`.

## Sicurezza (Security Group EC2)

- **Apri**: 80 (HTTP), 443 (HTTPS) **dal mondo**.
- **Chiudi** all’esterno: 8069 e 8072 (lasciale accessibili solo nella VPC).
- SSH 22 solo dal tuo IP.

## Avvio

```
docker compose pull
docker compose up -d caddy
# Se è il primo deploy: docker compose up -d (alza anche 'odoo' e 'db')
```

## Test

- Visita `https://TUO_DOMINIO/` → deve aprirsi Odoo con lucchetto verde.
- Longpolling: apri la console del browser e verifica assenza errori su `/longpolling`.

## Troubleshooting veloce

- **DNS non propagato**: aspetta 5–10 minuti e riprova.
- **Porta 80/443 chiusa**: controlla Security Group/VPC/NACL.
- **Certificato non emesso**: il dominio **deve** risolvere sull’IP della tua EC2 e le porte 80/443 devono essere raggiungibili.
- **Non trova il servizio `odoo`**: assicurati che il service name in `docker-compose.yml` sia proprio `odoo` (altrimenti cambia i target nel `Caddyfile`).

## Aggiungere altre app in futuro

- Sullo **stesso IP** puoi ospitare più app, ognuna con il **suo subdominio**; Caddy gestisce il routing e i certificati.
- Apri nuove porte **solo internamente** tra container; all’esterno **solo 80/443**.

---

