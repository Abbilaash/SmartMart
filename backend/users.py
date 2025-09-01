from flask import Blueprint, request, jsonify
from db import get_db


users_bp = Blueprint('users', __name__)

#------------------TODO-----------------
# Get products from the cart_items of specific cart.
# Add product to cart
# Delete product from cart

# Support both snake_case and compact route names
@users_bp.route('/users/carts/get_products', methods=['GET'])
def get_products():
    data = request.get_json()
    required_fileds = ['phone_number']
    if not data or not all(field in data for field in required_fileds):
        return jsonify({'message': 'Missing required fields'}), 400
    db = get_db()
    cart = db.cart_items.find_one({'cart_id': data['phone_number']})
    print(cart)
    
    # Get the product_ids list from the cart
    if 'product_id' not in cart or not isinstance(cart['product_id'], list):
        return jsonify({'products': []}), 200
    
    product_ids = cart['product_id']
    
    # Fetch product details for all product_ids
    products = []
    if product_ids:
        product_details = db.products.find({'product_id': {'$in': product_ids}})
        for product in product_details:
            products.append({
                'product_id': product['product_id'],
                'name': product['name'],
                'price': product['price']
            })
    
    return jsonify({'products': products}), 200

@users_bp.route('/users/carts/add_product', methods=['POST'])
def add_products():
    data = request.get_json()
    required_fileds = ['phone_number', 'product_id']
    if not data or not all(field in data for field in required_fileds):
        return jsonify({'message': 'Missing required fields'}), 400
    db = get_db()
    cart = db.cart_items.find_one({'cart_id': data['phone_number']})
    if not cart:
        return jsonify({'message': 'Cart not found'}), 404
    cart['product_id'].append(data['product_id'])
    db.cart_items.update_one({'cart_id': data['phone_number']}, {'$set': {'product_id': cart['product_id']}})
    return jsonify({'message': 'Product added to cart'}), 200

@users_bp.route('/users/carts/delete_product', methods=['POST'])
def delete_products():
    data = request.get_json()
    required_fileds = ['phone_number', 'product_id']
    if not data or not all(field in data for field in required_fileds):
        return jsonify({'message': 'Missing required fields'}), 400
    db = get_db()
    db.cart_items.delete_one({'cart_id': data['phone_number'], 'product_id': data['product_id']})
    return jsonify({'message': 'Product deleted from cart'}), 200


















