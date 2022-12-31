cd ..
cp dataflow_generate_template_bkp.sh dataflow_generate_template.sh
echo $1
echo "Replacing <<project_id>> in dataflow_generate_template.sh file"
sed -i "s/<<project_id>>/$1/g" "dataflow_generate_template.sh"
echo "Replacing <<project_id>> in streaming-pubsub-to-bq-bigtable.py file"
sed -i "s/<<project_id>>/$1/g" "streaming-pubsub-to-bq-bigtable.py"
chmod +x dataflow_generate_template.sh
sh ./dataflow_generate_template.sh