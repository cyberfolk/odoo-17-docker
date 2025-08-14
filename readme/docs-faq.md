# FAQ

- **Posso usare solo Git Bash?** → Se usi Windows no, serve WSL2
- **I file core Odoo compaiono localmente?** → No, vivono nel container
- **Posso sviluppare moduli con Docker?** → Sì, montando `./addons` e sviluppando da li.
- **Dove stanno i dati?** → Nei volumi `db-data` e `odoo-data`
- **Come resetto tutto?** → `docker compose down -v` (⚠️ perdi dati)
