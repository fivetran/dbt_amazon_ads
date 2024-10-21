# Decision Log

## Amazon Ads Accounts and Portfolios
- The models `amazon_ads__account_report` and `amazon_ads__portfolio_report` are aggregated from the campaign-level reports provided by Amazon Ads. This approach was necessary since Amazon Ads does not provide reporting at these levels, and the campaign reports are the broadest Amazon Ads provides.
- Accounts:
    - Broadest grain report
    - While the term "account" by Amazon Ad's definition would summarize all metrics under one advertiser and definitively result in a one-line report, the account report uses `profile_id` as the grain. Our understanding is that Amazon provides a `profile_id` for each market/country in which an advertiser operates, and the intention is to provide a more meaningful aggregation at the country level if it applies.  
- Portfolios:
    - Grain is narrower than Accounts but broader than Campaigns
    - This is a newer feature that is optional, so not all advertisers may not utilize portfolios. It is also possible that even if portfolios are being used, not all campaigns may be assigned to a portfolio. Arguably this report may not be entirely necessary, however since portfolios are a budgeting aid, we wanted to include a report with this grain.


## Why don't metrics add up across different grains (Ex. ad level vs campaign level)?
When aggregating metrics like clicks and spend across different grains, discrepancies can arise due to differences in how data is captured, grouped, or attributed at each grain. For example, certain actions or costs might be attributed differently at the ad, campaign, or ad group level, leading to inconsistencies when rolled up. Additionally, for example, at the keyword grain, where a keyword can belong to multiple ad groups, aggregations can lead to over counting. Conversely, some ads may only be represented at the ad group level, rather than individual ad levels, leading to under counting at the ad grain.

This is a reason why we have broken out the ad reporting packages into separate hierarchical end models (Ad, Ad Group, Campaign, and more). Because if we only used ad-level reports, we could be missing data.