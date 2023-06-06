import json
import boto3
from botocore.exceptions import ClientError
import os
import sys

def lambda_handler(event, context):
    if not "body" in event:
        return {
            'statusCode': 403,
            'body': "No key specified."
        }
    if event["body"] == os.environ['AUTHORIZATION']:
        ec2 = boto3.client('ec2', "us-west-2")
        response = ec2.start_instances(InstanceIds=[os.environ["INSTANCE"]])
            
        return {
            'statusCode': 200,
            'body': 'The server is starting.'
        }
    else:
        return {
            'statusCode': 403,
            'body': "Unauthorized"
        }
