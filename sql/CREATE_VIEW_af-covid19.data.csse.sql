CREATE OR REPLACE VIEW `af-covid19.data.csse` AS
SELECT
    *
FROM `af-covid19.data.csse_ext`
UNION ALL
SELECT
    * EXCEPT(day)
    , null Latitude
    , null Longitude
    , day
FROM `af-covid19.data.csse_ext_different_timestamp`
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
FROM `af-covid19.data.csse_ext_ts_ymd_hms`
