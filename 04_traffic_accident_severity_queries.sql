/* 
04_traffic_accident_severity_queries.sql
Author: Budhaditya Das

Assumed table:

TABLE accidents (
    accident_id          INT PRIMARY KEY,
    accident_date        DATE,
    day_of_week          VARCHAR(10),
    time_of_day          VARCHAR(10),    -- e.g. 'Morning', 'Afternoon'
    road_type            VARCHAR(50),
    weather_conditions   VARCHAR(50),
    light_conditions     VARCHAR(50),
    urban_or_rural       VARCHAR(10),    -- 'Urban' or 'Rural'
    casualty_severity    INT             -- 1 = Fatal, 2 = Serious, 3 = Slight
);
*/

-- 1. Distribution of casualty severity
SELECT 
    casualty_severity,
    COUNT(*) AS count_cases,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_cases
FROM accidents
GROUP BY casualty_severity
ORDER BY casualty_severity;

-- 2. Severity by road type
SELECT 
    road_type,
    casualty_severity,
    COUNT(*) AS count_cases
FROM accidents
GROUP BY road_type, casualty_severity
ORDER BY road_type, casualty_severity;

-- 3. When are severe accidents (1 + 2) more likely? (by time of day)
SELECT 
    time_of_day,
    COUNT(*) FILTER (WHERE casualty_severity IN (1,2)) AS severe_cases,
    COUNT(*) AS total_cases,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE casualty_severity IN (1,2)) 
        / NULLIF(COUNT(*),0), 2
    ) AS severe_rate_pct
FROM accidents
GROUP BY time_of_day
ORDER BY severe_rate_pct DESC;

-- 4. Rolling 7-day count of serious+fatal accidents (requires date support)
SELECT 
    accident_date,
    SUM(CASE WHEN casualty_severity IN (1,2) THEN 1 ELSE 0 END) AS daily_severe,
    SUM(SUM(CASE WHEN casualty_severity IN (1,2) THEN 1 ELSE 0 END))
        OVER (ORDER BY accident_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
        AS rolling_7day_severe
FROM accidents
GROUP BY accident_date
ORDER BY accident_date;
