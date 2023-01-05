cd ../dataflow-pipeline
pip install 'apache-beam[gcp]'
cp dataflow_generate_template_bkp.sh dataflow_generate_template.sh
cp streaming-pubsub-to-bq-bigtable_bkp.py streaming-pubsub-to-bq-bigtable.py
echo "Replacing <<project_id>> in dataflow_generate_template.sh file"
sed -i "s/<<project_id>>/$1/g" "dataflow_generate_template.sh"
echo "Replacing <<region_id>> in dataflow_generate_template.sh file"
sed -i "s/<<region_id>>/$2/g" "dataflow_generate_template.sh"
echo "Replacing <<project_id>> in streaming-pubsub-to-bq-bigtable.py file"
sed -i "s/<<project_id>>/$1/g" "streaming-pubsub-to-bq-bigtable.py"
chmod +x dataflow_generate_template.sh
sh ./dataflow_generate_template.sh