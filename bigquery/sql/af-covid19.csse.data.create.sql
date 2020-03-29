-- CREATE OR REPLACE VIEW `af-covid19.csse.data`
-- OPTIONS(
--     description='COVID19 data gathered by Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE). This view gathers CSSE data with different schemas.'
-- ) AS
    SELECT
          Province_State
        , Country_Region
        , Last_Update
        , Confirmed
        , Deaths
        , Recovered
        , null Latitude
        , null Longitude
        , day
    FROM `af-covid19.csse.external_v1`
    WHERE
        day <= "2020-02-01"
UNION ALL
    SELECT
          Province_State
        , Country_Region
        , Last_Update
        , Confirmed
        , Deaths
        , Recovered
        , Latitude
        , Longitude
        , day
    FROM `af-covid19.csse.external_v2`
    WHERE
        day BETWEEN "2020-02-02" AND "2020-03-21"
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
    WHERE
        day >= "2020-03-22"
