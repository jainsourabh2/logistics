cd ../test-harness
cp generate_data_bkp.py generate_data.py
echo "Replacing <<service_url_ingest_pubsub>> in generate_data.py file"
sed -i "s%<<service_url_ingest_pubsub>>%$1%g" "generate_data.py"