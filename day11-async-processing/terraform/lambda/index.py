import json
import boto3
import os
import time
from datetime import datetime, timezone

s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns")

TABLE_NAME = os.environ["TABLE_NAME"]
VALID_BUCKET = os.environ["VALID_BUCKET"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    record = event["Records"][0]["s3"]
    source_bucket = record["bucket"]["name"]
    key = record["object"]["key"]

    print(f"Processing document: {key} from bucket {source_bucket}")

    # Simulation d'un échec volontaire pour tester la DLQ
    # (si le nom de fichier contient "fail")
    if "fail" in key.lower():
        raise Exception(f"Simulated processing failure for {key}")

    # 1. Récupère les infos du fichier (simule l'étape "extraction")
    head = s3.head_object(Bucket=source_bucket, Key=key)
    file_size = head["ContentLength"]

    # 2. Écrit les métadonnées en DynamoDB (simule la base de résultats)
    document_id = key.replace("/", "_")
    table.put_item(Item={
        "document_id": document_id,
        "original_filename": key,
        "file_size_bytes": file_size,
        "processed_at": datetime.now(timezone.utc).isoformat(),
        "status": "validated",
    })

    # 3. Copie vers le bucket "validé", puis supprime du bucket brut (= déplacement)
    copy_source = {"Bucket": source_bucket, "Key": key}
    s3.copy_object(CopySource=copy_source, Bucket=VALID_BUCKET, Key=key)
    s3.delete_object(Bucket=source_bucket, Key=key)

    # 4. Notifie l'équipe médicale via SNS
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="Nouveau document patient traité",
        Message=f"Le document '{key}' ({file_size} octets) a été validé et archivé avec succès.\nID: {document_id}",
    )

    print(f"Document {key} processed successfully")
    return {"statusCode": 200, "document_id": document_id}