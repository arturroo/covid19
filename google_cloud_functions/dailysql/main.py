from google.cloud import bigquery
import logging
logging.basicConfig(level=logging.INFO)

# Author: Artur Fejklowicz

def main(event, context):
    logging.info(f"START main().")



if __name__ == '__main__':
    logging.info("START main() from CLI.")
    main()