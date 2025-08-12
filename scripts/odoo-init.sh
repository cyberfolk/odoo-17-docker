#!/usr/bin/env bash
set -euo pipefail
odoo -c /etc/odoo/odoo.conf \
  --db_host="${DB_HOST}" \
  --db_port="${DB_PORT}" \
  --db_user="${DB_USER}" \
  --db_password="${DB_PASSWORD}" \
  -d 17_odoo_init -i base --without-demo=all
