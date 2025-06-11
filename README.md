# 📢 GCP Twitter Bot - 自動ツイート投稿システム

Google Cloud Platform (GCP) を使って、Googleスプレッドシートに記載されたツイートを、指定時刻に自動投稿するBotです。

## ✅ 特長
- GCP上で完結（無料枠でも動作可能）
- スプレッドシートに記載するだけで簡単運用
- Google Driveの画像にも対応（最大4枚）
- 投稿ログをスプレッドシートに自動記録
- セキュリティも考慮（Secret Manager使用）

## 📁 フォルダ構成
```
gcp-twitter-bot/
├── cloud_function/
│   ├── main.py
│   └── requirements.txt
├── setup/
│   ├── setup.sh
│   └── register_secrets.py
├── deploy.sh
└── README.md
```

## 📝 スプレッドシートの仕様
| 列 | 内容 |
|----|------|
| A  | ツイート内容（280文字以内） |
| B〜E | Google Drive画像の共有URL（最大4枚まで） |
| F  | 投稿予定日時（例: 2025/06/13 08:00）※JST |
| G  | 投稿済み日時と結果（Botが記入） |
| H  | 備考（任意） |

## 🚀 セットアップ手順（初回のみ）

1. GCPログインとプロジェクト設定  
```bash
gcloud auth login
gcloud config set project <YOUR_PROJECT_ID>
```

2. リポジトリをクローン  
```bash
git clone https://github.com/yourname/gcp-twitter-bot.git
cd gcp-twitter-bot
```

3. GCP APIとIAMの設定  
```bash
bash setup/setup.sh
```

4. Secret登録（対話式）  
```bash
python3 setup/register_secrets.py
```

5. 関数とスケジューラのデプロイ  
```bash
bash deploy.sh
```

## 💡 注意点
- 30分ごとに投稿対象をチェック
- Drive画像は「IAM共有のみ」でBotと共有
- G列が空の行だけ投稿対象になります
