from flask import Blueprint, request, jsonify

admin_bp = Blueprint('admin', __name__)

ADMIN_CREDENTIALS = {
    'username': 'admin',
    'password': 'admin'
}

@admin_bp.route('/admin')
def admin_home():
    return {'message': 'Admin Home'}

@admin_bp.route('/admin/login', methods=['POST'])
def admin_login():
    data = request.get_json()
    if not data:
        return jsonify({'message': 'Missing JSON'}), 400
    username = data.get('username')
    password = data.get('password')
    if username == ADMIN_CREDENTIALS['username'] and password == ADMIN_CREDENTIALS['password']:
        return jsonify({'message': 'Login successful', 'username': username})
    return jsonify({'message': 'Invalid credentials'}), 401