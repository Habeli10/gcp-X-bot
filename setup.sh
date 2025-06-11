#!/bin/bash
# setup.sh - GCPプロジェクトの初期設定とAPI有効化

set -e

# 必要なAPI群
APIS=(
  secretmanager.googleapis.com
  cloudfunctions.googleapis.com
  cloudscheduler.googleapis.com
  iamcredentials.googleapis.com
  drive.googleapis.com
  sheets.googleapis.com
)

# 現在のプロジェクト確認
PROJECT_ID=$(gcloud config get-value project)
echo "\n🛠 プロジェクト: $PROJECT_ID を使用します"

# API 有効化
for api in "${APIS[@]}"; do
  echo "🔧 API 有効化: $api"
  gcloud services enable "$api"
done

# Cloud Functions 実行サービスアカウントにロール付与
SA="$(gcloud iam service-accounts list --filter='compute' --format='value(email)' | head -n1)"
echo "\n👤 サービスアカウント: $SA"

# Secret Manager & Sheets/Drive 用IAMロール
ROLES=(
  roles/secretmanager.secretAccessor
  roles/iam.serviceAccountTokenCreator
  roles/drive.readonly
  roles/sheets.reader
)

for role in "${ROLES[@]}"; do
  echo "🔑 ロール付与: $role"
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SA" \
    --role="$role"
done

echo -e "\n✅ 初期セットアップ完了！次に register_secrets.py を実行してください。"
