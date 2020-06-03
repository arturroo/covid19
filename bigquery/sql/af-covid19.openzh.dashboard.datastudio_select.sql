SELECT
    * EXCEPT(rn)
    , AVG(new_ncumul_conf) OVER (PARTITION BY abbreviation_canton_and_fl ORDER BY rn ASC RANGE BETWEEN 12 PRECEDING AND CURRENT ROW) moving_average_new_ncumul_conf
--    , AVG(new_deaths)    OVER (PARTITION BY Country_Region ORDER BY rn ASC RANGE BETWEEN 12 PRECEDING AND CURRENT ROW) moving_average_new_deaths
--    , AVG(new_recovered) OVER (PARTITION BY Country_Region ORDER BY rn ASC RANGE BETWEEN 12 PRECEDING AND CURRENT ROW) moving_average_new_recovered
FROM (
    SELECT
        * EXCEPT(yesterday_ncumul_conf) --, yesterday_deaths, yesterday_recovered)
        , (ncumul_conf - yesterday_ncumul_conf) new_ncumul_conf
--        , (Deaths    - yesterday_deaths)    new_deaths
--        , (Recovered - yesterday_recovered) new_recovered
        , row_number() OVER (PARTITION BY abbreviation_canton_and_fl ORDER BY date ASC) rn
    FROM (
        SELECT
            *
            , LAG(ncumul_conf) OVER (PARTITION BY abbreviation_canton_and_fl ORDER BY date ASC) yesterday_ncumul_conf
--            , LAG(Deaths)    OVER (PARTITION BY Country_Region ORDER BY day ASC) yesterday_deaths
--            , LAG(Recovered) OVER (PARTITION BY Country_Region ORDER BY day ASC) yesterday_recovered
        FROM `af-covid19.openzh.data`
    ) Q1
) Q2