from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
from google.cloud import pubsub_v1
from google.cloud import bigquery
import apache_beam as beam
import logging
import argparse
import json
import random
from apache_beam.transforms.window import FixedWindows
from apache_beam import DoFn, GroupBy, io, ParDo, Pipeline, PTransform, WindowInto, WithKeys
from apache_beam.io import fileio, filesystem
from apache_beam.io.filebasedsink_test import _TestCaseWithTempDirCleanUp


PROJECT="on-prem-project-337210"
schema = "client_id:STRING,epoch_time:STRING"
TOPIC = "projects/on-prem-project-337210/topics/vitaming"

class WriteFilesTest(_TestCaseWithTempDirCleanUp):
  class JsonSink(fileio.TextSink):

    def write(self, record):
      self._fh.write(json.dumps(record).encode('utf8'))
      self._fh.write('\n'.encode('utf8'))

def no_colon_file_naming(*args):
    file_name = fileio.destination_prefix_naming()(*args)
    return file_name.replace(':', '_')

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
            | "Json Parser" >> beam.Map(json.loads)
        )

        bq_streaming_write = (datasource
            | 'WriteToBigQuery' >> beam.io.WriteToBigQuery('{0}:vitaming.logistics'.format(PROJECT), schema=schema,
                                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED)
        )

        gcs_window_write = (datasource
        | "Window into fixed intervals" >> WindowInto(FixedWindows(30))
        | "Group by key" >> GroupBy(lambda s: random.randint(0, 2))
        | 'Extract Values"' >> beam.FlatMap(lambda x: x[1])
        | 'Write to GCS' >> fileio.WriteToFiles(
                                    path=str("gs://customer-demos-asia-south1/dataflow/"),
                                    sink=lambda x: WriteFilesTest.JsonSink(),
                                    file_naming=no_colon_file_naming,
                                    max_writers_per_bundle=0
                                    )
        )

    result = p.run()
    result.wait_until_finish()

if __name__ == '__main__':
    logger = logging.getLogger().setLevel(logging.INFO)
    main()