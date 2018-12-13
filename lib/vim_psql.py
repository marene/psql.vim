#!/usr/bin/python3

import psycopg2
import sys
import json
import vim

queryFromVim = sys.argv[0]

class FormattedResults:
    def __init__(self, cursor):
        results = cursor.fetchall()
        columnsNames = [desc[0] for desc in cursor.description]

        self.columnsNumber = len(columnsNames)
        self.rowsNumber = len(results)
        self.rows = [None]*(self.rowsNumber + 1)
        self.columnsMaxLengths = [0]*self.columnsNumber # Size of the longest element of each column
        self.rows[0] = columnsNames
        
        for i in range(self.rowsNumber):
            self.rows[i + 1] = [str(elem) for elem in results[i]]

        # find longest element for each column
        for columnNb in range(self.columnsNumber):
            for rowNb in range(self.rowsNumber + 1):
                columnLen = len(self.rows[rowNb][columnNb])
                if  columnLen > self.columnsMaxLengths[columnNb]:
                    self.columnsMaxLengths[columnNb] = columnLen

        # re-writing every cells with proper spacing
        for columnNb in range(self.columnsNumber):
            for rowNb in range(self.rowsNumber + 1):
                self.rows[rowNb][columnNb] = "| " + self.rows[rowNb][columnNb] + " " * (self.columnsMaxLengths[columnNb] - len(self.rows[rowNb][columnNb])) + " "

    def print(self):
        for rowNb in range(self.rowsNumber + 1):
            print("\n")
            for columnNb in range(self.columnsNumber):
                print(self.rows[rowNb][columnNb], end="")

def executeQuery(connection, query):
    cursor = connection.cursor()
    cursor.execute(query)
    return cursor

with psycopg2.connect("dbname=matthieu user=matthieu") as connection:
    try:
        cursor = executeQuery(connection, queryFromVim)
        formattedResults = FormattedResults(cursor)
        vim.command("let g:psqlvimQueryResult = {0}".format(str(formattedResults.rows)))
    except Exception as e:
        print(e)
        raise e
