from flask import Blueprint, request, jsonify
from db import get_db
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from collections import Counter


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
    # add a cart in cart_items collection

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
    
    # Count occurrences of each product_id to get quantities
    product_counts = Counter(product_ids)
    
    # Fetch product details for unique product_ids with discount information
    products = []
    if product_counts:
        # Get unique product IDs to fetch from database
        unique_product_ids = list(product_counts.keys())
        product_details = db.products.find({'product_id': {'$in': unique_product_ids}})
        
        for product in product_details:
            # Check if product has an active discount
            discount_price = product['price']
            discount_percentage = 0
            discount_name = None
            
            if 'discount_id' in product and product['discount_id']:
                discount = db.discounts.find_one({'_id': product['discount_id']})
                if discount and discount['status'] == 'Active':
                    # Check if discount is within valid date range
                    current_date = datetime.now().date()
                    start_date = discount['start_date'].date() if isinstance(discount['start_date'], datetime) else discount['start_date']
                    end_date = discount['end_date'].date() if isinstance(discount['end_date'], datetime) else discount['end_date']
                    
                    if start_date <= current_date <= end_date:
                        discount_percentage = discount['percentage']
                        discount_price = product['price'] * (1 - discount_percentage / 100)
                        discount_name = discount['name']
            
            # Get quantity for this product
            quantity = product_counts[product['product_id']]
            
            products.append({
                'product_id': product['product_id'],
                'name': product['name'],
                'price': product['price'],
                'discount_price': round(discount_price, 2),
                'discount_percentage': discount_percentage,
                'discount_name': discount_name,
                'quantity': quantity,
                'total_price': round(discount_price * quantity, 2),
                'original_total': round(product['price'] * quantity, 2)
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

@users_bp.route('/users/view_discounts', methods=['GET'])
def view_discounts():
    db = get_db()
    try:
        # Get all active discounts that are currently valid
        current_date = datetime.now().date()
        
        # Find active discounts within valid date range
        active_discounts = db.discounts.find({
            'status': 'Active',
            'start_date': {'$lte': current_date},
            'end_date': {'$gte': current_date}
        })
        
        discounts_list = []
        for discount in active_discounts:
            # Get product details for each discount
            product = db.products.find_one({'barcode': discount['product_barcode']})
            if product:
                discount_info = {
                    'discount_id': str(discount['_id']),
                    'name': discount['name'],
                    'percentage': discount['percentage'],
                    'start_date': discount['start_date'].strftime('%Y-%m-%d') if isinstance(discount['start_date'], datetime) else discount['start_date'],
                    'end_date': discount['end_date'].strftime('%Y-%m-%d') if isinstance(discount['end_date'], datetime) else discount['end_date'],
                    'product_name': discount['product_name'],
                    'product_barcode': discount['product_barcode'],
                    'original_price': product['price'],
                    'discounted_price': round(product['price'] * (1 - discount['percentage'] / 100), 2),
                    'savings': round(product['price'] * (discount['percentage'] / 100), 2)
                }
                discounts_list.append(discount_info)
        
        return jsonify({'discounts': discounts_list}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching discounts: {str(e)}'}), 500


# ------------------ Order Placement APIs ------------------
@users_bp.route('/users/orders/place_order', methods=['POST'])
def place_order():
    data = request.get_json()
    required_fields = ['phone_number', 'payment_method', 'delivery_address']
    if not data or not all(field in data for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400
    
    db = get_db()
    
    try:
        # Get user's cart
        cart = db.cart_items.find_one({'cart_id': data['phone_number']})
        if not cart or not cart.get('product_id') or len(cart['product_id']) == 0:
            return jsonify({'message': 'Cart is empty'}), 400
        
        # Get user details for customer name
        user = db.users.find_one({'phone_number': data['phone_number']})
        customer_name = user.get('name', 'Unknown Customer') if user else 'Unknown Customer'
        
        # Get cart products with quantities and calculate totals
        product_ids = cart['product_id']
        product_counts = Counter(product_ids)
        unique_product_ids = list(product_counts.keys())
        
        # Fetch product details and calculate order totals
        products = []
        total_order_amount = 0
        total_original_amount = 0
        
        product_details = db.products.find({'product_id': {'$in': unique_product_ids}})
        for product in product_details:
            # Check for active discounts
            discount_price = product['price']
            discount_percentage = 0
            discount_name = None
            
            if 'discount_id' in product and product['discount_id']:
                discount = db.discounts.find_one({'_id': product['discount_id']})
                if discount and discount['status'] == 'Active':
                    current_date = datetime.now().date()
                    start_date = discount['start_date'].date() if isinstance(discount['start_date'], datetime) else discount['start_date']
                    end_date = discount['end_date'].date() if isinstance(discount['end_date'], datetime) else discount['end_date']
                    
                    if start_date <= current_date <= end_date:
                        discount_percentage = discount['percentage']
                        discount_price = product['price'] * (1 - discount_percentage / 100)
                        discount_name = discount['name']
            
            quantity = product_counts[product['product_id']]
            item_total = discount_price * quantity
            original_total = product['price'] * quantity
            
            total_order_amount += item_total
            total_original_amount += original_total
            
            products.append({
                'product_id': product['product_id'],
                'name': product['name'],
                'price': product['price'],
                'discount_price': round(discount_price, 2),
                'discount_percentage': discount_percentage,
                'discount_name': discount_name,
                'quantity': quantity,
                'item_total': round(item_total, 2),
                'original_total': round(original_total, 2)
            })
        
        # Create order with current date and time
        current_datetime = datetime.now()
        order_data = {
            'user_id': data['phone_number'],
            'customer_name': customer_name,
            'order_date': current_datetime,
            'order_date_string': current_datetime.strftime('%Y-%m-%d %H:%M:%S'),
            'order_timestamp': current_datetime.timestamp(),
            'products': products,
            'total_amount': round(total_order_amount, 2),
            'original_total_amount': round(total_original_amount, 2),
            'total_savings': round(total_original_amount - total_order_amount, 2),
            'payment_method': data['payment_method'],
            'delivery_address': data['delivery_address'],
            'order_status': 'Pending',
            'payment_status': 'Pending',
            'delivery_status': 'Done',  # Set to "Done" as requested
            'created_at': current_datetime,
            'updated_at': current_datetime
        }
        
        # Insert order into orders collection
        order_result = db.orders.insert_one(order_data)
        order_id = str(order_result.inserted_id)
        
        # Create order items for detailed tracking
        order_items = []
        for product in products:
            order_item = {
                'order_id': order_id,
                'product_id': product['product_id'],
                'product_name': product['name'],
                'quantity': product['quantity'],
                'unit_price': product['discount_price'],
                'total_price': product['item_total'],
                'original_unit_price': product['price'],
                'original_total_price': product['original_total'],
                'discount_percentage': product['discount_percentage'],
                'discount_name': product['discount_name'],
                'created_at': current_datetime
            }
            order_items.append(order_item)
        
        # Insert order items
        if order_items:
            db.order_items.insert_many(order_items)
        
        # Create payment record
        payment_data = {
            'order_id': order_id,
            'user_id': data['phone_number'],
            'amount': total_order_amount,
            'payment_method': data['payment_method'],
            'payment_status': 'Pending',
            'transaction_id': f"TXN_{int(current_datetime.timestamp())}_{data['phone_number']}",
            'created_at': current_datetime,
            'updated_at': current_datetime
        }
        
        db.payments.insert_one(payment_data)
        
        # Clear the user's cart after successful order placement
        db.cart_items.update_one(
            {'cart_id': data['phone_number']},
            {'$set': {'product_id': []}}
        )
        
        return jsonify({
            'message': 'Order placed successfully',
            'order_id': order_id,
            'order_date': current_datetime.strftime('%Y-%m-%d %H:%M:%S'),
            'total_amount': total_order_amount,
            'total_savings': round(total_original_amount - total_order_amount, 2)
        }), 201
        
    except Exception as e:
        return jsonify({'message': f'Error placing order: {str(e)}'}), 500

@users_bp.route('/users/orders/get_orders', methods=['POST'])
def get_user_orders():
    data = request.get_json()
    required_fields = ['phone_number']
    if not data or not all(field in data for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400
    
    db = get_db()
    
    try:
        # Get user's orders
        orders = list(db.orders.find(
            {'user_id': data['phone_number']},
            {'_id': 0}  # Exclude MongoDB _id
        ).sort('order_date', -1))  # Sort by order date, newest first
        
        # Format dates for frontend
        for order in orders:
            if 'order_date' in order and isinstance(order['order_date'], datetime):
                order['order_date'] = order['order_date'].strftime('%Y-%m-%d %H:%M:%S')
            if 'created_at' in order and isinstance(order['created_at'], datetime):
                order['created_at'] = order['created_at'].strftime('%Y-%m-%d %H:%M:%S')
            if 'updated_at' in order and isinstance(order['updated_at'], datetime):
                order['updated_at'] = order['updated_at'].strftime('%Y-%m-%d %H:%M:%S')
        
        return jsonify({'orders': orders}), 200
        
    except Exception as e:
        return jsonify({'message': f'Error fetching orders: {str(e)}'}), 500

@users_bp.route('/users/orders/get_order_details', methods=['POST'])
def get_order_details():
    data = request.get_json()
    required_fields = ['phone_number', 'order_id']
    if not data or not all(field in data for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400
    
    db = get_db()
    
    try:
        from bson import ObjectId
        
        # Get order details
        order = db.orders.find_one(
            {'user_id': data['phone_number'], '_id': ObjectId(data['order_id'])},
            {'_id': 0}
        )
        
        if not order:
            return jsonify({'message': 'Order not found'}), 404
        
        # Get order items
        order_items = list(db.order_items.find(
            {'order_id': data['order_id']},
            {'_id': 0}
        ))
        
        # Format dates
        if 'order_date' in order and isinstance(order['order_date'], datetime):
            order['order_date'] = order['order_date'].strftime('%Y-%m-%d %H:%M:%S')
        if 'created_at' in order and isinstance(order['created_at'], datetime):
            order['created_at'] = order['created_at'].strftime('%Y-%m-%d %H:%M:%S')
        if 'updated_at' in order and isinstance(order['updated_at'], datetime):
            order['updated_at'] = order['updated_at'].strftime('%Y-%m-%d %H:%M:%S')
        
        for item in order_items:
            if 'created_at' in item and isinstance(item['created_at'], datetime):
                item['created_at'] = item['created_at'].strftime('%Y-%m-%d %H:%M:%S')
        
        return jsonify({
            'order': order,
            'order_items': order_items
        }), 200
        
    except Exception as e:
        return jsonify({'message': f'Error fetching order details: {str(e)}'}), 500


# ------------------ Auth APIs ------------------
@users_bp.route('/users/signup', methods=['POST'])
def users_signup():
    data = request.get_json() or {}
    required_fields = ['phone_number', 'password']
    if not all(field in data and data[field] for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400

    db = get_db()

    # Ensure user does not already exist
    existing = db.users.find_one({'phone_number': data['phone_number']})
    if existing:
        return jsonify({'message': 'User already exists'}), 400

    # Hash password
    hashed_password = generate_password_hash(data['password'])

    user_doc = {
        'user_id': data['phone_number'],  # use phone as user_id for simplicity
        'phone_number': data['phone_number'],
        'password': hashed_password,
        'name': data.get('name', ''),
        'role': 'users',
        'created_at': data.get('created_at')
    }

    db.users.insert_one(user_doc)

    # Create an empty cart for the user
    db.cart_items.insert_one({
        'cart_id': data['phone_number'],
        'product_id': []
    })

    return jsonify({'message': 'Signup successful'}), 201


@users_bp.route('/users/login', methods=['POST'])
def users_login():
    data = request.get_json() or {}
    required_fields = ['phone_number', 'password']
    if not all(field in data and data[field] for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400

    db = get_db()
    user = db.users.find_one({'phone_number': data['phone_number']})
    if not user:
        return jsonify({'message': 'Invalid credentials'}), 401

    stored_pwd = user.get('password', '')
    valid = stored_pwd == data['password'] or check_password_hash(stored_pwd, data['password'])
    if not valid:
        return jsonify({'message': 'Invalid credentials'}), 401

    return jsonify({
        'message': 'Login successful',
        'user': {
            'user_id': user.get('user_id'),
            'phone_number': user.get('phone_number'),
            'name': user.get('name', ''),
            'role': user.get('role', 'users')
        }
    }), 200








