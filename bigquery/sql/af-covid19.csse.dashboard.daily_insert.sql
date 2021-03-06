-- old file, new moved to google_cloud_functions/dailysql/sql/af-covid19.csse.dashboard.daily_insert.sql
INSERT INTO `af-covid19.csse.dashboard` (
      Country_Region
    , Confirmed
    , Deaths
    , Recovered
    , day 
)
SELECT
      Country_Region
    , sum( Confirmed ) Confirmed
    , sum( Deaths ) Deaths
    , sum( Recovered ) Recovered
    , day
FROM (
    SELECT 
        *,
        row_number() OVER (PARTITION BY day, Country_Region, Province_State, City ORDER BY Last_Update desc) rn
    FROM (
        SELECT 
              Admin2 City
            , Province_State
            , CASE Country_Region
                WHEN "Mainland China" THEN "China"
                WHEN "Republic of Korea" THEN "South Korea"
                WHEN "Korea, South" THEN "South Korea"
                ELSE Country_Region
            END Country_Region
            , Last_Update
            , Confirmed
            , Deaths
            , Recovered
            , day
        FROM `af-covid19.csse.external_v3`
        WHERE
            day = @day
    ) Q1 
    WHERE 
      Country_Region in ("Austria", "China", "France", "Germany", "Italy", "Japan", "Poland", "Spain", "South Korea", "Sweden", "Switzerland", "US")
) Q2
WHERE
    rn = 1
GROUP BY
    day, Country_Region
