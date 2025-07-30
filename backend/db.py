from flask import current_app, g
from pymongo import MongoClient

# You can set your MongoDB URI here or load from config
def get_db():
    if 'db' not in g:
        client = MongoClient('mongodb://localhost:27017/')
        g.db = client['smartmart']
    return g.db