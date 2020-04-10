gcloud \
    pubsub topics create \
    scheduler-sucker \
    --message-storage-policy-allowed-regions=europe-west6

gsutil mb gs://af-covid19-stage

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
