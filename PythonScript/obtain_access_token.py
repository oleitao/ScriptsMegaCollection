#https://github.com/reddit-archive/reddit/wiki/OAuth2-Quick-Start-Example
import requests
import requests.auth

client_auth = requests.auth.HTTPBasicAuth('<REDDIT_CLIENT_ID>', '<REDDIT_CLIENT_SECRET>')
post_data = {"grant_type": "password", "username": "<REDDIT_CLIENT_USERNAME>", "password": "<REDDIT_CLIENT_PASSWORD>"}
headers = {"User-Agent": "ChangeMeClient/0.1 by YourUsername"}
response = requests.post("https://www.reddit.com/api/v1/access_token", auth=client_auth, data=post_data, headers=headers)
print(response.json())