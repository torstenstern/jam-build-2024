import json
import requests
import boto3
import os

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    url = "https://jsonplaceholder.typicode.com/posts"  # Sample external API
    response = requests.get(url)
    data = response.json()
    
    # Optionally store data in S3
    s3_bucket = os.environ['S3_BUCKET']
    s3_key = 'external_data.json'
    s3_client.put_object(Bucket=s3_bucket, Key=s3_key, Body=json.dumps(data))
    
    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }