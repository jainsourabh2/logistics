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

PROJECT="on-prem-project-337210"
schema = "status:STRING,transaction_time:TIMESTAMP,item_id:INTEGER,customer_id:STRING,local_warehouse:INTEGER,customer_location:INTEGER,warehouse:INTEGER,supplier_id:INTEGER,package_id:STRING,price:INTEGER"
TOPIC = "projects/on-prem-project-337210/topics/vitaming"

class GetTimestamp(beam.DoFn):
 def process(self, mytime, timestamp=beam.DoFn.TimestampParam):
   yield '{}'.format(timestamp.to_utc_datetime())

def main(argv=None, save_main_session=True):
    import random

    parser = argparse.ArgumentParser()
    parser.add_argument("--input_topic")
    parser.add_argument("--output")
    known_args = parser.parse_known_args(argv)

    pipeline_options = PipelineOptions()
    pipeline_options.view_as(SetupOptions).save_main_session = save_main_session
    with beam.Pipeline(options=pipeline_options) as p:   

        datasource = (p
            | 'ReadData' >> beam.io.ReadFromPubSub(topic=TOPIC).with_output_types(bytes)
            | 'Reshuffle' >> beam.Reshuffle()
            #| 'With timestamps' >> beam.Map(lambda mytime: beam.window.TimestampedValue(mytime, mytime['transaction_time']))
            #| 'Get timestamp' >> beam.ParDo(GetTimestamp())
            | 'Json Parser' >> beam.Map(json.loads)
        )

        bigquery_streaming_write = (datasource
            | 'WriteToBigQuery' >> beam.io.WriteToBigQuery('{0}:vitaming.logistics'.format(PROJECT), schema=schema,
                                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED)
        )

    result = p.run()
    result.wait_until_finish()

if __name__ == '__main__':
    logger = logging.getLogger().setLevel(logging.INFO)
    main()