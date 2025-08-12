FROM odoo:17

# opzionale: evita cache pip
ENV PIP_NO_CACHE_DIR=1

# installa le tue dipendenze Python (es. xmltodict)
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

USER root
COPY --chmod=0755 --chown=odoo:root scripts/odoo-init.sh /usr/local/bin/odoo-init
USER odoo
