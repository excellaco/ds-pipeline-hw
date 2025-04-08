import boto3
from botocore.config import Config

def get_lf_temp_credentials(role_arn: str, database: str):
    """Retrieve temporary Lake Formation credentials"""
    lf_client = boto3.client('lakeformation', config=Config(
        retries={'max_attempts': 3},
        region_name='us-east-1'
    ))
    
    response = lf_client.get_temporary_credentials(
        RoleArn=role_arn,
        DatabaseName=database,
        DurationSeconds=900  # 15-minute expiry
    )
    
    return response['Credentials']