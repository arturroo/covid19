from google.cloud import storage
import base64
import requests
import os
from dataclasses import dataclass
from datetime import datetime, timedelta
import logging
logging.basicConfig(level=logging.INFO)

# Author: Artur Fejklowicz
# Doku download: https://stackabuse.com/download-files-with-python/

@dataclass(frozen=True)
class Conf:
    project = os.getenv("GOOGLE_CLOUD_PROJECT", "af-covid19")
    bucket = os.getenv("BUCKET", "af-covid19-data")
    blob_prefix = os.getenv("BLOB_PREFIX", "csse/v3")
    partition_name = os.getenv("PARTITION_key", "day")


def main(event, context):
    # pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    import_date = (datetime.utcnow() - timedelta(1)).strftime('%Y-%m-%d')
    logging.info(f"sucker: Running for import_date {import_date}")
    r = get_file(import_date)
    save_in_google_storage(r, import_date) if r.status_code == 200 else logging.critical(f"sucker: CSSE Repo has no file for date {import_date}.")


def get_file(import_date):
    """
    Downloads the CSV data file from CSSE Github for particular date.
    :return:
    r: Request object
    """
    csv_date = datetime.strptime(import_date, '%Y-%m-%d').strftime('%m-%d-%Y')
    url = f"https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/{csv_date}.csv"
    logging.info(f"Downloading {url}")
    r = requests.get(url)
    logging.info(f"Get status: {r.status_code}")
    logging.info(f"Get encoding: {r.encoding}")
    return r


def save_in_google_storage(r, import_date):
    """
    Saves downloaded data as Google Storage object (Blob).
    Path (Blob name) is equal as Hive partitioning schema.
    :param r: Request result with content (data)
    :return:
    """
    gs = storage.Client(project=Conf.project)
    bucket = gs.get_bucket(Conf.bucket)
    blob_name = f"{Conf.blob_prefix}/{Conf.partition_name}={import_date}/{import_date}.csv"
    logging.info(f"Blob name: {blob_name}")
    blob = bucket.blob(blob_name)
    blob.upload_from_string(r.content)


if __name__ == '__main__':
    logging.info("START main() from CLI.")
    main()
