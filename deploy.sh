#!/bin/bash
# deploy.sh - Cloud FunctionとSchedulerのデプロイ

set -e

PROJECT_ID=$(gcloud config get-value project)
REGION=asia-northeast1
FUNCTION_NAME=tweet_from_sheet
SCHEDULE="*/30 * * * *"

# 一時ファイルに関数情報を出力
TMP_OUT=$(mktemp)

echo ""
echo "🚀 Cloud Functionをデプロイ中..."
gcloud functions deploy "$FUNCTION_NAME" \
  --runtime=python310 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point=tweet_from_sheet \
  --region="$REGION" \
  --source=./cloud_function \
  --set-env-vars=GCP_PROJECT="$PROJECT_ID" \
  --memory=512MB \
  --timeout=60s \
  --quiet \
  --format=json > "$TMP_OUT"

URL=$(cat "$TMP_OUT" | grep -o 'https://[^"]*')

echo ""
echo "⏰ Cloud Schedulerジョブを作成中..."
gcloud scheduler jobs create http tweet-scheduler \
  --schedule="$SCHEDULE" \
  --uri="$URL" \
  --http-method=GET \
  --time-zone=Asia/Tokyo \
  --project="$PROJECT_ID" \
  || echo "既にSchedulerが存在する可能性があります（OK）"

rm "$TMP_OUT"
echo ""
echo "✅ デプロイ完了！30分ごとに投稿チェックが行われます。"
