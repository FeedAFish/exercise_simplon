from utils.get_files_request import get_files_request
import argparse

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("url", help="url to download")
args = parser.parse_args()

# Check if url is empty
if args.url == "":
    print("Please provide a url")
    exit()

if __name__ == "__main__":
    get_files_request(args.url)