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

schema = "status:STRING,transaction_time:TIMESTAMP,item_id:INTEGER,customer_id:STRING,local_warehouse:INTEGER,customer_location:INTEGER,warehouse:INTEGER,supplier_id:INTEGER,package_id:STRING,price:INTEGER"

# Classes
 
class CreateRowFn_Order(beam.DoFn):

    def __init__(self, pipeline_options):
        
        self.instance_id = pipeline_options.bigtable_instance
        self.table_id = pipeline_options.bigtable_table_order
  
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

class CreateRowFn_Customer(beam.DoFn):

    def __init__(self, pipeline_options):
        
        self.instance_id = pipeline_options.bigtable_instance
        self.table_id = pipeline_options.bigtable_table_customer
  
    def process(self, element):
        
        from google.cloud.bigtable import row
        import datetime
        import json

        order_json = json.loads(element)
        key = order_json["customer_id"]
        transaction_time = datetime.datetime.strptime(order_json["transaction_time"],"%Y-%m-%d %H:%M:%S.%f")

        direct_row = row.DirectRow(row_key=key)
        direct_row.set_cell(
            'delivery_stats',
            'status',
            element,
            timestamp=transaction_time)
        
        yield direct_row

# Options

class Logistics(PipelineOptions):


pipeline_options = Logistics(
    save_main_session=True, 
    streaming=True,
    runner='DataflowRunner',
    bigtable_instance='logistics_inst',
    bigtable_table_order='logistics_order',
    bigtable_table_customer='logistics_customer')

def main(argv=None, save_main_session=True):
    import random

    parser = argparse.ArgumentParser()
    parser.add_argument("--project_id", default='on-prem-project-337210')
    parser.add_argument("--input_topic", default='logistics')
    parser.add_argument("--temp_location", default='gs://vitaming-demo/temp')
    parser.add_argument("--staging_location", default='gs://vitaming-demo/staging/')
    args, beam_args = parser.parse_known_args()

    #known_args = parser.parse_known_args(argv)

    #pipeline_options = PipelineOptions()
    #pipeline_options.view_as(SetupOptions).save_main_session = save_main_session
    beam_options = PipelineOptions(beam_args)
    with beam.Pipeline(options=beam_options) as p:   

        datasource = (p
            | 'ReadData' >> beam.io.ReadFromPubSub(topic=args.input_topic).with_output_types(bytes)
            | 'Reshuffle' >> beam.Reshuffle()
        )

        bigtable_streaming_write_order = (datasource
            | 'Conversion UTF-8 bytes to string for Order' >> beam.Map(lambda msg: msg.decode('utf-8'))
            | 'Conversion string to row object for Order' >> beam.ParDo(CreateRowFn_Order(pipeline_options)) 
            | 'Writing row object to Order BigTable' >> WriteToBigTable(project_id=args.project_id,
                              instance_id=pipeline_options.bigtable_instance,
                              table_id=pipeline_options.bigtable_table_order)
        )

        bigtable_streaming_write_customer = (datasource
            | 'Conversion UTF-8 bytes to string for Customer' >> beam.Map(lambda msg: msg.decode('utf-8'))
            | 'Conversion string to row object for Customer' >> beam.ParDo(CreateRowFn_Customer(pipeline_options)) 
            | 'Writing row object to Customer BigTable' >> WriteToBigTable(project_id=args.project_id,
                              instance_id=pipeline_options.bigtable_instance,
                              table_id=pipeline_options.bigtable_table_customer)
        )

        bigquery_streaming_write = (datasource
            | 'Json Parser' >> beam.Map(json.loads)
            | 'WriteToBigQuery' >> beam.io.WriteToBigQuery('{0}:logistics.logistics'.format(args.project_id), schema=schema,
                                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED)
        )

    result = p.run()
    result.wait_until_finish()

if __name__ == '__main__':
    logger = logging.getLogger().setLevel(logging.INFO)
    main()