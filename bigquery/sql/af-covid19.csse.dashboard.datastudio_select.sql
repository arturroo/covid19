SELECT
    *
    , AVG(new_confirmed) OVER (PARTITION BY Country_Region ORDER BY rn ASC RANGE BETWEEN @MA_ROWS PRECEDING AND CURRENT ROW) moving_average_new_confirmed
    , AVG(new_deaths)    OVER (PARTITION BY Country_Region ORDER BY rn ASC RANGE BETWEEN @MA_ROWS PRECEDING AND CURRENT ROW) moving_average_new_deaths
FROM (
    SELECT
        * EXCEPT(yesterday_confirmed, yesterday_deaths)
        , (Confirmed - yesterday_confirmed) new_confirmed
        , (Deaths    - yesterday_deaths)    new_deaths
        , row_number() OVER (PARTITION BY Country_Region ORDER BY day ASC) rn
    FROM (
        SELECT
            *
            , LAG(Confirmed) OVER (PARTITION BY Country_Region ORDER BY day ASC) yesterday_confirmed
            , LAG(Deaths)    OVER (PARTITION BY Country_Region ORDER BY day ASC) yesterday_deaths
        FROM `af-covid19.csse.dashboard`
    ) Q1
) Q2