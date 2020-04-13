from google.cloud import bigquery
import logging
logging.basicConfig(level=logging.INFO)

# Author: Artur Fejklowicz
@dataclass(frozen=True)
class Conf:
    project = os.getenv("GOOGLE_CLOUD_PROJECT", "af-covid19")
    bucket = os.getenv("BUCKET", "af-covid19-data")
    blob_prefix = os.getenv("BLOB_PREFIX", "csse/v3")
    partition_name = os.getenv("PARTITION_key", "day")
    import_date = (datetime.now() - timedelta(1)).strftime('%Y-%m-%d')

def main(event, context):
    logging.info(f"START main().")
    day = get_day(context["objectId"])
    query = get_query()
    execute(query)


def get_day(objectId):
    # objectId = "csse/v3/day=2020-04-12/2020-04-12.csv"
    return objectId.split("/")[-2].split("=")[1]


def get_query():



if __name__ == '__main__':
    logging.info("START main() from CLI.")
    main()