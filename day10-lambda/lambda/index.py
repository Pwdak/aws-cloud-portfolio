import json
import time

# Exécuté une seule fois par environnement (cold start)
INIT_TIME = time.time()
invocations = 0

def handler(event, context):
    global invocations
    invocations += 1
    body = {
        "message": "Hello from Lambda",
        "invocations_in_this_container": invocations,
        "container_age_seconds": round(time.time() - INIT_TIME, 1),
        "request_id": context.aws_request_id,
        "memory_limit_mb": context.memory_limit_in_mb,
    }
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }