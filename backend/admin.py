from flask import Blueprint, request, jsonify
from db import get_db
from werkzeug.security import check_password_hash
from datetime import datetime

admin_bp = Blueprint('admin', __name__)

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
    if not username or not password:
        return jsonify({'message': 'Username and password required'}), 400
    db = get_db()
    user = db.users.find_one({'username': username, 'role': 'admin'})
    if user and (user.get('password') == password or check_password_hash(user.get('password', ''), password)):
        return jsonify({'message': 'Login successful', 'username': username})
    return jsonify({'message': 'Invalid credentials'}), 401

@admin_bp.route('/admin/product/add_product', methods=['POST'])
def add_product():
    data = request.get_json()
    required_fields = [
        'product_id', 'name', 'barcode', 'description', 'price',
        'discount_id', 'stck_qty', 'image_url', 'is_active', 'created_at'
    ]
    if not data or not all(field in data for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400
    db = get_db()
    # Optionally, check for duplicate product_id or barcode
    if db.products.find_one({'product_id': data['product_id']}):
        return jsonify({'message': 'Product ID already exists'}), 400
    if db.products.find_one({'barcode': data['barcode']}):
        return jsonify({'message': 'Barcode already exists'}), 400
    # Insert product
    db.products.insert_one({
        'product_id': data['product_id'],
        'name': data['name'],
        'barcode': data['barcode'],
        'description': data['description'],
        'price': float(data['price']),
        'discount_id': data['discount_id'],
        'stck_qty': int(data['stck_qty']),
        'image_url': data['image_url'],
        'is_active': bool(data['is_active']),
        'created_at': data['created_at']
    })
    return jsonify({'message': 'Product added successfully'}), 201

@admin_bp.route('/admin/product/update_product', methods=['PUT'])
def update_product():
    data = request.get_json()
    if not data or 'product_id' not in data:
        return jsonify({'message': 'Missing product_id'}), 400
    db = get_db()
    update_fields = {k: v for k, v in data.items() if k != 'product_id'}
    result = db.products.update_one({'product_id': data['product_id']}, {'$set': update_fields})
    if result.matched_count == 0:
        return jsonify({'message': 'Product not found'}), 404
    return jsonify({'message': 'Product updated successfully'}), 200

@admin_bp.route('/admin/product/get_products', methods=['GET'])
def get_products():
    db = get_db()
    products = list(db.products.find({}, {'image_url': 0}))  # Exclude image_url
    for product in products:
        product['_id'] = str(product['_id'])  # Convert ObjectId to string for JSON
    return jsonify({'products': products}), 200