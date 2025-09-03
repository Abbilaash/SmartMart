from flask import Blueprint, request, jsonify
from db import get_db


users_bp = Blueprint('users', __name__)

#------------------TODO-----------------
# checkout api (razorpay payment gateway)
    # update the product quantity after checkout
    # add the order to the orders collection
    # add the order items to the order_items collection
    # add the payment to the payments collection
    # add the payment method to the payment_methods collection
# login api
# signup api

# Support both snake_case and compact route names
@users_bp.route('/users/carts/get_products', methods=['POST'])
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
    
    # First, atomically decrease stock by 1 only if stock > 0
    stock_update_result = db.products.update_one(
        {'product_id': data['product_id'], 'stck_qty': {'$gt': 0}},
        {'$inc': {'stck_qty': -1}}
    )
    
    if stock_update_result.modified_count == 0:
        # Either product not found or out of stock
        return jsonify({'message': 'Product not found or out of stock'}), 400
    
    # Then, add the product to the cart
    cart = db.cart_items.find_one({'cart_id': data['phone_number']})
    if not cart:
        # Roll back stock decrement if cart not found
        db.products.update_one(
            {'product_id': data['product_id']},
            {'$inc': {'stck_qty': 1}}
        )
        return jsonify({'message': 'Cart not found'}), 404
    
    # Ensure cart has a list for product_id
    if 'product_id' not in cart or not isinstance(cart['product_id'], list):
        cart['product_id'] = []
    
    cart['product_id'].append(data['product_id'])
    db.cart_items.update_one(
        {'cart_id': data['phone_number']}, 
        {'$set': {'product_id': cart['product_id']}}
    )
    
    return jsonify({'message': 'Product added to cart after decreasing stock'}), 200

@users_bp.route('/users/carts/delete_product', methods=['POST'])
def delete_products():
    data = request.get_json()
    required_fileds = ['phone_number', 'product_id']
    if not data or not all(field in data for field in required_fileds):
        return jsonify({'message': 'Missing required fields'}), 400
    
    db = get_db()
    
    # Find the cart by phone_number
    cart = db.cart_items.find_one({'cart_id': data['phone_number']})
    if not cart:
        return jsonify({'message': 'Cart not found'}), 404
    
    # Check if product exists in cart
    if 'product_id' not in cart or not isinstance(cart['product_id'], list):
        return jsonify({'message': 'No products in cart'}), 400
    
    # Check if product is actually in the cart
    if data['product_id'] not in cart['product_id']:
        return jsonify({'message': 'Product not found in cart'}), 404
    
    # First, increment the product stock by 1
    stock_update_result = db.products.update_one(
        {'product_id': data['product_id']},
        {'$inc': {'stck_qty': 1}}
    )
    
    if stock_update_result.modified_count == 0:
        return jsonify({'message': 'Product not found in products collection'}), 404
    
    # Then, remove the product from cart
    cart['product_id'].remove(data['product_id'])
    
    # Update the cart
    db.cart_items.update_one(
        {'cart_id': data['phone_number']}, 
        {'$set': {'product_id': cart['product_id']}}
    )
    
    return jsonify({'message': 'Product stock increased and removed from cart'}), 200


















