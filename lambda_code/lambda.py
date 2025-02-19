def hello_handler(event, context):
    #Lambda function to greet a user with their full name.
    first_name = event.get("first_name", "Guest")
    last_name = event.get("last_name", "")
    return {
        "statusCode": 200,
        "body": f"Hello, {first_name} {last_name}!"
    }

#test in JSON
"""
{
  "first_name": "victor",
  "last_name": "ponce"
}
"""