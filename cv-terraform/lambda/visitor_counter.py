import json
import boto3
import os
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE', 'cv-visitor-counter')
table = dynamodb.Table(table_name)

def decimal_default(obj):
    """Helper function to convert Decimal to int for JSON serialization"""
    if isinstance(obj, Decimal):
        return int(obj)
    raise TypeError

def lambda_handler(event, context):
    """
    Lambda function to track and return visitor count
    
    This function:
    1. Increments the visitor count in DynamoDB
    2. Returns the updated count with CORS headers
    """
    
    try:
        # Update counter in DynamoDB (atomic increment)
        response = table.update_item(
            Key={'id': 'visitor-count'},
            UpdateExpression='ADD visit_count :inc',
            ExpressionAttributeValues={':inc': 1},
            ReturnValues='UPDATED_NEW'
        )
        
        # Get the updated count
        visit_count = response['Attributes']['visit_count']
        
        # Return response with CORS headers
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',  # Allow from any origin
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
            },
            'body': json.dumps({
                'count': visit_count
            }, default=decimal_default)
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        
        # Return error response
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
            },
            'body': json.dumps({
                'error': 'Failed to update visitor count',
                'message': str(e)
            })
        }
