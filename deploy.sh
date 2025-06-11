#!/bin/bash
# deploy.sh - Cloud FunctionとSchedulerのデプロイ

set -e

PROJECT_ID=$(gcloud config get-value project)
REGION=asia-northeast1
FUNCTION_NAME=tweet_from_sheet
SCHEDULE="*/30 * * * *"

# 関数URL取得の一時ファイル
TMP_OUT=$(mktemp)

# Cloud Functionデプロイ
echo "\n🚀 Cloud Functionをデプロイ中..."
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

# Scheduler作成
echo "\n⏰ Cloud Schedulerジョブを作成中..."
gcloud scheduler jobs create http tweet-scheduler \
  --schedule="$SCHEDULE" \
  --uri="$URL" \
  --http-method=GET \
  --time-zone=Asia/Tokyo \
  --project="$PROJECT_ID"

rm "$TMP_OUT"
echo "\n✅ デプロイ完了！30分ごとに投稿チェックが行われます。"
