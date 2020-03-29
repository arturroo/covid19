SELECT
    * EXCEPT(yesterday_confirmed)
    , (Confirmed - yesterday_confirmed) new_confirmed
FROM (
    SELECT
        *,
        LAG(Confirmed) OVER (PARTITION BY Country_Region ORDER BY day ASC) yesterday_confirmed
    FROM `af-covid19.csse.dashboard`
)