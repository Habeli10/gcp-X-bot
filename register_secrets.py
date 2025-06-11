# register_secrets.py - 対話形式でSecret Managerに情報登録

import subprocess
import sys

secrets = {
    "twitter_consumer_key": "TwitterのConsumer Key",
    "twitter_consumer_secret": "TwitterのConsumer Secret",
    "twitter_access_token": "TwitterのAccess Token",
    "twitter_access_token_secret": "TwitterのAccess Token Secret",
    "spreadsheet_id": "スプレッドシートのID (URLの /d/XXX/ の部分)"
}

def create_or_update_secret(name, value):
    try:
        subprocess.run([
            "gcloud", "secrets", "create", name,
            "--replication-policy=automatic",
            "--data-file=-"
        ], input=value.encode(), check=True)
    except subprocess.CalledProcessError:
        subprocess.run([
            "gcloud", "secrets", "versions", "add", name,
            "--data-file=-"
        ], input=value.encode(), check=True)

if __name__ == '__main__':
    for key, description in secrets.items():
        print(f"🔑 {description} を入力してください：")
        value = input("> ").strip()
        if not value:
            print("❌ 入力が空です。中断します。")
            sys.exit(1)
        create_or_update_secret(key, value)
        print(f"✅ {key} をSecret Managerに登録しました\n")

    print("🎉 すべてのシークレットを登録しました！")
