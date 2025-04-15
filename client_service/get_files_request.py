from utils.get_files_request import get_files_request
import argparse


# Create the parser
parser = argparse.ArgumentParser()

# Add an argument
parser.add_argument("url", help="url to download")

# Parse the argument
args = parser.parse_args()

# Check if url is empty
if args.url == "":
    print("Please provide a url")
    exit()

if __name__ == "__main__":
    get_files_request(args.url)