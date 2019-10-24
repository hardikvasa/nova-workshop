import boto3
import json

client = boto3.client('sns', region_name='<region>')

response = client.publish(
    TopicArn='<SNS topic ARN>',
    Message='Hello, World!',
    MessageCategory={
        '<Key1>': {
            'DataType': 'String',
            'StringValue': '<Value1>'
        },
        '<Key2>': {
            'DataType': 'String',
            'StringValue': '<Value2>'
        }
    }
)

print(json.dumps(response, indent=4, sort_keys=True))