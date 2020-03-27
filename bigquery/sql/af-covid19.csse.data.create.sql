-- CREATE OR REPLACE VIEW `af-covid19.csse.data` AS
SELECT
    * EXCEPT(day)
    , null Latitude
    , null Longitude
    , day
FROM `af-covid19.csse.external_v1`
UNION ALL
SELECT
    *
FROM `af-covid19.csse.external_v2`
UNION ALL
SELECT
    Province_State
    , Country_Region
    , Last_Update
    , Confirmed
    , Deaths
    , Recovered
    , Lat Latitude
    , Long_ Longitude
    , day
FROM `af-covid19.csse.external_v3`
-- OPTIONS(
--     description='COVID19 data gathered by Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE). This view gathers CSSE data with different schemas.'
-- )
