#!/usr/bin/python3

import psycopg2

query = sys.argv[0]

with psycopg2.connect("dbname=matthieu user=matthieu") as connection:
    try:
        cursor = connection.cursor()
        cursor.execute(query)
        results = cursor.fetchall()
        print(results)
    except Exception as e:
        print(e)
