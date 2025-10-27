# Amazon Ads dbt Package ([Docs](https://fivetran.github.io/dbt_amazon_ads/))

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_amazon_ads/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

## What does this dbt package do?
- Produces modeled tables that leverage Amazon Ads data from [Fivetran's connector](https://fivetran.com/docs/applications/amazon-ads) in the format described by [this ERD](https://fivetran.com/docs/applications/amazon-ads#schemainformation).
- Provides insight into your ad performance across the following grains:
  - Account, portfolio, campaign, ad group, ad, keyword, and search term
- Materializes output models designed to work simultaneously with our [multi-platform Ad Reporting package](https://github.com/fivetran/dbt_ad_reporting).
- Generates a comprehensive data dictionary of your source and modeled Amazon Ads data through the [dbt docs site](https://fivetran.github.io/dbt_amazon_ads/).

<!--section="amazon_ads_transformation_model"-->
The following table lists all tables that are materialized within this package by default.
> TIP: See more details about these tables in the package's [dbt docs site](https://fivetran.github.io/dbt_amazon_ads/#!/overview?g_v=1&g_e=seeds).

| **Table** | **Details** |
|-----------|-------------|
| [`amazon_ads__account_report`](https://fivetran.github.io/dbt_amazon_ads/#!/model/model.amazon_ads.amazon_ads__account_report) | Represents daily performance aggregated at the account level, including `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>How does performance compare across different accounts by account manager?</li><li>Are currency fluctuations affecting results across markets?</li></ul> |
| [`amazon_ads__ad_group_report`](https://fivetran.github.io/dbt_amazon_ads/#!/model/model.amazon_ads.amazon_ads__ad_group_report) | Represents daily performance at the ad group level, including `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>Which ad groups have the strongest engagement relative to their budget?</li><li>Do certain ad groups dominate impressions within a campaign?</li><li>Are new ad groups ramping up as expected after launch?</li></ul> |
| [`amazon_ads__ad_report`](https://fivetran.github.io/dbt_amazon_ads/#!/model/model.amazon_ads.amazon_ads__ad_report) | Represents daily performance at the individual ad level, including `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>Which ad creatives are driving the lowest cost per click?</li><li>Do expanded text ads perform better than responsive search ads?</li><li>How do performance trends change after refreshing ad copy?</li></ul> |
| [`amazon_ads__campaign_report`](https://fivetran.github.io/dbt_amazon_ads/#!/model/model.amazon_ads.amazon_ads__campaign_report) | Represents daily performance aggregated at the campaign level, including `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>Which campaigns are most efficient in terms of cost per conversion?</li><li>Are paused or limited-status campaigns still accruing impressions?</li><li>Which campaigns contribute most to overall spend or conversions?</li></ul> |
| [`amazon_ads__keyword_report`](https://fivetran.github.io/dbt_amazon_ads/#!/model/model.amazon_ads.amazon_ads__keyword_report) | Represents daily performance at the keyword level, enriched with account, campaign, ad group, and criterion context. Includes metrics such as `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>Which keywords are driving the highest quality traffic at the lowest cost?</li><li>Are branded vs. non-branded keywords performing differently?</li><li>Should underperforming keywords be reallocated to different match types?</li></ul> |
| [`amazon_ads__portfolio_report`](https://fivetran.github.io/dbt_amazon_ads/#!/model/model.amazon_ads.amazon_ads__portfolio_report) | Represents daily performance at the portfolio level, including `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>Which portfolios are delivering the best return on ad spend?</li><li>How do different portfolio strategies compare in terms of performance?</li><li>What are the spending trends across my portfolio segments?</li></ul> |
| [`amazon_ads__search_report`](https://fivetran.github.io/dbt_amazon_ads/#!/model/model.amazon_ads.amazon_ads__search_report) | Represents daily performance at the search term level, enriched with account, campaign, and ad group context. Includes metrics such as `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>What new search terms are emerging that I should add as keywords?</li><li>Which irrelevant search terms should be added as negatives to reduce wasted spend?</li><li>Are there seasonal shifts in search terms driving conversions?</li></ul> |

Many of the above reports are now configurable for [visualization via Streamlit](https://github.com/fivetran/streamlit_ad_reporting). Check out some [sample reports here](https://fivetran-ad-reporting.streamlit.app/ad_performance).

### Example Visualizations
Curious what these tables can do? The Amazon Ads models provide advertising performance data that can be visualized to track key metrics like spend, impressions, click-through rates, conversion rates, and return on ad spend across different campaign structures and time periods. Check out example visualizations in the [Fivetran Ad Reporting Streamlit App](https://fivetran-ad-reporting.streamlit.app/ad_performance), and see how you can use these tables in your own reporting. Below is a screenshot of an example dashboard; explore the app for more.

<p align="center">
  <a href="https://fivetran-ad-reporting.streamlit.app/ad_performance">
    <img src="https://raw.githubusercontent.com/fivetran/dbt_amazon_ads/main/images/streamlit_example.png" alt="Fivetran Ad Reporting Streamlit App" width="100%">
  </a>
</p>

### Materialized Models
Each Quickstart transformation job run materializes 30 models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.
<!--section-end-->

## How do I use the dbt package?
### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Amazon Ads connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

#### Databricks Dispatch Configuration
If you are using a Databricks destination with this package, you will need to add the following dispatch configuration (or a variation) within your `dbt_project.yml`. This is necessary to ensure that this package searches for macros in the `dbt-labs/spark_utils` package before searching the `dbt-labs/dbt_utils` package.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Step 2: Install the package (skip if also using the `ad_reporting` combo package)
Include the following amazon_ads package version in your `packages.yml` file _if_ you are not also using the upstream [Ad Reporting combination package](https://github.com/fivetran/dbt_ad_reporting):
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read dbt's Package Management documentation](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/amazon_ads
    version: [">=1.0.0", "<1.1.0"] # we recommend using ranges to capture non-breaking changes automatically
```

> All required sources and staging models are now bundled into this transformation package. Do not include `fivetran/amazon_ads_source` in your `packages.yml` since this package has been deprecated.

### Step 3: Define database and schema variables
By default, this package uses your destination and the `amazon_ads` schema. If your Amazon Ads data is in a different database or schema (for example, if your Amazon Ads schema is named `amazon_ads_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    amazon_ads_database: your_destination_name
    amazon_ads_schema: your_schema_name 
```

### Step 4: Disable models for non-existent sources
Your Amazon Ads connection may not sync every table that this package expects. If you do not have the `PORTFOLIO_HISTORY` table synced, add the following variable to your root `dbt_project.yml` file:

```yml
vars:
    amazon_ads__portfolio_history_enabled: False   # Disable if you do not have the portfolio table. Default is True.
```

### (Optional) Step 5: Additional configurations
<details open><summary>Expand/Collapse details</summary>

#### Union multiple connections
If you have multiple amazon_ads connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `amazon_ads_union_schemas` OR `amazon_ads_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
vars:
    amazon_ads_union_schemas: ['amazon_ads_usa','amazon_ads_canada'] # use this if the data is in different schemas/datasets of the same database/project
    amazon_ads_union_databases: ['amazon_ads_usa','amazon_ads_canada'] # use this if the data is in different databases/projects but uses the same schema name
```
> NOTE: The native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.

#### Passing Through Additional Metrics
By default, this package will select `clicks`, `impressions`, `cost`, `purchases_30_d`, and `sales_30_d` from the source reporting tables to store into the staging and end models. If you would like to pass through additional metrics to the package models, add the following configurations to your `dbt_project.yml` file. These variables allow the pass-through fields to be aliased (`alias`) if desired, but not required. Use the following format for declaring the respective pass-through variables:

> **Note** Make sure to exercise due diligence when adding metrics to these models. The metrics added by default have been vetted by the Fivetran team maintaining this package for accuracy. There are metrics included within the source reports, for example, metric averages, which may be inaccurately represented at the grain for reports created in this package. You want to ensure whichever metrics you pass through are indeed appropriate to aggregate at the respective reporting levels provided in this package.

```yml
vars:
    amazon_ads__campaign_passthrough_metrics: 
      - name: "new_custom_field"
        alias: "custom_field"
    amazon_ads__ad_group_passthrough_metrics:
      - name: "unique_string_field"
        transform_sql: "coalesce(unique_string_field, 'NA')"
    amazon_ads__advertised_product_passthrough_metrics: 
      - name: "new_custom_field"
        alias: "custom_field"
        transform_sql: "coalesce(custom_field, 'NA')" # reference alias in transform_sql if aliasing 
      - name: "a_second_field"
    amazon_ads__targeting_keyword_passthrough_metrics:
      - name: "this_field"
    amazon_ads__search_term_ad_keyword_passthrough_metrics:
      - name: "unique_string_field"
        alias: "field_id"
```

#### Changing the Build Schema
By default, this package will build the Amazon Ads staging models (11 views, 11 tables) within a schema titled (<target_schema> + `amazon_ads_source`) and the Amazon Ads intermediate (1 view) and end models (7 tables) within a schema titled (<target_schema> + `amazon_ads`) in your destination. If this is not where you would like your Amazon Ads staging and modeling data to be written, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    amazon_ads:
      +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
      staging:
        +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable. This is not available when running the package on multiple unioned connections.

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_amazon_ads/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    amazon_ads_<default_source_table_name>_identifier: your_table_name 
```

</details>

### (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for more details</summary>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).

</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Be aware that these dependencies are installed by default within this package. For more information on these packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of the dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/amazon_ads/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_amazon_ads/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Opinionated Decisions
In creating this package, which is meant for a wide range of use cases, we had to take opinionated stances on certain decisions, such as logic choices or column selection. Therefore, we have documented significant choices in the [DECISIONLOG.md](https://github.com/fivetran/dbt_amazon_ads/blob/main/DECISIONLOG.md) and will continue to update this as the package evolves. We are always open to and encourage feedback on these choices and the package in general.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

#### Contributors
We thank [everyone](https://github.com/fivetran/amazon_ads/graphs/contributors) who has taken the time to contribute. Each PR, bug report, and feature request has made this package better and is truly appreciated.

A special thank you to [Seer Interactive](https://www.seerinteractive.com/?utm_campaign=Fivetran%20%7C%20Models&utm_source=Fivetran&utm_medium=Fivetran%20Documentation), who we closely collaborated with to introduce native conversion support to our Ad packages.

## Are there any resources available?
- If you have questions or want to reach out for help, refer to the [GitHub Issue](https://github.com/fivetran/dbt_amazon_ads/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
