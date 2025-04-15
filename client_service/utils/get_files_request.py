import requests
from urllib.parse import unquote
import os

def get_files_request(url):
    response = requests.get(url=url)

    filename = unquote(response.headers['content-disposition'].split("filename*=UTF-8''")[1])
    new_filename = filename.split(".")[0]

    if not os.path.exists('data'):
        os.makedirs('data')

    i = 0
    while os.path.exists('data/' +new_filename+'.csv'):
        new_filename = filename.split(".")[0] + "_" + str(i)
        i += 1

    with open('data/' +new_filename+'.csv', 'wb') as f:
        for chunk in response.iter_content(chunk_size=512 * 1024): 
            if chunk:
                f.write(chunk)

    print("File saved as " + new_filename + '.csv')
