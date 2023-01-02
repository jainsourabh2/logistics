cd ../ingest-pubsub
chmod +x ../terraform/scripts/get_latest_tag.sh
gcloud config set project $1
gcloud builds submit --tag gcr.io/$1/ingest-pubsub