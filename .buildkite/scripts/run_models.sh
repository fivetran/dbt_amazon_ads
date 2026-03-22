#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools

# Install specific adapter for this warehouse
echo "Installing dbt adapter: ${DBT_ADAPTER}"
pip install "${DBT_ADAPTER}>=1.3.0,<2.0.0"
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests

# Get schema variable name from workflow file
SCHEMA_VAR_NAME=$(grep -o 'schema_var_name: .*' ../.github/workflows/generate-docs.yml | cut -d' ' -f2 | tr -d '\r')

dbt deps
dbt seed --target "$db" --full-refresh
echo "=== Running dbt compile ==="
echo "Running: dbt compile --target \"$db\" --vars \"{${SCHEMA_VAR_NAME}: ${BUILD_SCHEMA}}\""
dbt compile --target "$db" --vars "{${SCHEMA_VAR_NAME}: ${BUILD_SCHEMA}}"
echo "✓ Successful compile"

# Run test scenarios using Python script
python3 ../.buildkite/scripts/run_test_scenarios.py "$db" "$SCHEMA_VAR_NAME" "$BUILD_SCHEMA"
