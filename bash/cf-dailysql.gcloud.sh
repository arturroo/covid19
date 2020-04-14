#################################################
# Create and deploy Cloud Function Dailysql
# Artur Fejklowicz
#################################################

# Create topic for scheduling data download
gcloud \
    pubsub topics create \
    trigger-dailysql \
    --message-storage-policy-allowed-regions=europe-west6

# Create subscription (like Kafka Consumer) to debug from command line interface
gcloud pubsub subscriptions create --topic trigger-dailysql trigger-dailysql.sub.cli

# Create stageing bucket for CF
# gsutil mb gs://af-covid19-stage

# Create CF Sucker for downloadinf the date from CSSE and save it to Google storage
gcloud \
    functions deploy \
    dailysql \
    --runtime=python37 \
    --region=europe-west1 \
    --stage-bucket=af-covid19-stage \
    --entry-point=main \
    --service-account=service-account@af-covid19.iam.gserviceaccount.com \
    --source=. \
    --trigger-topic=trigger-dailysql

# Create Google Storage trigger notofication
gsutil \
    notification create \
    -e OBJECT_FINALIZE \
    -f none \
    -p csse/ \
    -t trigger-dailysql \
    gs://af-covid19-data

#################################################
# Tests

# Check is message was recieved
gsutil cp requirements.txt  gs://af-covid19-data/csse/
# Get message from topic's subscription
gcloud pubsub subscriptions pull trigger-dailysql.sub.cli --limit 10
┌──────┬─────────────────┬─────────────────────────────────────────────────────────────────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ DATA │    MESSAGE_ID   │                                  ATTRIBUTES                                 │                                                                                        ACK_ID                                                                                        │
├──────┼─────────────────┼─────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 6��  │ 874148024150600 │ bucketId=af-covid19-data                                                    │ EU4EISE-MD5FU0RQBhYsXUZIUTcZCGhRDk9eIz81IChFFwtTE1FcdgNSEGszXHUHUQ0YdXxnJ21YFlUHE1l-VVsJPGh-Y30AVQwden1jcWtfEwcCRXu85pWikbmqbW87abq-i7lUVbiEkJQwZhg9XBJLLD5-LS1FQV5AEkwmGERJUytDCypY │
│      │                 │ eventTime=2020-04-11T22:53:08.843907Z                                       │                                                                                                                                                                                      │
│      │                 │ eventType=OBJECT_FINALIZE                                                   │                                                                                                                                                                                      │
│      │                 │ notificationConfig=projects/_/buckets/af-covid19-data/notificationConfigs/3 │                                                                                                                                                                                      │
│      │                 │ objectGeneration=1586645588844086                                           │                                                                                                                                                                                      │
│      │                 │ objectId=csse/requirements.txt                                              │                                                                                                                                                                                      │
│      │                 │ payloadFormat=NONE                                                          │                                                                                                                                                                                      │
└──────┴─────────────────┴─────────────────────────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘