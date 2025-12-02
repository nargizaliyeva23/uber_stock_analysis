use uber_stock_analysis;

select * from uber_stock;



# Daily Price Change Percentage 

select
date 
,open_price
,close_price
, round( ((close_price-open_price)/close_price)*100,2) as daily_change_percent
from uber_stock;


# Top 5 Days with Highest Trading Volume
SELECT *
FROM uber_stock
ORDER BY daily_volume DESC
LIMIT 5;


# 7-Day Moving Average (MA7)

SELECT 
    date,
    close_price,
    AVG(close_price) OVER (
        ORDER BY STR_TO_DATE(date, '%m/%d/%Y')
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS ma7
FROM uber_stock;

# Bullish / Bearish Day Classification
select 
date
,open_price
,close_price
, case when open_price>close_price then "Bullish" 
	  when open_price<close_price then "Bearish"
      else "Neutral" end as trend
from uber_stock
order by STR_TO_DATE(date, '%m/%d/%Y') desc;



# Longest Consecutive Uptrend Streak 
with t as (
select
date
,close_price
,lag(close_price) over ( order by STR_TO_DATE(date, '%m/%d/%Y') ) AS prev_close
,case when close_price > lag(close_price) over ( order by STR_TO_DATE(date, '%m/%d/%Y')) then 1 else 0 end as up_signal
FROM uber_stock
),

streaks as (
select
 date
 ,up_signal
 ,case when up_signal = 1 then 
                coalesce (lag(up_signal) over (order by STR_TO_DATE(date, '%m/%d/%Y')), 0) 
            else 0 end as streak
 from t
)
select MAX(streak) as longest_up_streak
from streaks;



# Monthly Average Closing Price
select 
date_format(str_to_date(date,'%m/%d/%Y'),'%b-%Y') as month
,round(avg(close_price),2) as avg_month_close
,MIN(STR_TO_DATE(date, '%m/%d/%Y')) AS real_month_date
from uber_stock
group by month
order by real_month_date ;




# Intraday Price Range (High–Low) 

select
date
,high_price - low_price as intraday_range
from uber_stock;


# Top 10 Most Volatile Days
select 
date
,high_price
,low_price
,(high_price - low_price) as volatility
from uber_stock
order by volatility desc
limit 10;


# Volume–Price Relationship Analysis
select 
date
,daily_volume
,close_price
, case when daily_volume> lag(daily_volume) over ( order by STR_TO_DATE(date, '%m/%d/%Y'))
		and close_price>lag (close_price) over ( order by STR_TO_DATE(date, '%m/%d/%Y')) then 'Both up'
		else 'no relation' end as relation_analysis
 from uber_stock
 order by STR_TO_DATE(date, '%m/%d/%Y');
 
 
 
 # Average Closing Price by Weekday
 select
str_to_date(date, '%m/%d/%Y') as date
,Dayname(str_to_date(date, '%m/%d/%Y')) As weekday
,close_price
From uber_stock
Order By Str_to_date(date, '%m/%d/%Y');



# 3-Day SMA and EMA Calculation
select
date
,close_price
, avg(close_price) over (
        order by str_to_date(date, '%m/%d/%Y')
        rows between 2 preceding and current row
    ) as sma3
from uber_stock;


# Yearly Bullish, Bearish, and Neutral Days Percentage Analysis
with yearly_data as (
    select
    year(STR_TO_DATE(date, '%m/%d/%Y')) AS year
	,close_price
     ,open_price
    FROM uber_stock
),

bull_bear as (
select 
year
, case when open_price>close_price then "Bullish" 
	  when open_price<close_price then "Bearish"
      else "Neutral" end as trend
from yearly_data
) 

select 
year
, round((sum( case when trend="Bullish" then 1 else 0 end ) / count(*)),2) as bullish_percentage
, round((sum( case when trend="Bearish" then 1 else 0 end ) / count(*)),2) as bearish_percentage
, round((sum( case when trend="Neutral" then 1 else 0 end ) / count(*)),2) as neutral_percentage
from bull_bear
group by year 
order by year ;

#Monthly Total Volume Ranking
select 
date_format(str_to_date(date,'%m/%d/%Y'),'%b-%Y') as month
,sum(daily_volume) AS total_volume
from uber_stock
group by month
order by total_volume desc;

 


# Analytical query showing price change and volume trend for the last day.
with prev_day as (
    select 
        STR_TO_DATE(date, '%m/%d/%Y') AS date
        ,daily_volume
        ,lag(daily_volume) over (order by STR_TO_DATE(date, '%m/%d/%Y')) as prev_volume
        ,open_price
        ,close_price
    from uber_stock
),
last_day as (
    select *
    from prev_day
    where date = (select MAX(STR_TO_DATE(date, '%m/%d/%Y')) from uber_stock)
)
select
    date
    ,open_price
    ,close_price
    ,daily_volume
    ,close_price - open_price AS price_change
    ,case
        when daily_volume > prev_volume then 'Up'
        when daily_volume < prev_volume then 'Down'
        else 'Stable'
    end as volume_trend
from last_day
order by price_change desc;


 
 
 