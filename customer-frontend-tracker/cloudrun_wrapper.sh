cd ../customer-frontend-tracker
gcloud config set project $1
gcloud builds submit --tag gcr.io/$1/order-frontend