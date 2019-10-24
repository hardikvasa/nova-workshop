import boto3
import json

client = boto3.client('sns', region_name='<region>')

response = client.publish(
    TopicArn='<SNS topic arn>',
    Message='Hello, World!'
    
    '''
    MessageAttributes={
        'string': {
            'DataType': 'string',
            'StringValue': 'string',
            'BinaryValue': b'bytes'
        }
    }
    '''
)

print(json.dumps(response, indent=4, sort_keys=True))