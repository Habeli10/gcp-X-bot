#!/bin/bash
# deploy.sh - Cloud FunctionとSchedulerのデプロイ（Gen2＋Secret権限＋Drive共有案内）

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

SERVICE_ACCOUNT=$(gcloud functions describe "$FUNCTION_NAME" \
  --region="$REGION" \
  --format="value(serviceConfig.serviceAccountEmail)")

echo ""
echo "🔐 Secret Manager 読み取り権限を付与中: $SERVICE_ACCOUNT"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/secretmanager.secretAccessor"

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
  --location="$REGION" \
  --project="$PROJECT_ID" \
  || echo "既にSchedulerが存在する可能性があります（OK）"

echo ""
echo "✅ デプロイ完了！Cloud Function URL: $URL"
echo ""
echo "📸 このメールアドレスを Google Drive画像およびスプレッドシートに「閲覧者」として共有してください:"
echo "   $SERVICE_ACCOUNT"
