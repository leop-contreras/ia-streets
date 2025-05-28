import requests
import json

if __name__ == '__main__':
    data = {}
    with open('./back/data.json', 'r') as file:
        data = json.load(file)
        print(data)
        r = requests.post("http://localhost:8000/get_path", json=data)
        print(r.content)