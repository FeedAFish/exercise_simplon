from os import getenv as getenv

PARAMS = {
    'dbname': getenv('DB_NAME', 'postgres'),
    'user': getenv('DB_USER', 'postgres'),
    'password': getenv('DB_PASSWORD', 'postgres'),
    'host': getenv('DB_HOST', 'localhost'),
    'port': getenv('DB_PORT', '5432')
}