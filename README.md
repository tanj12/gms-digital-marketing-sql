# Digital Marketing Strategy Optimisation (SQL) — Google Merchandise Store

## Project Scope

- **Dataset:** US web sessions from the Google Merchandise Store (Oct 1 – Dec 31, 2016)  
- **Tools:** MySQL Workbench  
- **Techniques:** Advanced SQL including subqueries, window functions, aggregations, and joins  
- **Objective:** Transform raw session and traffic data into actionable insights for acquisition, retention, monetization, and mobile experience optimization  


---

## Key Insights at a Glance

This analysis of the Google Merchandise Store dataset (Oct–Dec 2016) uncovered clear performance patterns:

- **Seasonality drives sales** → December campaigns lifted revenue by ~25%.  
- **Conversion peaks on Mondays** → but traffic lags; boosting Monday visits is a quick win.  
- **Midweek engagement is highest** → Tuesday and Wednesday see the most active traffic.  
- **Mobile underperforms** → 25% of sessions but just 5% of revenue highlights a major UX gap.  
- **Regional skew** → Washington and Illinois customers spend far above average.  
- **Low retention** → 80% of visitors never return, signaling opportunity for loyalty and retargeting.  


---
![Device Monetize](../reports/11_web_monetize_device_chart2.png)    
![Channel Engagement](../reports/16_web_acq_mon_channel.png)
![Web Engagement](../reports/07_web_eng_day_graph.png)

### Check Out the scripts 👇
- [Data Exploration](../SQL/03_data_exploration.sql)
- [Identify Unique Duplicate Value](../SQL/06_unique_duplicate_identifier.sql)
- [Website Engagement By Day](../SQL/08_webengagement_day.sql)
- [Website Monetisation By Device](../SQL/11_web_monetization_device.sql)
- [Website Retention](../SQL/13_website_retention.sql)
- [Website Acquisition By Channel](../SQL/15_website_acquistion_channel.sql)
---

## DATASETS
We'll be exploring the [Google Merchandise Store](https://www.googlemerchandisestore.com/) dataset, containing data on website users from the US from October 1, 2016, to December 31, 2016. This dataset is sourced from the Google Merchandise Store, a real e-commerce platform offering Google-branded merchandise, including apparel, lifestyle products, and stationery from Google and its brands. While some sensitive fields have been obfuscated for privacy reasons, this dataset provides a unique opportunity to analyze actual customer behavior and trends in an e-commerce setting.

*Disclaimer: for this analysis, certain fields within the dataset have been aggregated. The original dataset is available as a public dataset in Google BigQuery.*

## SITUATION
The Google Marketing Team in the US was facing challenges in several key areas of its online business. Despite having a robust platform and a diverse range of products, the company was not fully leveraging its potential. With various strategies and channels in play, accurately assessing the impact of different marketing initiatives and proving their effectiveness to stakeholders proved to be quite challenging.
To address these challenges, the Google Marketing Team focused on gaining insights into several key areas:
- How do users interact with our e-commerce platform? Are there specific user behaviours or patterns that can inform our marketing strategies?
- How effective are our promotional campaigns and discount strategies in driving sales? Do these initiatives lead to long-term customer retention or only short-term gains?
- How does the user experience on our website and mobile app impact sales and customer engagement? Are there areas in need of improvement?
- Which geographical markets or customer segments are most profitable? Are there emerging markets or segments that we should focus on?
- How effective are our current strategies in acquiring new customers and retaining existing ones?
- Which traffic channels are yielding the highest conversion rates? What are the underlying reasons for variations in conversion rates across different channels?

## TASK
As the new marketing analyst at Google, my task involved conducting a detailed analysis of the e-commerce platform's performance. My main objective was to develop actionable strategies that would enhance overall performance. This included focusing on key areas such as customer acquisition, retention, monetization, and more efficient use of marketing channels. The ultimate aim was to significantly boost overall revenue.

## ACTION
In my role as a marketing analyst at Google, I used SQL to create a database and merge multiple datasets into a unified one for in-depth analysis, followed by thorough data preprocessing, including cleansing to ensure accuracy and reliability. I then conducted advanced analyses using advanced string, date and window functions to gain deeper insights into the website's performance, focusing on user interactions and the effectiveness of our e-commerce strategies. Additionally, I analyzed various web traffic sources to identify the most effective channels for driving sales and conversions, turning data into actionable business intelligence.

## SET UP
In MySQL Workbench, I create a new database called `gms_project`. This database will be used to store tables and data as part of this project.
- CREATE DATABASE `gms_project`;

![set up](../reports/01_setup.png)

## COMBINING DATASETS
Our first task is to create a unified view of the data across the three months. The combined dataset will serve as the base of our analysis.
```sql
CREATE TABLE gms_project.data_combined AS (

	SELECT * FROM gms_project.data_10

	UNION ALL 

	SELECT * FROM gms_project.data_11

	UNION ALL

	SELECT * FROM gms_project.data_12

);
```
### DATA EXPLORATION
To get a sense of the data we're working with, we’ll take a look at the first few rows of the table. This allows us to see what columns are available and the kind of data each column contains.
```sql
SELECT * FROM gms_project.data_combined
LIMIT 5;
```
![data exploration](../reports/02_data_exploration.png)
**Column Overview:** The dataset contains rows with identifiers like **`fullvisitorid`** and **`visitid`**, along with date of visits, and details of traffic sources in the **`channelGrouping`**, **`source`**, and **`medium`** columns. It offers insights into user engagement through metrics such as visits, pageviews, time on website, and bounces. Additionally, it includes e-commerce data like transactions and revenue, user-specific information (operating system, mobile device usage, device type), and geographical data (region, country, continent, subcontinent). Some fields, like **`adcontent`**, are missing data.

**Row Overview:** At first glance, it seems that each row represents a single session on the website. The **`visitid`** column appears to be a unique identifier for each session, and therefore, needs closer investigation. 

First, we’ll examine the **`visitid`** column for null values. Ensuring there are no NULL values in this key column is essential for the integrity of our dataset.
```sql
SELECT 
    COUNT(*) AS total_rows,
    COUNT(visitid) AS non_null_rows
FROM gms_project.data_combined;
```
![null](../reports/03_null.png)
It appears that there are no NULL values in the **`visitid`** column, indicating that each session captured in the data has been assigned an identifier. The absence of NULL values in this key column is a positive sign for data integrity.

Next, we'll check for duplicate values in the **`visitid`** column. Identifying duplicates is important as they can significantly impact the accuracy of our analysis. We'll determine whether these duplicates represent valid data repetitions or if they need to be addressed.
```sql
SELECT
		visitid,
		COUNT(*) as total_rows
FROM gms_project.data_combined
GROUP BY 1
HAVING COUNT(*) > 1
LIMIT 5;
```
![duplicate](../reports/04_duplicate.png)
The **`visitid`** column in the dataset, while seemingly unique, does not serve as a unique identifier for each session. This is because **`visitid`** represents the timestamp when a visit or session begins. Since multiple visitors can start their sessions at the same exact time, **`visitid`** alone is not sufficient to uniquely identify each session.

To create a unique identifier for each session, we need to combine **`visitid`** with another column, **`fullvisitorid`**. The **`fullvisitorid`** column uniquely identifies each visitor to the website. By concatenating **`fullvisitorid`** and **`visitid`**, we can create a new identifier that is unique for each session. This new identifier will ensure that each session is distinctly recognized, even if multiple sessions start at the same time.
```sql
SELECT
		CONCAT(fullvisitorid, '-', visitid) AS unique_session_id,
		COUNT(*) as total_rows
FROM gms_project.data_combined
GROUP BY 1
HAVING COUNT(*) > 1
LIMIT 5;
```
![unique identifier](../reports/05_unique_identifier.png)
From the analysis of the data, it appears that we still have two duplicate entries. This is likely due to how sessions are tracked around midnight. In many web analytics systems, a visitor's session is reset at midnight. This means that if a visitor is active on the website across midnight, their activity before and after midnight is counted as two separate sessions. However, if the **`visitid`** is based on the start time of the session, then the visitor will have the same **`visitid`** for both sessions. When we concatenate this **`visitid`** with the **`fullvisitorid`**, the resulting **`unique_session_id`** will be the same for both sessions. Therefore, despite being on the website across two different sessions (before and after midnight), the visitor appears in our data with the same **`unique_session_id`** for both sessions. Let’s examine one example.

*Note: Our dataset timestamps are in UTC (Coordinated Universal Time), the main time standard used globally, which remains constant year-round. As our analysis focuses on US data, we'll convert these timestamps to PDT (Pacific Daylight Time). PDT applies to the US and Canadian Pacific Time Zone during summer months, operating 7 hours behind UTC (UTC-7). In winter, this region switches to PST (Pacific Standard Time), which is 8 hours behind UTC.*

```sql
SELECT
		CONCAT(fullvisitorid, '-', visitid) AS unique_session_id,
		FROM_UNIXTIME(date) - INTERVAL 8 HOUR AS date,
	  COUNT(*) as total_rows
FROM gms_project.data_combined
GROUP BY 1,2
HAVING unique_session_id = "4961200072408009421-1480578925"
LIMIT 5;
```
![unique session](../reports/06_unique_session.png)

In our analysis, we acknowledge this scenario and have decided to treat these two sessions as a single continuous session, maintaining the same `unique_session_id`. This approach aligns with our analytical objectives and simplifies our dataset. Therefore, we won't modify the session tracking mechanism to separate these instances into distinct sessions.

## BUSINESS INSIGHTS
## Website Engagement by Day
Now that we have a basic understanding of our dataset, we're ready to delve into a more detailed analysis. First, we'll explore daily web traffic to gain insights into overall website performance. This initial step will reveal key traffic patterns and trends in visitor behavior.
Note: For simplicity, our analysis will use UTC time for all timestamps, avoiding the complexities of time zone conversions and Daylight Saving Time adjustments.

```sql
SELECT 
    date,
    COUNT(DISTINCT unique_session_id) AS sessions
FROM (
		SELECT
				DATE(FROM_UNIXTIME(date)) AS date,
	      CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
	  FROM gms_project.data_combined
	  GROUP BY 1,2
) t1
GROUP BY 1
ORDER BY 1;
```
![website engagement day](../reports/07_web_eng_day.png)
![graph](../reports/07_web_eng_day_graph.png)
We observe an uptick in web traffic as we approach the holiday season in December. In addition, web traffic consistently peaks during weekdays and tapers off during weekends. To better illustrate this trend, we'll extract the name of the day from the visit date.
```sql
SELECT 
    DAYNAME(date) AS weekday,
    COUNT(DISTINCT unique_session_id) AS sessions
FROM (
		SELECT
				DATE(FROM_UNIXTIME(date)) AS date,
        CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
    FROM gms_project.data_combined
    GROUP BY 1,2
) t1
GROUP BY 1
ORDER BY 2 DESC;
```
![engagement by weekday](../reports/08_web_eng_weekday.png)
We notice a variation in visitor numbers, with web traffic peaking mid-week, particularly on Tuesdays and Wednesdays, and then declining over the weekend. This pattern indicates that user engagement on the website fluctuates throughout the week. This insight can be crucial for planning content updates and marketing initiatives.

## Website Engagement & Monetization by Day
We can delve deeper into this trend by examining conversion rates to determine if these visits result in transactions. This analysis will provide a clearer understanding of how effectively web traffic is translating into actual sales.
```sql
SELECT 
    DAYNAME(date) AS weekday,
    COUNT(DISTINCT unique_session_id) AS sessions,
    SUM(converted) AS conversions,
		((SUM(converted)/COUNT(DISTINCT unique_session_id))*100) AS conversion_rate
FROM (
		SELECT
				DATE(FROM_UNIXTIME(date)) AS date,
        CASE
						WHEN transactions >= 1 THEN 1
						ELSE 0 
				END AS converted,
        CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
    FROM gms_project.data_combined
    GROUP BY 1,2,3
) t1
GROUP BY 1
ORDER BY 2 DESC;
```
![web monetization](../reports/10_web_monetize_day.png)
While `Tuesdays` see the most website visits, it's interesting to note that `Mondays` have the highest conversion rate. In contrast, weekends experience a substantial drop in conversions, indicating different visitor behaviors and purchasing patterns between weekdays and weekends.

## Website Engagement & Monetization by Device
We can further refine our analysis by examining the data by device type, which will reveal variations in conversion rates and visits across desktops, tablets, and smartphones. This device-specific insight is key for optimizing website design and marketing for each device category.

*Note: in the dataset, revenue is expressed in a scaled format, where the actual value is multiplied by 10^6. For instance, a revenue of $2.40 is recorded as 2,400,000. To interpret these figures accurately, we’ll divide them by 10^6 to get the original dollar amount.*
```sql
SELECT
		deviceCategory,
		COUNT(DISTINCT unique_session_id) AS sessions,
		((COUNT(DISTINCT unique_session_id)/SUM(COUNT(DISTINCT unique_session_id)) OVER ())*100) AS sessions_percentage,
		SUM(transactionrevenue)/1e6 AS revenue,
		((SUM(transactionrevenue)/SUM(SUM(transactionrevenue)) OVER ())*100) AS revenue_percentage
FROM (
		SELECT
				deviceCategory,
		    transactionrevenue,
				CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
		FROM gms_project.data_combined
		GROUP BY 1,2,3
) t1
GROUP BY 1;
```
![monetize device](../reports/11_web_monetize_device.png)
![chart 1](../reports/11_web_monetize_device_chart1.png)
![chart 2](../reports/11_web_monetize_device_chart2.png)
While ~25% of sessions originate from mobile devices, only 5% of revenue is generated through them. This significant discrepancy suggests a need to optimize the mobile shopping experience. Marketing strategies should focus on enhancing mobile usability, streamlining the checkout process, and tailoring mobile-specific promotions. Considering the significant number of users who shop on their mobile devices during commutes or workday breaks, a seamless mobile experience on our e-commerce platform is crucial. To further tap into this growing user base, Google might also consider developing a dedicated mobile app, which could substantially increase revenue from mobile users.

## Website Engagement & Monetization by Region
We can analyze these numbers further to determine if there are regional differences affecting mobile device usage and revenue generation. This deeper dive will help us understand whether certain regions have higher mobile engagement or sales, guiding targeted marketing strategies and region-specific optimizations.
```sql
SELECT
		deviceCategory,
		region,
		COUNT(DISTINCT unique_session_id) AS sessions,
    ((COUNT(DISTINCT unique_session_id)/SUM(COUNT(DISTINCT unique_session_id)) OVER ())*100) AS sessions_percentage,
		SUM(transactionrevenue)/1e6 AS revenue,
    ((SUM(transactionrevenue)/SUM(SUM(transactionrevenue)) OVER ())*100) AS revenue_percentage
FROM (
		SELECT
				deviceCategory,
        CASE
						WHEN region = '' OR region IS NULL THEN 'NA'
						ELSE region
				END AS region,
				transactionrevenue,
				CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
		FROM gms_project.data_combined
		WHERE deviceCategory = "mobile"
		GROUP BY 1,2,3,4
) t1
GROUP BY 1,2
ORDER BY 3 DESC;
```
![monetize region](../reports/12_web_monetize_region.png)
The data shows that while only 1% of mobile sessions are from Washington, they contribute to 11% of revenue. Similarly, Illinois sees 3% of sessions but accounts for 9% of revenue. This suggests an untapped opportunity, as these regions have higher conversion rates or transaction values despite fewer sessions. Focusing marketing efforts on these regions could potentially increase revenue, leveraging their higher purchasing effectiveness. Potential approaches could include targeted marketing campaigns, localized promotions, or even exploring the reasons behind the higher conversion rates, such as product preferences or purchasing power.

One limitation in our analysis arises from the fact that some mobile sessions in the dataset are not mapped to any specific region. This means that for a subset of mobile sessions, the **`region`** field is either left blank or marked as **`NULL`**, indicating that the geographic location of these users is unknown or not recorded. Addressing this issue with the Data Engineering team could be vital for ensuring more accurate and comprehensive data for future analyses.

## Website Retention
Next, we’ll examine website retention, specifically focusing on whether users are new or returning. This will provide insights into user loyalty and the effectiveness of strategies in encouraging repeat visits. Typically, having around 50-70% new users and 30-50% returning users is considered a good balance.
```sql
SELECT
	  CASE
		    WHEN newVisits = 1 THEN 'New Visitor'
		    ELSE 'Returning Visitor'
	  END AS visitor_type,
	  COUNT(DISTINCT fullVisitorId) AS visitors,
    ((COUNT(DISTINCT fullVisitorId)/SUM(COUNT(DISTINCT fullVisitorId)) OVER ())*100) AS visitors_percentage
FROM gms_project.data_combined
GROUP BY 1;
```
![retention](../reports/13_web_retention.png)
Interestingly, about 80% of users visit the website only once. This statistic suggests a need for better incentives or value propositions to encourage repeat visits, presenting a major opportunity for enhanced retention strategies such as personalized marketing, loyalty programs, or targeted retargeting campaigns. In contrast, the substantial influx of new visitors reflects successful marketing efforts in brand awareness, effectively attracting people to the site initially. Key factors like a user-friendly interface, engaging content, and smooth navigation play a crucial role here.

## Website Acquisition
Building on this analysis, the next logical step is to calculate the bounce rate. This measure is key as it indicates the proportion of visitors who exit the site after viewing only one page and is often used to evaluate the effectiveness of acquisition strategies. A high bounce rate can indicate that the landing page or the initial content isn't meeting the expectations of visitors or isn't engaging enough to encourage further exploration of the site or purchases. Understanding the bounce rate offers valuable insights into the site's initial engagement success with its audience.
```sql
SELECT
		COUNT(DISTINCT unique_session_id) AS sessions,
		SUM(bounces) AS bounces,
		((SUM(bounces)/COUNT(DISTINCT unique_session_id))*100) AS bounce_rate
FROM (
		SELECT
				bounces,
				CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
		FROM gms_project.data_combined
		GROUP BY 1,2
) t1
ORDER BY 1 DESC;
```
![acquisition](../reports/14_web_acquisition.png)
A bounce rate within the 20-40% range is generally seen as effective engagement. However, to truly understand visitor behavior and optimize engagement strategies, it's important to analyze the bounce rate by individual channels. This deeper analysis will enable us to tailor our strategies to specific audiences, refine our understanding of user interactions, and allocate marketing resources more efficiently.

## Website Acquisition by Channel
Moving forward, we'll delve into the bounce rate by channel to gain a clearer picture of the effectiveness of various marketing strategies. This will also shed light on user engagement across diverse traffic sources, providing valuable insights for optimizing our outreach efforts.
```sql
SELECT
		channelGrouping,
		COUNT(DISTINCT unique_session_id) AS sessions,
		SUM(bounces) AS bounces,
		((SUM(bounces)/COUNT(DISTINCT unique_session_id))*100) AS bounce_rate
FROM (
		SELECT
				channelGrouping,
		    bounces,
				CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
		FROM gms_project.data_combined
		GROUP BY 1,2,3
) t1
GROUP BY 1
ORDER BY 2 DESC;
```
![channel acquisition](../reports/15_web_acquisition_channel.png)
Organic Search, Paid Search, and Display exhibit bounce rates of 30-40%, indicating effective visitor engagement and an ability to encourage exploration beyond the landing page. Referral shows the lowest bounce rate, marking it as particularly healthy. However, Direct, Social, and Affiliates, with bounce rates of 40-50%, highlight areas where there is potential for improvement.

## Website Acquisition & Monetization by Channel
Building on our analysis of visits and bounce rates by channel, we'll next include key metrics like time on site, revenue, and conversion rate. This broader evaluation will give us a fuller view of each channel's performance, encompassing not only traffic volume but also user engagement quality, revenue generation efficiency, and overall conversion impact.
```sql
SELECT
		channelGrouping,
		COUNT(DISTINCT unique_session_id) AS sessions,
		SUM(bounces) AS bounces,
		((SUM(bounces)/COUNT(DISTINCT unique_session_id))*100) AS bounce_rate,
    (SUM(pageviews)/COUNT(DISTINCT unique_session_id)) AS avg_pagesonsite,
    (SUM(timeonsite)/COUNT(DISTINCT unique_session_id)) AS avg_timeonsite,
		SUM(CASE WHEN transactions >= 1 THEN 1 ELSE 0 END) AS conversions,
    ((SUM(CASE WHEN transactions >= 1 THEN 1 ELSE 0 END)/COUNT(DISTINCT unique_session_id))*100) AS conversion_rate,
		SUM(transactionrevenue)/1e6 AS revenue
FROM (
		SELECT
				channelGrouping,
        bounces,
        pageviews,
        timeonsite,
        transactions,
        transactionrevenue,
				CONCAT(fullvisitorid, '-', visitid) AS unique_session_id
	FROM gms_project.data_combined
	GROUP BY 1,2,3,4,5,6,7
) t1
GROUP BY 1
ORDER BY 2 DESC;
```
![channel monetization](../reports/16_web_acq_mon_channel.png)
Referral leads with the lowest bounce rate and highest conversion at 7%, driving strong revenue, making it a prime candidate for expanded partnerships. Organic Search, with the most sessions and a solid 32% bounce rate, shows robust SEO efficacy and good conversion potential. Direct traffic, while high at a 46% bounce rate, has moderate conversions, suggesting a need for more personalized engagement. Social media, despite high traffic, suffers from the lowest conversions, calling for more targeted campaigns. Paid Search and Display, both with 34% bounce rates, demonstrate moderate visitor retention but require improved targeting for better conversions. Lastly, Affiliates, with the highest bounce rate and lowest conversions, need a thorough evaluation of partner quality.

## RESULTS
### Leverage Seasonal Campaigns
- December’s holiday promotions produced a ~25% revenue uplift.
- Replicating themed campaigns in other high-traffic months could yield similar gains.
### Boost Monday Traffic
- Mondays convert well but attract fewer visitors.
- Driving just +10% more traffic (via “start-of-week” offers and targeted emails) could lift total conversions.
### Capitalise on Midweek Peaks
- Tuesdays and Wednesdays have the highest site traffic.
- Running timed promotions and ad pushes midweek ensures campaigns hit when customers are most active.
### Fix Mobile Revenue Gap
- Mobile = 25% of sessions but only 5% of revenue.
- Optimising the mobile checkout flow and offering mobile-specific discounts can unlock a significant revenue opportunity.
### Double Down on High-Value Regions
- Washington and Illinois users spend disproportionately more.
- Localised offers and targeted regional campaigns can capture this higher purchasing power.
### Improve Retention (80% one-time visitors)
- Four out of five visitors never return.
- Personalised onboarding, loyalty rewards, and retargeting ads should lift repeat visits by 10%.