# Packages

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigtableio import WriteToBigTable
from google.cloud import pubsub_v1

# Classes
 
class CreateRowFn(beam.DoFn):

    def __init__(self, pipeline_options):
        
        self.instance_id = pipeline_options.bigtable_instance
        self.table_id = pipeline_options.bigtable_table
  
    def process(self, key):
        
        from google.cloud.bigtable import row
        import datetime

        #direct_row = row.DirectRow(row_key='key')
        direct_row = row.DirectRow(row_key='1234abcd#4321joe')
        direct_row.set_cell(
            'delivery_stats',
            'dataflow',
            'value1',
            timestamp=datetime.datetime.now())
        
        yield direct_row

# Options

class XyzOptions(PipelineOptions):
    
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_argument('--bigtable_project', default='tdbargolis1'),
        parser.add_argument('--bigtable_instance', default='vitg-inst'),
        parser.add_argument('--bigtable_table', default='logistics-cust')

pipeline_options = XyzOptions(
    save_main_session=True, 
    streaming=True,
    runner='DataflowRunner',
    project='tdbargolis1',
    region='asia-south1',
    temp_location='gs://vitaming-bucket-logs/temp/',
    staging_location='gs://vitaming-bucket-logs/staging/',
    bigtable_project='tdbargolis1',
    bigtable_instance='vitg-inst',
    bigtable_table='logistics-cust')

# Pipeline

def run (argv=None):
    
    with beam.Pipeline(options=pipeline_options) as p:
       
       input_subscription=f"projects/{PROJECT}/subscriptions/{SUBSCRIPTION}"

        _ = (p
                | 'Read from Pub/Sub' >> beam.io.ReadFromPubSub(subscription=input_subscription).with_output_types(bytes)
                | 'Conversion UTF-8 bytes to string' >> beam.Map(lambda msg: msg.decode('utf-8'))
                | 'Reshuffle' >> beam.Reshuffle()                
                | 'Conversion string to row object' >> beam.ParDo(CreateRowFn(pipeline_options)) 
                | 'Writing row object to BigTable' >> WriteToBigTable(project_id=pipeline_options.bigtable_project,
                                  instance_id=pipeline_options.bigtable_instance,
                                  table_id=pipeline_options.bigtable_table))

if __name__ == '__main__':
    run()