import requests
import errno
r = requests.get("http://www.example.com")
print(r.content)
r.close()