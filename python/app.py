from flask import Flask
import boto3
import os

app = Flask(__name__)

# AWS credentials and region from environment variables
aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_region = os.getenv("AWS_REGION", "us-east-1")

# Initialize clients (once)
ec2_client = boto3.client(
    "ec2",
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    region_name=aws_region
)
elb_client = boto3.client(
    "elb",
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    region_name=aws_region
)
elbv2_client = boto3.client(
    "elbv2",
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    region_name=aws_region
)

@app.route("/")
def aws_resources():
    try:
        # Count running EC2 instances
        ec2_response = ec2_client.describe_instances(
            Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
        )
        running_instances = sum(len(res["Instances"]) for res in ec2_response["Reservations"])

        # Count Load Balancers (Classic and Application/Network)
        classic_lbs = len(elb_client.describe_load_balancers()["LoadBalancerDescriptions"])
        app_net_lbs = len(elbv2_client.describe_load_balancers()["LoadBalancers"])
        total_lbs = classic_lbs + app_net_lbs

        # List VPCs
        vpcs = ec2_client.describe_vpcs()["Vpcs"]
        vpc_list = "\n".join([vpc["VpcId"] for vpc in vpcs]) if vpcs else "None"

        # List AMIs (owned by the account)
        amis = ec2_client.describe_images(Owners=["self"])["Images"]
        ami_list = "\n".join([ami["ImageId"] for ami in amis]) if amis else "None"

        # Format response with newlines
        response_text = f"""
Number of running AWS EC2 instances: {running_instances}
Total Load Balancers: {total_lbs}
Available VPCs:
{vpc_list}
Available AMIs:
{ami_list}
"""
        # Wrap in <pre> tag to preserve newlines in browser
        return f"<pre>{response_text}</pre>"
    except Exception as e:
        return f"<pre>Error fetching AWS resources: {str(e)}</pre>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)