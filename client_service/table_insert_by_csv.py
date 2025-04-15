from utils.insert_by_csv import insert_csv
import argparse

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("table", help="table to insert into")
parser.add_argument("-f", '--file', help="csv file's path")

args = parser.parse_args()

if args.table == "" or args.file == "":
    print("Please provide a table's name and a csv's path")
    exit()

if __name__ == "__main__":
    insert_csv(args.file, args.table)