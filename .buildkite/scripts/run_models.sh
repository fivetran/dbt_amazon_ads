#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools

# Determine warehouse from step key pattern
WAREHOUSE=${BUILDKITE_STEP_KEY#run_dbt_}

# Install specific adapter for this warehouse
echo "Installing dbt adapter: dbt-${WAREHOUSE}"
pip install "dbt-${WAREHOUSE}>=1.3.0,<2.0.0"
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests

SCHEMA_VAR_NAME='amazon_ads_schema'

# Fetch central test scenario script
SCRIPT_VERSION="feature/buildkite-scripts"  # Use feature/buildkite-scripts branch
mkdir -p ../.buildkite/scripts
curl -f -s -o ../.buildkite/scripts/run_test_scenarios.py \
    "https://raw.githubusercontent.com/fivetran/dbt_package_automations/${SCRIPT_VERSION}/buildkite/scripts/run_test_scenarios.py"

# Run test scenarios using Python script (includes deps, seed, compile)
python3 ../.buildkite/scripts/run_test_scenarios.py "$db" "$SCHEMA_VAR_NAME" "$BUILD_SCHEMA"
