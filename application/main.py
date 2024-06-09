from google.cloud import asset_v1, bigquery
import datetime

def export_assets_to_bigquery():
    # GCP variables - TO BE CHANGED
    org_id = "CHANGEME"
    project_id = "CHANGEME"

    # Initialisation
    bq_client = bigquery.Client()
    asset_client = asset_v1.AssetServiceClient()
    
    # BigQuery variables
    dataset_id = "cloud_asset_inventory"
    table_id = f'asset_inventory_{datetime.datetime.utcnow().strftime("%d%m%Y_%H%M%S")}'
    latest_table_id = 'asset_inventory_latest'
    bigquery_destination = f"projects/{project_id}/datasets/{dataset_id}"      
    fully_qualified_table_id = f"{project_id}.{dataset_id}.{table_id}"
    fully_qualified_latest_table_id = f"{project_id}.{dataset_id}.{latest_table_id}"

    # Prepare the output configuration
    output_config = asset_v1.OutputConfig(
        bigquery_destination=asset_v1.BigQueryDestination(
            dataset=bigquery_destination,
            table=table_id,
            force=True
        )
    )

    # Prepare the request
    request = asset_v1.ExportAssetsRequest(
        parent=f"organizations/{org_id}",
        content_type=asset_v1.ContentType.RESOURCE,
        output_config=output_config
    )
   
    try:
        operation = asset_client.export_assets(request=request)
        response = operation.result()
        print(f"Successfully exported assets to BigQuery table: {fully_qualified_table_id}")
        
        '''
        Copy the exported table to asset_inventory_latest
        This ensures that the dashboard for Looker visualisation is up to date with the latest run.
        '''
        src_table = bigquery.TableReference.from_string(fully_qualified_table_id)
        dest_table = bigquery.TableReference.from_string(fully_qualified_latest_table_id)
        
        # Configure the copy job to overwrite the destination table if it exists
        copy_job_config = bigquery.CopyJobConfig(write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE)
        
        job = bq_client.copy_table(src_table, dest_table, job_config=copy_job_config)
        job.result()
        
        print(f"Successfully copied assets to BigQuery table: {fully_qualified_latest_table_id}")
    except Exception as e:
        print(f"Failed to export assets: {e}")

# The Cloud Function entry point
def pubsub_to_bigquery(event, context):
    export_assets_to_bigquery()

if __name__ == "__main__":
    event = {}
    context = {}
    pubsub_to_bigquery(event, context)