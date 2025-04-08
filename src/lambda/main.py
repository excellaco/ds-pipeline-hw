import json
import boto3
from lf_helper import get_lf_temp_credentials

def lambda_handler(event, context):
    """Process incoming data with Lake Formation temp credentials"""
    try:
        # Get temp credentials for cross-account access
        creds = get_lf_temp_credentials(
            role_arn="arn:aws:iam::123456789012:role/LakeFormationCrossAccountRole",
            database="sales_db"
        )
        
        # Initialize clients with temp creds
        session = boto3.Session(
            aws_access_key_id=creds['AccessKeyId'],
            aws_secret_access_key=creds['SecretAccessKey'],
            aws_session_token=creds['SessionToken']
        )
        
        glue = session.client('glue')
        tables = glue.get_tables(DatabaseName="sales_db")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Data processed with LF credentials',
                'tables': tables['TableList']
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }