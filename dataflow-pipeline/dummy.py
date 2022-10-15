# Packages

import logging
import os

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigtableio import WriteToBigTable


# Globals

REGION="asia-south1"
REQUIREMENTS_FILE="./requirements.txt"

#GOOGLE_APPLICATION_CREDENTIALS="<my_credentials>.json"
PROJECT="on-prem-project-337210"
INSTANCE="vitg-inst"
TABLE="logistics-cust"
BUCKET="vitaming-demo"
TEMP_LOCATION="gs://vitaming-demo/temp/"
STAGING_LOCATION="gs://vitaming-demo/staging/"

# Authentication

# os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = GOOGLE_APPLICATION_CREDENTIALS

# Pipeline

class CreateRowFn(beam.DoFn):
    
    def __init__(self, pipeline_options):
        
        self.instance_id = pipeline_options.bigtable_instance
        self.table_id = pipeline_options.bigtable_table
  
    def process(self, key):
        
        from google.cloud.bigtable import row
        import datetime

        direct_row = row.DirectRow(row_key=key)
        direct_row.set_cell(
            "stats_summary",
            b"os_build",
            b"android",
            datetime.datetime.now())
        
        yield direct_row

class XyzOptions(PipelineOptions):
    
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_argument('--bigtable_project', default='nested'),
        parser.add_argument('--bigtable_instance', default='instance'),
        parser.add_argument('--bigtable_table', default='table')

pipeline_options = XyzOptions(
    save_main_session=True, streaming=True,
    runner='DirectRunner',
    project=PROJECT,
    region=REGION,
    temp_location=TEMP_LOCATION,
    staging_location=STAGING_LOCATION,
    requirements_file=REQUIREMENTS_FILE,
    bigtable_project=PROJECT,
    bigtable_instance=INSTANCE,
    bigtable_table=TABLE)

def run (argv=None):
    
    with beam.Pipeline(options=pipeline_options) as p:
         
        _ = (p
                | beam.Create(
                    ["phone#4c410523#20190501",
                     "phone#4c410523#20190502"])
                | beam.ParDo(CreateRowFn(pipeline_options)) 
                | WriteToBigTable(project_id=pipeline_options.bigtable_project,
                                  instance_id=pipeline_options.bigtable_instance,
                                  table_id=pipeline_options.bigtable_table))

run()
