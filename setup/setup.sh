#!/bin/bash
# setup.sh - GCPプロジェクトの初期設定とAPI有効化（Cloud Shell＋Gen2対応版）

set -e

# 必要なAPI群（Gen2対応の追加含む）
APIS=(
  secretmanager.googleapis.com
  cloudfunctions.googleapis.com
  cloudscheduler.googleapis.com
  iamcredentials.googleapis.com
  drive.googleapis.com
  sheets.googleapis.com
  cloudbuild.googleapis.com
  run.googleapis.com
  artifactregistry.googleapis.com
)

# プロジェクトID取得
PROJECT_ID=$(gcloud config get-value project)
echo ""
echo "🛠 使用プロジェクト: $PROJECT_ID"

# API有効化
for api in "${APIS[@]}"; do
  echo "🔧 API 有効化中: $api"
  gcloud services enable "$api"
done

# サービスアカウントへのロール付与は関数デプロイ後に案内
echo ""
echo "⚠️ 注意：Cloud Function のサービスアカウントがまだ存在しないため、"
echo "         ロール付与はデプロイ後に行ってください。"
echo ""
echo "🔍 関数のサービスアカウントを確認するには："
echo "gcloud functions describe tweet_from_sheet --region=asia-northeast1 --format='value(serviceAccountEmail)'"
echo ""
echo "🛠 次に実行するコマンド："
echo "python3 setup/register_secrets.py"
