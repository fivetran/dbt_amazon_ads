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
