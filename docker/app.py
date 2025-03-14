# app.py
from flask import Flask
import boto3
import os

app = Flask(__name__)

# AWS credentials and region from environment variables
aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_region = os.getenv("AWS_REGION", "us-east-1")  # Default to us-east-1

# Initialize boto3 EC2 client
ec2_client = boto3.client(
    "ec2",
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    region_name=aws_region
)

@app.route("/")
def instance_count():
    try:
        # Query running instances
        response = ec2_client.describe_instances(
            Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
        )
        running_instances = sum(len(res["Instances"]) for res in response["Reservations"])
        return f"Number of running AWS EC2 instances: {running_instances}"
    except Exception as e:
        return f"Error fetching instance count: {str(e)}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)

