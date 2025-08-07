# src/lambda_function.py
import boto3
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')
rds = boto3.client('rds')

def stop_ec2_instances(tag_key='env', tag_value='dev'):
    """Finds and stops all EC2 instances with the specified tag."""
    instances_to_stop = []
    reservations = ec2.describe_instances(
        Filters=[
            {'Name': f'tag:{tag_key}', 'Values': [tag_value]},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )['Reservations']

    for reservation in reservations:
        for instance in reservation['Instances']:
            instances_to_stop.append(instance['InstanceId'])

    if instances_to_stop:
        logger.info(f"Stopping EC2 instances: {instances_to_stop}")
        ec2.stop_instances(InstanceIds=instances_to_stop)
    else:
        logger.info("No running EC2 instances with specified tags found.")

def stop_rds_instances(tag_key='env', tag_value='dev'):
    """Finds and stops all RDS instances with the specified tag."""
    # Note: RDS tagging and stopping logic is more complex in a real scenario.
    # This is a simplified representation.
    logger.info("Checking for RDS instances to stop (logic placeholder).")
    # rds.stop_db_instance(DBInstanceIdentifier='your-db-id')

def lambda_handler(event, context):
    """
    Main Lambda function handler triggered by EventBridge.
    """
    logger.info("Starting FinOps hibernation script...")
    
    try:
        stop_ec2_instances()
        stop_rds_instances()
        logger.info("Hibernation script completed successfully.")
        return {
            'statusCode': 200,
            'body': 'Hibernation script executed successfully.'
        }
    except Exception as e:
        logger.error(f"Error during script execution: {e}")
        return {
            'statusCode': 500,
            'body': f'Error: {e}'
        }
