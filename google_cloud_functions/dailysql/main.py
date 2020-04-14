from google.cloud import bigquery
import logging
logging.basicConfig(level=logging.INFO)
from dataclasses import dataclass
import os


# Author: Artur Fejklowicz
@dataclass(frozen=True)
class Conf:
    sql_file = os.getenv("SQL_FILE", "sql/af-covid19.csse.dashboard.daily_insert.sql")


def main(event, context):
    logging.info(f"dailysql: START main().")
    if 'attributes' in event:
        objectId = event["attributes"]["objectId"]
        logging.info(f"dailysql: objectId: {objectId}")
        day = get_day(objectId)
        query = get_query(Conf.sql_file)
        execute(query, day)


def get_day(objectId):
    """
    Extracts date from loaded file path.
    :param objectId: path to the Blob on GS, ex: "csse/v3/day=2020-04-12/2020-04-12.csv"
    :return: String with date of day to load
    """
    logging.info(f"dailysql: READING DAY from PubSub message meta objectId: {objectId}")
    return objectId.split("/")[-2].split("=")[1]


def get_query(sql_file):
    logging.info(f"dailysql: LOADING QUERY from file: {sql_file}")
    f = open(sql_file, "r")
    query = f.read()
    f.close()
    return query


def execute(query, day):
    logging.info(f"dailysql: EXECUTING QUERY for day={day}")
    bq = bigquery.Client()

    job_config = bigquery.QueryJobConfig(
        query_parameters=[
            bigquery.ScalarQueryParameter("day", "DATE", day),
        ]
    )
    query_job = bq.query(query, job_config=job_config)  # Make an API request.
    rows = query_job.result()
    logging.info(query_job.state)

#if __name__ == '__main__':
#    logging.info("START main() from CLI.")
#    main()