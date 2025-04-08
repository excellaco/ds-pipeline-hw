from unittest.mock import patch
from lambda.data_processor.main import lambda_handler
import pytest

@patch('lambda.data_processor.lf_helper.get_lf_temp_credentials')
def test_lambda_handler(mock_creds):
    mock_creds.return_value = {
        'AccessKeyId': 'test',
        'SecretAccessKey': 'test',
        'SessionToken': 'test'
    }
    
    event = {"test": "data"}
    result = lambda_handler(event, None)
    
    assert result['statusCode'] == 200
    assert 'tables' in json.loads(result['body'])