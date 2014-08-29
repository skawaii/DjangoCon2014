#!/bin/bash

echo "==== Delete databases ===="
sudo -u postgres dropdb polldb
echo "Database dropped"
sudo -u postgres createdb -O polluser polldb
echo "Database created"

echo "==== Load demo database ===="
psql -Upolluser polldb < scripts/dump_sample_demo.sql
