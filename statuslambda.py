import json
import boto3
from botocore.exceptions import ClientError
import os
import sys

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', "us-west-2")
    try:
        results = ec2.describe_instance_status(IncludeAllInstances=True, InstanceIds=[os.environ["INSTANCE"]])["InstanceStatuses"][0]
        return {
            'statusCode': 200,
            'body': "The server status is " + results["InstanceState"]["Name"] + ", but you may need to wait a little while to see the results of this. IP: " + os.environ["CONNECT_IP"]
        }
    except ClientError as e:
            return {
                'statusCode': 503,
                'body': "Could not get the status."
            }
    
    
    

