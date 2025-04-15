# Brief project SIMPLON

This project provides a PostgresSQL database to analyse the sales of a company based on their data provied with a client service to import, modify and extract data from the database.

## Infrastruture schema
![Schema](imgs/schema.png.png)

The schema of the infrastruture is shown in the image above.
## Database schema

![Schema_db](imgs/schema_db.png.png)

The schema of the database is shown in the image above.

## Installation

1. Clone the project

```bash
git clone git@github.com:FeedAFish/exercise_simplon.git
```

2. Build Docker Compose

```bash
docker-compose up --build -d
```

## Usage

To open the bash shell of client service, run:

```bash
# Default is client-service
# You can change image name in docker-compose.yml
docker exec -it client-service bash
```

### First run

To create tables inside database:

```bash
# In bash shell of client-service
# 'postgres' is by default
PGPASSWORD=postgres psql -h postgres -U postgres -d postgres -f Scripts/init.sql
```

### Commands
To receive file by request url (only tested on google sheet):

```bash
# In bash shell of client-service
# Files will be saved in $(cwd)/data/
python get_files_request.py 'your_url'
```

To import from a csv to your database:

```bash
# In bash shell of client-service
# table_name for this project is stores, products and sales
python table_insert_by_csv.py table_name -f 'csv_path'
```

To create/update changes to aggregate views:

```bash
# In bash shell of client-service
# 'postgres' is by default
PGPASSWORD=postgres psql -h postgres -U postgres -d postgres -f Scripts/update_view.sql
```

To access sql shell:
```bash
# In bash shell of client-service
# 'postgres' is by default
PGPASSWORD=postgres psql -h postgres -U postgres -d postgres
```

## License

This project is licensed under the [MIT License](LICENSE).