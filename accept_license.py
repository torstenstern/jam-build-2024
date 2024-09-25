import boto3

def main():
    client = boto3.client('marketplace-catalog')
    response = client.accept_terms(
        ProductCode='ami-033bb8199fdec0a84'
    )
    print(response)

if __name__ == "__main__":
    main()