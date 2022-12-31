echo "Please input project-id(This has to be unique)"
read project_id
echo "The input project-id is : " $project_id
search_string="<<project-id>>"
cd ../dataflow-pipeline/
echo "Replacing <<project_id>> in streaming-pubsub-to-bq-bigtable.py file"
sed -i "s/$search_string/$project_id/" "streaming-pubsub-to-bq-bigtable.py"
cd ../terraform