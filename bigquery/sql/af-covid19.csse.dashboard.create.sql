CREATE OR REPLACE TABLE `af-covid19.csse.dashboard` 
OPTIONS(
    description="Materialized view for the dashboard, because DataStudio Map graph had problems with selecting day=X from this query."
)
AS
SELECT
    Country_Region
    , sum( Confirmed ) Confirmed
    , sum( Deaths ) Deaths
    , sum( Recovered ) Recovered
    , day
FROM (
    SELECT 
        *,
        row_number() OVER (PARTITION BY day, Country_Region, Province_State ORDER BY Last_Update desc) rn
    FROM (
        SELECT 
            CASE Country_Region
                WHEN "Mainland China" THEN "China"
                WHEN "Republic of Korea" THEN "South Korea"
                WHEN "Korea, South" THEN "South Korea"
                ELSE Country_Region
            END Country_Region
            , Province_State
            , Last_Update
            , Confirmed
            , Deaths
            , Recovered
            , day
        FROM `af-covid19.csse.data`
    ) Q1 
    WHERE 
      Country_Region in ("China", "South Korea", "Switzerland", "Germany", "Italy", "Spain", "France", "Poland")
) Q2
WHERE
    rn = 1
GROUP BY
    day, Country_Region
