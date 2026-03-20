#!/usr/bin/env python3
"""
Run dbt test scenarios from YAML configuration
"""

import yaml
import json
import subprocess
import sys
import os
from pathlib import Path


def load_scenarios(config_file):
    """Load test scenarios from YAML file"""
    with open(config_file, 'r') as f:
        return yaml.safe_load(f)


def run_dbt_command(cmd, cwd=None):
    """Run a dbt command and handle errors"""
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=cwd)
    if result.returncode != 0:
        print(f"Command failed: {' '.join(cmd)}")
        return False
    return True


def main():
    if len(sys.argv) != 4:
        print("Usage: run_test_scenarios.py <target> <schema_var_name> <build_schema>")
        sys.exit(1)

    target = sys.argv[1]
    schema_var_name = sys.argv[2]
    build_schema = sys.argv[3]

    # Load scenarios
    config_file = Path('ci/test_scenarios.yml')
    if not config_file.exists():
        print(f"Error: {config_file} not found")
        sys.exit(1)

    config = load_scenarios(config_file)

    print(f"Running test scenarios for target: {target}")
    print(f"Schema variable: {schema_var_name} = {build_schema}")

    # Always run default scenario first
    def run_scenario(scenario_vars, scenario_name, full_refresh=True):
        print(f"\n=== Running {scenario_name} ===")

        # Build vars dict
        vars_dict = scenario_vars.copy()
        if build_schema:
            vars_dict[schema_var_name] = build_schema

        vars_json = f"'{json.dumps(vars_dict)}'"
        refresh_flag = "--full-refresh" if full_refresh else ""
        print(f"Variables: {vars_json}")
        print(f"Full refresh: {full_refresh}")

        # Run dbt commands
        run_cmd = ['dbt', 'run', '--target', target, '--vars', vars_json]
        if full_refresh:
            run_cmd.append('--full-refresh')

        test_cmd = ['dbt', 'test', '--target', target, '--vars', vars_json]

        # Execute commands
        if not run_dbt_command(run_cmd):
            print(f"dbt run failed for {scenario_name}")
            sys.exit(1)

        if not run_dbt_command(test_cmd):
            print(f"dbt test failed for {scenario_name}")
            sys.exit(1)

    # Run default scenario first (always full refresh)
    run_scenario({}, "default scenario", full_refresh=True)

    # Run additional test scenarios
    for i, scenario in enumerate(config.get('test_scenarios', []), 2):
        scenario_vars = scenario.get('vars', {})
        full_refresh = scenario.get('full_refresh', True)  # Default to true if not specified
        run_scenario(scenario_vars, f"test scenario {i}", full_refresh)

    print("\n=== All test scenarios completed successfully! ===")


if __name__ == "__main__":
    main()