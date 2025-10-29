#!/bin/bash
PGPASSWORD='Yr@dNwcvZ&Mz' psql -h T24-DB -U t24 -d BANCA -c 'SELECT * FROM "public"."F_TSA_STATUS";'

