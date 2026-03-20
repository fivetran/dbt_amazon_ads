#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools

# Install specific adapter for this warehouse or fall back to full requirements
if [[ -n "${DBT_ADAPTER:-}" ]]; then
    echo "Installing specific dbt adapter: ${DBT_ADAPTER}"
    pip install "${DBT_ADAPTER}>=1.3.0,<2.0.0"
else
    echo "Installing all adapters from requirements.txt"
    pip install -r integration_tests/requirements.txt
fi
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
dbt seed --target "$db" --full-refresh
dbt run --target "$db" --full-refresh
dbt test --target "$db"
dbt run --vars '{amazon_ads__portfolio_history_enabled: false}' --target "$db" --full-refresh
dbt test --vars '{amazon_ads__portfolio_history_enabled: false}' --target "$db"
