#!/bin/bash
# setup.sh - GCPプロジェクトの初期設定とAPI有効化（Cloud Shell対応版）

set -e

APIS=(
  secretmanager.googleapis.com
  cloudfunctions.googleapis.com
  cloudscheduler.googleapis.com
  iamcredentials.googleapis.com
  drive.googleapis.com
  sheets.googleapis.com
)

PROJECT_ID=$(gcloud config get-value project)
echo "\n🛠 プロジェクト: $PROJECT_ID を使用します"

for api in "${APIS[@]}"; do
  echo "🔧 API 有効化: $api"
  gcloud services enable "$api"
done

echo "\n⚠️ 注意：IAMロールの付与はCloud Functionデプロイ後に行ってください。"
echo "🔍 関数のサービスアカウント確認方法："
echo "gcloud functions describe tweet_from_sheet --region=asia-northeast1 --format='value(serviceAccountEmail)'"
echo ""
echo "🛠 次に実行するコマンド："
echo "python3 setup/register_secrets.py"