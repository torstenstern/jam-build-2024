import json
import boto3
import random
import string
from boto3.dynamodb.conditions import Key

def book_flight(event, request_body, table):
    
    # Grab required fields out of request_body
    properties = request_body['properties']
    flight_number = next((prop['value'] for prop in properties if prop['name'] == 'flight_number'), None)
    departure_date = next((prop['value'] for prop in properties if prop['name'] == 'departure_date'), None)
    first_name = next((prop['value'] for prop in properties if prop['name'] == 'first_name'), None)
    last_name = next((prop['value'] for prop in properties if prop['name'] == 'last_name'), None)
    dob = next((prop['value'] for prop in properties if prop['name'] == 'dob'), None)
    credit_card_num = next((prop['value'] for prop in properties if prop['name'] == 'credit_card_num'), None)
    cc_expiration_date = next((prop['value'] for prop in properties if prop['name'] == 'cc_expiration_date'), None)
    cvc = next((prop['value'] for prop in properties if prop['name'] == 'cvc'), None)
    
    # Generate 8-digit 'confirmation code' back to the user
    conf_code = ''.join(random.choices(string.ascii_uppercase +
                             string.digits, k=8))
    
    response_body = {
        'application/json': {
            'body': conf_code
        }
    }
    action_response = {
        'actionGroup': event['actionGroup'],
        'apiPath': event['apiPath'],
        'httpMethod': event['httpMethod'],
        'httpStatusCode': 200,
        'responseBody': response_body
    }
    response = {'messageVersion': '1.0', 'response': action_response}
    
    print(f"Return: {response}")
  
    return response

def get_flight_details(event, request_body, table):
    # Get flight details by flight number and departure date
    # Pull the properties out of request_body
    properties = request_body['properties']

    flight_number = properties[0].get("value")
    departure_date = properties[1].get("value")

    
    print("Checking flight details for " + flight_number + " departing on " + departure_date)
    
    query_result = table.get_item(
        Key={
            'flight_number': flight_number,
            'departure_date': departure_date
        }
    )
    item = query_result.get('Item')

    if not item:
        print("Could not find a flight")
        response_body = {
            'application/json': {
                'body': "Flight not found"
            } 
        }
        action_response = {
            'actionGroup': event['actionGroup'],
            'apiPath': event['apiPath'],
            'httpMethod': event['httpMethod'],
            'httpStatusCode': 404,
            'responseBody': response_body
        }
        response = {'messageVersion': '1.0', 'response': action_response}
        print(f"Return: {response}")
        return response
    # Else, return the flight details
    flight_detail = {
        'flight_number': item['flight_number'],
        'departure_date': item['departure_date'],
        'arrival_city': item['arrival_city'],
        'departure_city': item['departure_city'],
        'departure_time': item['departure_time'],
        'flight_details': item['flight_details']
    }

    response_body = {
        'application/json': {
            'body': flight_detail
        } 
    }

    action_response = {
        'actionGroup': event['actionGroup'],
        'apiPath': event['apiPath'],
        'httpMethod': event['httpMethod'],
        'httpStatusCode': 200,
        'responseBody': response_body
    }
    response = {'messageVersion': '1.0', 'response': action_response}
    print(f"Lambda return response: {response}")
    return response

def search_flights(event, request_body, table):

    properties = request_body['properties']
    
    arrival_city = next((prop['value'] for prop in properties if prop['name'] == 'arrival_city'), None)
    departure_city = next((prop['value'] for prop in properties if prop['name'] == 'departure_city'), None)
        
    if arrival_city and departure_city:
        response = table.scan(
            FilterExpression=Key('arrival_city').eq(arrival_city) & Key('departure_city').eq(departure_city)
        )
        items = response['Items']
        print(f"Found {len(items)} flights")
        flights = []
        for item in items:
            flight = {
                'flight_number': item['flight_number'],
                'departure_date': item['departure_date'],
                'departure_time': item['departure_time'],
                'ticket_price': item['ticket_price']
            }
            flights.append(flight)
            
        response_body = {
            'application/json': {
                'body': flights
            }
        }
        action_response = {
            'actionGroup': event['actionGroup'],
            'apiPath': event['apiPath'],
            'httpMethod': event['httpMethod'],
            'httpStatusCode': 200,
            'responseBody': response_body
        }
        response = {'messageVersion': '1.0', 'response': action_response}
        
        print(f"Return: {response}")
      
        return response
    else:
        response = {
            'application/json':{
                'body': {
                    'message': 'Missing required fields: arrival_city and/or departure_city'
                }
            }
                
        }
        print(f"Return: {response}")
        return response

def lambda_handler(event, context):
    # Create a DynamoDB client
    dynamodb = boto3.resource('dynamodb')
    flight_data_table = dynamodb.Table('workshop_flight_data')
    reservations_table = dynamodb.Table('SensitiveFlightData')

    # Get the API path from the event
    api_path = event['apiPath']
    
    try:
        if api_path == '/get-flight-details':
            request_body = event['requestBody']['content']['application/json']
            response = get_flight_details(event, request_body, flight_data_table) 
            return response
            
        elif api_path == '/search-flights':
            request_body = event['requestBody']['content']['application/json']
            response = search_flights(event, request_body, flight_data_table) 
            return response
        
        elif api_path == '/book-flight':
            # Get ticket price by flight number and departure date  
            request_body = event['requestBody']['content']['application/json']
            response = book_flight(event, request_body, flight_data_table)
            return response

        else:
            response_body = {
                'application/json':{
                     'body': "Invalid API Path"
                }
            }
            action_response = {
                'actionGroup': event['actionGroup'],
                'apiPath': event['apiPath'],
                'httpMethod': event['httpMethod'],
                'httpStatusCode': 400,
                'responseBody': response_body
            }
            response = {'messageVersion': '1.0', 'response': action_response}
            print(f"Return: {response}")
            return response
    except Exception as e:
        response_body = {
            'application/json':{
                 'body': "Error details: " + str(e)
            }
        }
        action_response = {
            'actionGroup': event['actionGroup'],
            'apiPath': event['apiPath'],
            'httpMethod': event['httpMethod'],
            'httpStatusCode': 500,
            'responseBody': response_body
        }
        response = {'messageVersion': '1.0', 'response': action_response}

        print(f"Exception Return: {response}")
        return response
