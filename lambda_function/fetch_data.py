# Use the Converse API to send a text message to Titan Text G1 - Premier.

import boto3
from botocore.exceptions import ClientError

# Create a Bedrock Runtime client in the AWS Region you want to use.
client = boto3.client("bedrock-runtime", region_name="us-east-1")

# Set the model ID, e.g., Titan Text Premier.
model_id = "amazon.titan-text-premier-v1:0"

# Start a conversation with the user message.
user_message = """You are an expert Business Analyst at a fitness company with more than 10,000 daily active users on the app and website.

You are tasked to do a market research in comparing multiple brands of shoes for a potential partnership.

The goal for these shoes are to be used for workouts, so they should be easy fit, good for running, walking and jumping, and be affordable for your customers. After this partnership, customers can buy the partners shoes from your website at a discounted price and create a win-win opportunity for the partner as well as for your business and customers.

Tha main objective when doing this analysis is 
- Customer Satisfaction
- Inclusion for all ages, sizes, and purchasing power
- Brand visibiliy and partnership

Help me with a step-by-step plan on how to go about doing this analysis and what research I should do to come to a conclusion.

Guide me and help me think step-by-step. Explain your thought process as you work through this process. 
"""
conversation = [
    {
        "role": "user",
        "content": [{"text": user_message}],
    }
]

try:
    # Send the message to the model, using a basic inference configuration.
    response = client.converse(
        modelId="amazon.titan-text-premier-v1:0",
        messages=conversation,
        inferenceConfig={"maxTokens":1024,"stopSequences":[],"temperature":0.7,"topP":0.9},
        additionalModelRequestFields={}
    )

    # Extract and print the response text.
    response_text = response["output"]["message"]["content"][0]["text"]
    print(response_text)

except (ClientError, Exception) as e:
    print(f"ERROR: Can't invoke '{model_id}'. Reason: {e}")
    exit(1)
