import boto3
import os

def print_token():
    """Print the token from environment variables."""
    token = os.getenv("TOKEN", "No Token Found")
    print(f"Retrieved TOKEN: {token}")

def test_s3_connectivity():
    """Test connectivity to S3 by listing available buckets."""
    access_key = os.getenv("AWS_ACCESS_KEY_ID")
    secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")

    if not access_key or not secret_key:
        raise ValueError("AWS credentials are not set in the environment variables.")

    s3 = boto3.client(
        "s3",
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
    )
    response = s3.list_buckets()
    print(f"Connected to S3. Buckets: {[bucket['Name'] for bucket in response.get('Buckets', [])]}")

if __name__ == "__main__":
    # Call the functions
    print("Printing Tokens to Log")
    
    # Print the token
    print_token()

    # Test S3 connectivity
    try:
        test_s3_connectivity()
    except ValueError as e:
        print(f"Error: {e}")
