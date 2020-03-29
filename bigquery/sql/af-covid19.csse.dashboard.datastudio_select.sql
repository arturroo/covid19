SELECT
    * EXCEPT(yesterday_confirmed, yesterday_deaths)
    , (Confirmed - yesterday_confirmed) new_confirmed
    , (Deaths - yesterday_deaths) new_deaths
FROM (
    SELECT
        *
        , LAG(Confirmed) OVER (PARTITION BY Country_Region ORDER BY day ASC) yesterday_confirmed
        , LAG(Deaths) OVER (PARTITION BY Country_Region ORDER BY day ASC) yesterday_deaths
    FROM `af-covid19.csse.dashboard`
)