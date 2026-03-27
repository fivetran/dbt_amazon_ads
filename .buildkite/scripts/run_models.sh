#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools

# Get warehouse from command line argument
db=$1
WAREHOUSE=$db

# Install specific adapter for this warehouse
echo "Installing dbt adapter: dbt-${WAREHOUSE}"
pip install "dbt-${WAREHOUSE}>=1.3.0,<2.0.0"

echo "Creating dbt config directory..."
mkdir -p ~/.dbt

echo "Copying profiles.yml..."
if [ -f "integration_tests/ci/sample.profiles.yml" ]; then
    cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml
    echo "Profiles.yml copied successfully"
else
    echo "ERROR: sample.profiles.yml not found!"
    exit 1
fi

echo "Current directory: $(pwd)"
echo "Changing to integration_tests directory..."
if [ -d "integration_tests" ]; then
    cd integration_tests
    echo "Successfully changed to integration_tests directory"
else
    echo "ERROR: integration_tests directory not found!"
    exit 1
fi

SCHEMA_VAR_NAME='amazon_ads_schema'

# Fetch central test scenario script
echo "Creating scripts directory..."
mkdir -p ../.buildkite/scripts

echo "Fetching test scenario script from feature/buildkite-scripts branch..."
SCRIPT_URL="https://raw.githubusercontent.com/fivetran/dbt_package_automations/refs/heads/feature/buildkite-scripts/.buildkite/scripts/run_test_scenarios.py"
echo "URL: ${SCRIPT_URL}"

if curl -f -s -o ../.buildkite/scripts/run_test_scenarios.py "${SCRIPT_URL}"; then
    echo "Successfully fetched test scenario script"
else
    echo "ERROR: Failed to fetch test scenario script (exit code: $?)"
    exit 1
fi

# Run test scenarios using Python script (includes deps, seed, compile)
python3 ../.buildkite/scripts/run_test_scenarios.py "$db" "$SCHEMA_VAR_NAME" "$BUILD_SCHEMA"
