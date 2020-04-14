#################################################
# Create and deploy Cloud Function Sucker
# Artur Fejklowicz
#################################################

# Create topic for scheduling data download
gcloud \
    pubsub topics create \
    scheduler-sucker \
    --message-storage-policy-allowed-regions=europe-west6

# Create subscription (like Kafka Consumer) to debug from command line interface
gcloud pubsub subscriptions create --topic scheduler-sucker scheduler-sucker.sub.cli

# Create stageing bucket for CF
gsutil mb gs://af-covid19-stage

# Create CF Sucker for downloadinf the date from CSSE and save it to Google storage
gcloud \
    functions deploy \
    sucker \
    --runtime=python37 \
    --region=europe-west1 \
    --stage-bucket=af-covid19-stage \
    --entry-point=main \
    --service-account=service-account@af-covid19.iam.gserviceaccount.com \
    --source=. \
    --trigger-topic=scheduler-sucker

# Create Cron Job
gcloud \
    scheduler jobs create pubsub \
    sucker \
    --schedule="0 4 * * *" \
    --topic=scheduler-sucker \
    --message-body=1 \

