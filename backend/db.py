from flask import current_app, g
from pymongo import MongoClient
from dotenv import load_dotenv
import os

load_dotenv()

# You can set your MongoDB URI here or load from config
def get_db():
    if 'db' not in g:
        client = MongoClient(os.getenv('MONGO_URI'))
        g.db = client['database']
    return g.db