# dbt_amazon_ads v1.0.0
[PR #26](https://github.com/fivetran/dbt_amazon_ads/pull/26) includes the following updates:

## Breaking Changes
> A `--full-refresh` is required after upgrading to this release.

### Source Package Consolidation
- Consolidated `dbt_amazon_ads_source` into this package.
- All functionality from the source package has been merged into this transformation package. Be sure to:
  - Remove `fivetran/amazon_ads_source` from `packages.yml`
  - Delete any `source:` overrides that reference the source package

### dbt Fusion Compatibility Updates
- For compatibility with dbt Fusion versions >= 1.10.6:
    - Removed `dbt_utils.unique_combination_of_columns` tests
    - Removed `accepted_values` tests
    - In src_amazon_ads.yml, moved `loaded_at_field: _fivetran_synced` under the `config:` block.

### Schema Configuration Updates
- Some customizations have changed, refer to the [README](https://github.com/fivetran/dbt_amazon_ads/blob/main/README.md) for details.

# dbt_amazon_ads v0.5.0

[PR #23](https://github.com/fivetran/dbt_amazon_ads/pull/23) includes the following updates:

## Breaking Change for dbt Core < 1.9.6
> *Note: This is not relevant to Fivetran Quickstart users.*

Migrated `freshness` from a top-level source property to a source `config` in alignment with [recent updates](https://github.com/dbt-labs/dbt-core/issues/11506) from dbt Core ([Source PR #24](https://github.com/fivetran/dbt_amazon_ads_source/pull/24)). This will resolve the following deprecation warning that users running dbt >= 1.9.6 may have received:

```
[WARNING]: Deprecated functionality
Found `freshness` as a top-level property of `amazon_ads` in file
`models/src_amazon_ads.yml`. The `freshness` top-level property should be moved
into the `config` of `amazon_ads`.
```

**IMPORTANT:** Users running dbt Core < 1.9.6 will not be able to utilize freshness tests in this release or any subsequent releases, as older versions of dbt will not recognize freshness as a source `config` and therefore not run the tests.

If you are using dbt Core < 1.9.6 and want to continue running Amazon Ads freshness tests, please elect **one** of the following options:
  1. (Recommended) Upgrade to dbt Core >= 1.9.6
  2. Do not upgrade your installed version of the `amazon_ads` package. Pin your dependency on v0.4.0 in your `packages.yml` file.
  3. Utilize a dbt [override](https://docs.getdbt.com/reference/resource-properties/overrides) to overwrite the package's `amazon_ads` source and apply freshness via the [old](https://github.com/fivetran/dbt_amazon_ads_source/blob/main/models/src_amazon_ads.yml#L11-L13) top-level property route. This will require you to copy and paste the entirety of the `src_amazon_ads.yml` [file](https://github.com/fivetran/dbt_amazon_ads_source/blob/main/models/src_amazon_ads.yml#L4-L369) and add an `overrides: amazon_ads_source` property.

## Under the Hood
- Updated the package maintainer PR template.

## Documentation
- Added Quickstart model counts to README. ([#21](https://github.com/fivetran/dbt_amazon_ads/pull/21))
- Corrected references to connectors and connections in the README. ([#21](https://github.com/fivetran/dbt_amazon_ads/pull/21))
- Updated LICENSE.
- Updated README headers.

# dbt_amazon_ads v0.4.0
[PR #16](https://github.com/fivetran/dbt_amazon_ads/pull/16) includes the following updates:

## Feature Update: Conversions Support
- We have added conversion metrics to each of the end models by default.
- The conversion metrics are the following:
  - `purchases_30_d`: Number of attributed conversion events occurring within 30 days of an ad click.
  - `sales_30_d`: Total value of sales occurring within 30 days of an ad click.
- To bring in other conversion fields (`purchases_same_sku_30_d`, `sales_14_d`, etc.), please refer to our [passthrough column variables](https://github.com/fivetran/dbt_amazon_ads_source?tab=readme-ov-file#passing-through-additional-metrics).

> The above new field additions are **breaking changes** for users who were not already bringing in conversion fields via passthrough columns.

## Under the Hood
- Created `amazon_ads_persist_pass_through_columns` macro to ensure that the new conversion fields are backwards compatible with users who have already included them via [passthrough columns](https://github.com/fivetran/dbt_amazon_ads?tab=readme-ov-file#passing-through-additional-metrics) . The package will dynamically avoid "duplicate column" errors.
- Added integrity and consistency validation tests within `integration_tests` folder for the transformation models (to be used by maintainers only).
- Added documentation explaining potential discrepancies across reporting grains. See the [DECISIONLOG.md](https://github.com/fivetran/dbt_amazon_ads/blob/main/DECISIONLOG.md).

# dbt_amazon_ads v0.3.0
[PR #11](https://github.com/fivetran/dbt_amazon_ads/pull/11) includes the following updates:
## Feature update 🎉
- Unioning capability! This adds the ability to union source data from multiple amazon_ads connectors. Refer to the [Union Multiple Connectors README section](https://github.com/fivetran/dbt_amazon_ads/blob/main/README.md#union-multiple-connectors) for more details.

## Under the hood 🚘
- In the source package, updated tmp models to union source data using the `fivetran_utils.union_data` macro. 
- To distinguish which source each field comes from, added `source_relation` column in each staging and downstream model and applied the `fivetran_utils.source_relation` macro.
  - The `source_relation` column is included in all joins in the transform package. 
- Updated tests to account for the new `source_relation` column.

# dbt_amazon_ads v0.2.0
[PR #6](https://github.com/fivetran/dbt_amazon_ads/pull/6) includes the following updates:
## 🚨 Breaking changes
- This release is labeled breaking since changes made in [dbt_amazon_ads_source](https://github.com/fivetran/dbt_amazon_ads_source) are breaking. Note that columns in this package are unchanged.
- Further details are available in the [dbt_amazon_ads_source CHANGELOG](https://github.com/fivetran/dbt_amazon_ads_source/blob/main/CHANGELOG.md).
## 🎉 Features
- Updated documentation to reference changes in the source package.

 ## 🚘 Under the Hood
- Updated testing seed data to reflect the source seed changes.

 [PR #4](https://github.com/fivetran/dbt_amazon_ads/pull/4) includes the following updates:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).

 # dbt_amazon_ads v0.1.0
🎉 This is the initial release of this package! 🎉
## 📣 What does this dbt package do?
- Produces modeled tables that leverage Amazon Ads data from [Fivetran's connector](https://fivetran.com/docs/applications/amazon-ads) in the format described by [this ERD](https://fivetran.com/docs/applications/amazon-ads#schemainformation) and builds off the output of our [Amazon Ads source package](https://github.com/fivetran/dbt_amazon_ads_source).
- Provides insight into your ad performance across the following grains:
  - Account, portfolio, campaign, ad group, ad, keyword, and search term
- Materializes output models designed to work simultaneously with our [multi-platform Ad Reporting package](https://github.com/fivetran/dbt_ad_reporting).
- Generates a comprehensive data dictionary of your source and modeled Amazon Ads data through the [dbt docs site](https://fivetran.github.io/dbt_amazon_ads/).
