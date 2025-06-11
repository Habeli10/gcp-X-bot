# GCP × Twitter 自動投稿Bot（Cloud Shell対応）

## 概要
- Googleスプレッドシートからツイート文と画像を取得
- Google Driveの画像（最大4枚）付きで投稿
- Cloud Schedulerで30分ごとにチェック＆自動投稿

## セットアップ手順（Cloud Shell）

1. Cloud Shellを起動し、以下を実行：
```bash
git clone https://github.com/yourname/gcp-X-bot.git
cd gcp-X-bot
bash setup/setup.sh
python3 setup/register_secrets.py
bash deploy.sh
```

2. 関数のサービスアカウント確認：
```bash
gcloud functions describe tweet_from_sheet --region=asia-northeast1 --format='value(serviceAccountEmail)'
```

3. Drive画像をこのアドレスに「閲覧者」として共有（公開共有は不要）

## スプレッドシート仕様

| 列 | 内容 |
|----|------|
| A | ツイート本文 |
| B〜E | Drive画像リンク（最大4枚） |
| F | 投稿予定日時（JST） |
| G | Botが投稿結果を記録 |
| H | 備考（任意） |