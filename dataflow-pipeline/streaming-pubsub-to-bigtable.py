# Packages

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigtableio import WriteToBigTable
from google.cloud import pubsub_v1
import json

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
        print("Element")
        print(element)
        print(type(element))
        print("OrderJSON")
        print(order_json)
        print(type(order_json))

        #direct_row = row.DirectRow(row_key='key')
        key = order_json["package_id"]

        direct_row = row.DirectRow(row_key=key)
        direct_row.set_cell(
            'delivery_stats',
            'status',
            element,
            timestamp=datetime.datetime.now())
        
        yield direct_row

# Options

class XyzOptions(PipelineOptions):
    
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_argument('--bigtable_project', default='on-prem-project-337210'),
        parser.add_argument('--bigtable_instance', default='vitg-inst'),
        parser.add_argument('--bigtable_table', default='logistics-cust')

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

# Pipeline

def run (argv=None):
    
    with beam.Pipeline(options=pipeline_options) as p:
        input_subscription=f"projects/on-prem-project-337210/subscriptions/transactions-subscibed"
        _ = (p
                | 'Read from Pub/Sub' >> beam.io.ReadFromPubSub(subscription=input_subscription).with_output_types(bytes)
                | 'Conversion UTF-8 bytes to string' >> beam.Map(lambda msg: msg.decode('utf-8'))
                #| 'Json Parser' >> beam.Map(json.loads)
                | 'Reshuffle' >> beam.Reshuffle()                
                | 'Conversion string to row object' >> beam.ParDo(CreateRowFn(pipeline_options)) 
                | 'Writing row object to BigTable' >> WriteToBigTable(project_id=pipeline_options.bigtable_project,
                                  instance_id=pipeline_options.bigtable_instance,
                                  table_id=pipeline_options.bigtable_table)
            )
if __name__ == '__main__':
    run()