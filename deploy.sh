#!/bin/bash
# deploy.sh - Cloud FunctionとSchedulerのデプロイ（Gen2対応）

set -e

PROJECT_ID=$(gcloud config get-value project)
REGION=asia-northeast1
FUNCTION_NAME=tweet_from_sheet
SCHEDULE="*/30 * * * *"

echo ""
echo "🚀 Cloud Functionをデプロイ中..."

gcloud functions deploy "$FUNCTION_NAME" \
  --gen2 \
  --runtime=python310 \
  --trigger-http \
  --entry-point=tweet_from_sheet \
  --region="$REGION" \
  --source=./cloud_function \
  --set-env-vars=GCP_PROJECT="$PROJECT_ID" \
  --memory=512MB \
  --timeout=60s \
  --quiet

# ✅ URL取得（Gen2対応）
URL=$(gcloud functions describe "$FUNCTION_NAME" \
  --region="$REGION" \
  --format="value(serviceConfig.uri)")

echo ""
echo "⏰ Cloud Schedulerジョブを作成中..."

gcloud scheduler jobs create http tweet-scheduler \
  --schedule="$SCHEDULE" \
  --uri="$URL" \
  --http-method=GET \
  --time-zone=Asia/Tokyo \
  --project="$PROJECT_ID" \
  || echo "既にSchedulerが存在する可能性があります（OK）"

echo ""
echo "✅ デプロイ完了！Cloud Function URL: $URL"
