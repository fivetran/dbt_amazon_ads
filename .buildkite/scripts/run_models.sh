#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools

# Install specific adapter for this database
echo "Installing dbt adapter: dbt-${1}"
pip install "dbt-${1}>=1.3.0,<2.0.0"
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

cd integration_tests

# Fetch central test scenario script
mkdir -p ../.buildkite/scripts
curl -f -s -o ../.buildkite/scripts/run_test_scenarios.py \
    "https://raw.githubusercontent.com/fivetran/dbt_package_automations/refs/heads/feature/buildkite-scripts/.buildkite/scripts/run_test_scenarios.py"

# Run test scenarios using Python script (includes deps, seed, compile)
# Test parameters and scenarios are configured in: integration_tests/ci/test_scenarios.yml
python3 ../.buildkite/scripts/run_test_scenarios.py "${1}" "${BUILD_SCHEMA}"
