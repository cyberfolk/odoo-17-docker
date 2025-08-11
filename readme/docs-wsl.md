# WSL2

> Sottosistema di Windows che ti permette di eseguire un vero **Linux** dentro Windows, con integrazione diretta col sistema.

---

## Concetti chiave

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

---

## Git Bash ≠ WSL

| Git Bash                                   | WSL 2                               |
|--------------------------------------------|-------------------------------------|
| Emulatore Bash su Windows                  | Vero ambiente Linux integrato       |
| Esegue tool tipo Unix, ma resta in Windows | Esegue nativamente binari Linux     |
| Non sostituisce WSL per Docker             | Backend usato da **Docker Desktop** |

💡 Mapping dischi: `C:\...` in Windows ↔︎ `/mnt/c/...` in WSL

---
