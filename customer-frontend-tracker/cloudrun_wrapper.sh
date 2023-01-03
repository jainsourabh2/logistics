cd ../customer-frontend-tracker
cp src/components/CustomerLookupForm/index_bkp.js src/components/CustomerLookupForm/index.js
echo "Replacing <<service_url_order_frontend>> in src/components/CustomerLookupForm/index.js file"
sed -i "s%<<service_url_order_frontend>>%$2%g" "src/components/CustomerLookupForm/index.js"
gcloud config set project $1
gcloud builds submit --tag gcr.io/$1/order-frontend