はじめに

本BotはGoogle Cloud Platform(GCP)の有料の機能 (Cloud Functions)を使用しているため、基本的にクレジットカードとの紐づけが必要です。ただし、無料枠に収まっているので金銭は発生しないはずです。不安な場合は上限を設定しておいてください。

🔧 構築に必要なもの

✅ Twitter APIキー4種（Consumer Key / Consumer Secret / Access Token / Access Token Secret）⇩Twitter(X)API Freeプラン利用開始手順(こちらを参考にしてください)https://programming-zero.net/how-to-start-twitter-api-basic-and-free/⇩API Key、API Secretの取得・確認手順(こちらを参考にしてください)https://programming-zero.net/twitter-api-process/注：OAuth1.0a利用のSTEP6まで進めてください

✅ Googleスプレッドシート IDスプレッドシートを作成し、ID(下記のXXXXX部分)を控えておいてください。https://docs.google.com/spreadsheets/d/XXXXX/edit?gid=0#gid=0

列を合わせて、上記の様な内容で保存ください。投稿予定日時は30分刻みで設定可能、G列は投稿が完了したら自動で記入されます。

🛠 セットアップ手順（Cloud Shellから）

1. GCPプロジェクトを用意

https://console.cloud.google.com で新しいプロジェクトを作成し、Cloud Shell を起動。

2. リポジトリをクローン

git clone https://github.com/Habeli10/gcp-X-bot.git
cd gcp-X-bot

3. セットアップスクリプト実行

bash setup.sh

 自動的に以下を実行します：

各種APIの有効化（Cloud Functions / Scheduler / Secret Managerなど）

サービスアカウントに必要なロール付与

4. Twitter APIキーとスプレッドシートIDを登録

python3 setup/register_secrets.py

"構築に必要なもの"で準備した、XのAPIキー(4種)とスプレッドシートのIDを入力してください。

5. Cloud Function をデプロイ

bash deploy.sh

デプロイ完了後、Cloud Schedulerが30分おきに関数を実行します。下記の様なメールアドレスが表示されるので、Googleドライブ内の画像には「閲覧者」、スプレッドシートには「編集者」でアクセスユーザーを追加し、共有してください。xxxxx-compute@developer.gserviceaccount.com


📊 スプレッドシートの仕様
A列	B〜E列	F列	G列	H列
ツイート本文	画像URL（最大4つ）	投稿予定日時（JST）	投稿済み日時＋結果	備考

画像URLは Google Drive の共有リンク（例：https://drive.google.com/file/d/XXXXX）

投稿予定時刻は JST形式：YYYY/MM/DD HH:MM

投稿済みになると YYYY/MM/DD HH:MM:SS (SUCCESS) のようにG列に記録
