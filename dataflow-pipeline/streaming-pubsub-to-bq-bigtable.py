from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
from google.cloud import pubsub_v1
from google.cloud import bigquery
import apache_beam as beam
import logging
import argparse
import json
import random
from apache_beam.io import fileio, filesystem
from apache_beam.io.gcp.bigtableio import WriteToBigTable

PROJECT="on-prem-project-337210"
schema = "status:STRING,transaction_time:TIMESTAMP,item_id:INTEGER,customer_id:STRING,local_warehouse:INTEGER,customer_location:INTEGER,warehouse:INTEGER,supplier_id:INTEGER,package_id:STRING,price:INTEGER"
TOPIC = "projects/on-prem-project-337210/topics/vitaming"


# Classes
 
class CreateRowFn(beam.DoFn):

    def __init__(self, pipeline_options):
        
        self.instance_id = pipeline_options.bigtable_instance
        self.table_id = pipeline_options.bigtable_table
  
    def process(self, element):
        
        from google.cloud.bigtable import row
        import datetime
        import json

        order_json = json.loads(element)
        key = order_json["package_id"]
        transaction_time = datetime.datetime.strptime(order_json["transaction_time"],"%Y-%m-%d %H:%M:%S.%f")

        direct_row = row.DirectRow(row_key=key)
        direct_row.set_cell(
            'delivery_stats',
            'status',
            element,
            timestamp=transaction_time)
        
        yield direct_row

# Options

class XyzOptions(PipelineOptions):
    
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_argument('--bigtable_project', default='on-prem-project-337210'),
        parser.add_argument('--bigtable_instance', default='vitg-inst'),
        parser.add_argument('--bigtable_table', default='logistics-cust')
        parser.add_argument("--input_topic", default='vitaming')

pipeline_options = XyzOptions(
    save_main_session=True, 
    streaming=True,
    runner='DataflowRunner',
    project='on-prem-project-337210',
    region='asia-south1',
    temp_location='gs://vitaming-demo/temp/',
    staging_location='gs://vitaming-demo/staging/',
    bigtable_project='on-prem-project-337210',
    bigtable_instance='vitg-inst',
    bigtable_table='logistics-cust')

def main(argv=None, save_main_session=True):
    import random

    parser = argparse.ArgumentParser()
    #known_args = parser.parse_known_args(argv)

    #pipeline_options = PipelineOptions()
    #pipeline_options.view_as(SetupOptions).save_main_session = save_main_session
    with beam.Pipeline(options=pipeline_options) as p:   

        datasource = (p
            | 'ReadData' >> beam.io.ReadFromPubSub(topic=TOPIC).with_output_types(bytes)
            | 'Reshuffle' >> beam.Reshuffle()
        )

        bigtable_streaming_write = (datasource
            | 'Conversion UTF-8 bytes to string' >> beam.Map(lambda msg: msg.decode('utf-8'))
            | 'Conversion string to row object' >> beam.ParDo(CreateRowFn(pipeline_options)) 
            | 'Writing row object to BigTable' >> WriteToBigTable(project_id=pipeline_options.bigtable_project,
                              instance_id=pipeline_options.bigtable_instance,
                              table_id=pipeline_options.bigtable_table)
        )

        bigquery_streaming_write = (datasource
            | 'Json Parser' >> beam.Map(json.loads)
            | 'WriteToBigQuery' >> beam.io.WriteToBigQuery('{0}:vitaming.logistics'.format(PROJECT), schema=schema,
                                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED)
        )

    result = p.run()
    result.wait_until_finish()

if __name__ == '__main__':
    logger = logging.getLogger().setLevel(logging.INFO)
    main()