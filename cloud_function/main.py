import os
import io
import logging
import tempfile
import datetime
import requests
import functions_framework
import tweepy
import google.auth
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
from google.cloud import secretmanager
from tweepy.errors import TooManyRequests
from datetime import timezone, timedelta

SHEET_NAME = 'シート1'
JST = timezone(timedelta(hours=9))

def get_secret(secret_id):
    client = secretmanager.SecretManagerServiceClient()
    project_id = os.environ['GCP_PROJECT']
    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(name=name)
    return response.payload.data.decode("UTF-8")

def get_image_from_drive(file_id):
    creds, _ = google.auth.default()
    drive_service = build('drive', 'v3', credentials=creds)
    request = drive_service.files().get_media(fileId=file_id)
    fh = io.BytesIO()
    downloader = MediaIoBaseDownload(fh, request)
    done = False
    while not done:
        status, done = downloader.next_chunk()
    fh.seek(0)
    return fh.read()

@functions_framework.http
def tweet_from_sheet(request):
    logging.info("✅ Cloud Function 呼び出し開始")
    try:
        SPREADSHEET_ID = get_secret("spreadsheet_id")

        auth = tweepy.OAuth1UserHandler(
            get_secret("twitter_consumer_key"),
            get_secret("twitter_consumer_secret"),
            get_secret("twitter_access_token"),
            get_secret("twitter_access_token_secret")
        )
        api = tweepy.API(auth)
        client = tweepy.Client(
            consumer_key=get_secret("twitter_consumer_key"),
            consumer_secret=get_secret("twitter_consumer_secret"),
            access_token=get_secret("twitter_access_token"),
            access_token_secret=get_secret("twitter_access_token_secret")
        )

        creds, _ = google.auth.default()
        service = build('sheets', 'v4', credentials=creds)
        sheet = service.spreadsheets()
        result = sheet.values().get(spreadsheetId=SPREADSHEET_ID, range=f"{SHEET_NAME}!A2:H").execute()
        values = result.get('values', [])

        now_jst = datetime.datetime.now(JST)
        posted_any = False

        for i, row in enumerate(values, start=2):
            if len(row) < 6 or row[5].strip() == '':
                tweet_text = row[0]
                image_urls = row[1:5]
                scheduled_time_str = row[5].strip()

                try:
                    target_time = datetime.datetime.strptime(scheduled_time_str, "%Y/%m/%d %H:%M")
                    target_time = JST.localize(target_time)
                except Exception as e:
                    logging.warning(f"⏰ 投稿予定時刻の解析に失敗（行{i}）: {e}")
                    continue

                if now_jst < target_time:
                    continue  # まだ投稿予定時刻に達していない

                media_ids = []
                for url in image_urls:
                    if not url.strip():
                        continue
                    try:
                        file_id = url.split('/d/')[1].split('/')[0]
                        image_bytes = get_image_from_drive(file_id)
                        with tempfile.NamedTemporaryFile(delete=False, suffix=".png") as tmp:
                            tmp.write(image_bytes)
                            tmp.flush()
                            media = api.media_upload(tmp.name)
                            media_ids.append(media.media_id)
                            os.unlink(tmp.name)
                    except Exception as e:
                        logging.warning(f"画像取得失敗: {url} → {e}")

                try:
                    if media_ids:
                        client.create_tweet(text=tweet_text, media_ids=media_ids)
                    else:
                        client.create_tweet(text=tweet_text)
                    result_status = "SUCCESS"
                    logging.info(f"✅ 投稿成功: {tweet_text}")
                except TooManyRequests:
                    logging.warning("❌ 投稿失敗（429 Too Many Requests）")
                    result_status = "RATE_LIMIT"
                except Exception as e:
                    logging.exception(f"❌ 投稿失敗: {e}")
                    result_status = "FAILED"

                timestamp = now_jst.strftime("%Y/%m/%d %H:%M:%S")
                sheet.values().update(
                    spreadsheetId=SPREADSHEET_ID,
                    range=f"{SHEET_NAME}!G{i}",
                    valueInputOption="RAW",
                    body={"values": [[f"{timestamp} ({result_status})"]]}
                ).execute()

                posted_any = True

        return ("✅ 投稿完了" if posted_any else "ℹ️ 投稿対象なし"), 200

    except Exception as e:
        logging.exception(f"❌ 関数実行中にエラー: {e}")
        return "Internal Error", 500
