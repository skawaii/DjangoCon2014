#!/bin/bash
pg_dump --username polluser -O polldb >> scripts/dump_sample_demo.sql
