cd ../ingest-pubsub
gcloud config set project $1
gcloud builds submit --tag gcr.io/$1/ingest-pubsub