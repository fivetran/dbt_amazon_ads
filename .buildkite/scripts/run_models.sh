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

# Set up base variables
BASE_VARS=""
if [[ -n "${BUILD_SCHEMA:-}" ]]; then
    BASE_VARS="\"amazon_ads_schema\": \"${BUILD_SCHEMA}\""
fi

# Define test scenarios - easy to add/modify
declare -a test_scenarios=(
    # Scenario 1: Default run
    "{${BASE_VARS}}"

    # Scenario 2: Portfolio history disabled
    "{${BASE_VARS}, \"amazon_ads__portfolio_history_enabled\": false}"
)

dbt deps
dbt seed --target "$db" --full-refresh

# Run each test scenario
for i in "${!test_scenarios[@]}"; do
    scenario_num=$((i + 1))
    vars="${test_scenarios[$i]}"

    echo "Running test scenario ${scenario_num}: ${vars}"
    dbt run --target "$db" --vars "$vars" --full-refresh
    dbt test --target "$db" --vars "$vars"
done
