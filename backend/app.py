from flask import Flask
from admin import admin_bp
from users import users_bp
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Register blueprints
app.register_blueprint(admin_bp)
app.register_blueprint(users_bp)

if __name__ == '__main__':
    app.run(debug=True)