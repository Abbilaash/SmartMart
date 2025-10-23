# ------------------ Payments API for Profile Graph ------------------

from flask import Blueprint, request, jsonify
from db import get_db
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from collections import Counter
import stripe
import dotenv, os

dotenv.load_dotenv()

stripe.api_key = os.getenv("STRIPE_SECRET_KEY")

users_bp = Blueprint('users', __name__)

#------------------TODO-----------------
# make the payment gatewey
# apply discounts to the products scanned

# Support both snake_case and compact route names
@users_bp.route('/users/payments/get_payments', methods=['POST'])
def get_user_payments():
    data = request.get_json()
    required_fields = ['user_id']
    if not data or not all(field in data for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400

    db = get_db()
    try:
        # Get last 7 payments for the user, sorted by created_at descending
        payments = list(db.payments.find(
            {'user_id': data['user_id']},
            {'_id': 0}
        ).sort('created_at', -1).limit(7))

        # Format dates for frontend
        for payment in payments:
            if 'created_at' in payment and isinstance(payment['created_at'], datetime):
                payment['created_at'] = payment['created_at'].strftime('%Y-%m-%d %H:%M:%S')
        return jsonify({'payments': payments}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching payments: {str(e)}'}), 500



@users_bp.route('/users/carts/get_products', methods=['POST'])
def get_products():
    data = request.get_json()
    required_fileds = ['phone_number']
    if not data or not all(field in data for field in required_fileds):
        return jsonify({'message': 'Missing required fields'}), 400
    db = get_db()
    cart = db.cart_items.find_one({'cart_id': data['phone_number']})
    
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
            
            discount = None
            
            # First: Check if product has discount_id field
            if 'discount_id' in product and product['discount_id']:
                discount = db.discounts.find_one({'_id': product['discount_id']})
            
            # Second: If no discount found via discount_id, search by product_barcode
            if not discount:
                # Try to find discount by product_barcode matching product_id or barcode
                product_barcode = product.get('barcode', product['product_id'])
                discount = db.discounts.find_one({
                    'product_barcode': product_barcode,
                    'status': 'Active'
                })
            
            if discount and discount['status'] == 'Active':
                # Check if discount is within valid date range
                current_datetime = datetime.now()
                
                # Handle both datetime and date objects for comparison
                start_date = discount['start_date']
                end_date = discount['end_date']
                
                # Convert to datetime if they are date objects
                if hasattr(start_date, 'date'):  # It's a datetime object
                    start_datetime = start_date
                else:  # It's a date object, convert to datetime
                    start_datetime = datetime.combine(start_date, datetime.min.time())
                
                if hasattr(end_date, 'date'):  # It's a datetime object
                    end_datetime = end_date
                else:  # It's a date object, convert to datetime
                    end_datetime = datetime.combine(end_date, datetime.max.time())
                
                if start_datetime <= current_datetime <= end_datetime:
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

@users_bp.route('/products/<product_id>', methods=['GET'])
def get_product_by_id(product_id):
    """Get a single product by product_id/barcode with discount information"""
    db = get_db()
    try:
        # Find product by product_id (which could be barcode) or by barcode field
        product = db.products.find_one({'product_id': product_id})
        if not product:
            # Also try searching by barcode field
            product = db.products.find_one({'barcode': product_id})
        
        if not product:
            return jsonify({'message': 'Product not found'}), 404
        
        # Check if product has an active discount
        discount_price = product['price']
        discount_percentage = 0
        discount_name = None
        discount_debug_info = []
        
        discount = None
        
        # First: Check if product has discount_id field
        if 'discount_id' in product and product['discount_id']:
            discount_debug_info.append(f"Product has discount_id: {product['discount_id']}")
            discount = db.discounts.find_one({'_id': product['discount_id']})
            if discount:
                discount_debug_info.append(f"Found discount via discount_id: {discount['name']}")
        
        # Second: If no discount found via discount_id, search by product_barcode
        if not discount:
            # Try to find discount by product_barcode matching product_id or barcode
            product_barcode = product.get('barcode', product['product_id'])
            discount = db.discounts.find_one({
                'product_barcode': product_barcode,
                'status': 'Active'
            })
            if discount:
                discount_debug_info.append(f"Found discount via product_barcode match: {discount['name']}")
            else:
                discount_debug_info.append(f"No discount found for product_barcode: {product_barcode}")
        
        if not discount:
            discount_debug_info.append("No discount found for this product")
        else:
            discount_debug_info.append(f"Found discount: {discount['name']}, Status: {discount['status']}")
            
            if discount['status'] != 'Active':
                discount_debug_info.append("Discount is not Active")
            else:
                # Check if discount is within valid date range
                current_datetime = datetime.now()
                discount_debug_info.append(f"Current datetime: {current_datetime}")
                
                # Handle both datetime and date objects for comparison
                start_date = discount['start_date']
                end_date = discount['end_date']
                discount_debug_info.append(f"Discount period: {start_date} to {end_date}")
                
                # Convert to datetime if they are date objects
                if hasattr(start_date, 'date'):  # It's a datetime object
                    start_datetime = start_date
                else:  # It's a date object, convert to datetime
                    start_datetime = datetime.combine(start_date, datetime.min.time())
                
                if hasattr(end_date, 'date'):  # It's a datetime object
                    end_datetime = end_date
                else:  # It's a date object, convert to datetime
                    end_datetime = datetime.combine(end_date, datetime.max.time())
                
                discount_debug_info.append(f"Converted period: {start_datetime} to {end_datetime}")
                
                if start_datetime <= current_datetime <= end_datetime:
                    discount_percentage = discount['percentage']
                    discount_price = product['price'] * (1 - discount_percentage / 100)
                    discount_name = discount['name']
                    discount_debug_info.append(f"DISCOUNT APPLIED: {discount_percentage}% off")
                else:
                    discount_debug_info.append("Discount is outside valid date range")
        
        # Return product with discount information
        product_data = {
            'product_id': product['product_id'],
            'name': product['name'],
            'barcode': product.get('barcode', product['product_id']),
            'description': product.get('description', ''),
            'price': product['price'],
            'discount_price': round(discount_price, 2),
            'discount_percentage': discount_percentage,
            'discount_name': discount_name,
            'stck_qty': product['stck_qty'],
            'image_url': product.get('image_url', ''),
            'is_active': product.get('is_active', True),
            'created_at': product.get('created_at', ''),
            'discount_debug': discount_debug_info  # Remove this after debugging
        }
        
        return jsonify(product_data), 200
        
    except Exception as e:
        return jsonify({'message': f'Error fetching product: {str(e)}'}), 500

@users_bp.route('/users/view_discounts', methods=['GET'])
def view_discounts():
    db = get_db()
    try:
        # Get all active discounts that are currently valid
        current_datetime = datetime.now()
        current_date = current_datetime.date()
        
        # Find active discounts within valid date range
        # Convert current_date to datetime for MongoDB comparison
        active_discounts = db.discounts.find({
            'status': 'Active',
            'start_date': {'$lte': current_datetime},
            'end_date': {'$gte': current_datetime}
        })
        
        discounts_list = []
        for discount in active_discounts:
            # Get product details for each discount using both barcode and product_barcode fields
            product = None
            
            # Try to find product by product_barcode field in discount
            if 'product_barcode' in discount:
                product = db.products.find_one({'barcode': discount['product_barcode']})
                if not product:
                    # Also try matching with product_id
                    product = db.products.find_one({'product_id': discount['product_barcode']})
            
            # If product_barcode doesn't exist or no product found, try using discount_id relationship
            if not product:
                # Find products that have this discount_id
                product = db.products.find_one({'discount_id': discount['_id']})
            
            if product:
                # Use product name from database, fallback to discount's product_name
                product_name = product.get('name', discount.get('product_name', 'Unknown Product'))
                product_barcode = product.get('barcode', product.get('product_id', discount.get('product_barcode', 'N/A')))
                
                discount_info = {
                    'discount_id': str(discount['_id']),
                    'name': discount['name'],
                    'percentage': discount['percentage'],
                    'start_date': discount['start_date'].strftime('%Y-%m-%d') if isinstance(discount['start_date'], datetime) else str(discount['start_date']),
                    'end_date': discount['end_date'].strftime('%Y-%m-%d') if isinstance(discount['end_date'], datetime) else str(discount['end_date']),
                    'product_name': product_name,
                    'product_barcode': product_barcode,
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
    required_fields = ['phone_number', 'payment_method', 'billing_address']
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
            
            discount = None
            
            # First: Check if product has discount_id field
            if 'discount_id' in product and product['discount_id']:
                discount = db.discounts.find_one({'_id': product['discount_id']})
            
            # Second: If no discount found via discount_id, search by product_barcode
            if not discount:
                # Try to find discount by product_barcode matching product_id or barcode
                product_barcode = product.get('barcode', product['product_id'])
                discount = db.discounts.find_one({
                    'product_barcode': product_barcode,
                    'status': 'Active'
                })
            
            if discount and discount['status'] == 'Active':
                current_datetime = datetime.now()
                
                # Handle both datetime and date objects for comparison
                start_date = discount['start_date']
                end_date = discount['end_date']
                
                # Convert to datetime if they are date objects
                if hasattr(start_date, 'date'):  # It's a datetime object
                    start_datetime = start_date
                else:  # It's a date object, convert to datetime
                    start_datetime = datetime.combine(start_date, datetime.min.time())
                
                if hasattr(end_date, 'date'):  # It's a datetime object
                    end_datetime = end_date
                else:  # It's a date object, convert to datetime
                    end_datetime = datetime.combine(end_date, datetime.max.time())
                
                if start_datetime <= current_datetime <= end_datetime:
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
        # Normalize payment method label to desired display (Card/UPI)
        method = data['payment_method']
        method_display = 'Card' if str(method).lower() == 'card' else ('UPI' if str(method).lower() == 'upi' else str(method))

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
            'payment_method': method_display,
            'billing_address': data.get('billing_address', ''),
            'order_status': 'Completed',
            'payment_status': 'Completed',
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
        
        # Create payment record (store amount in paise)
        amount_paise = int(round(total_order_amount * 100))
        payment_data = {
            'order_id': order_id,
            'user_id': data['phone_number'],
            'amount': amount_paise,
            'payment_method': method_display,
            'payment_status': 'Completed',
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
            'total_amount_paise': amount_paise,
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


@users_bp.route('/users/change_password', methods=['POST'])
def change_password():
    data = request.get_json() or {}
    required_fields = ['phone_number', 'old_password', 'new_password']
    if not all(field in data and data[field] for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400

    db = get_db()
    
    # Find user by phone number
    user = db.users.find_one({'phone_number': data['phone_number']})
    if not user:
        return jsonify({'message': 'User not found'}), 404

    # Verify old password
    stored_pwd = user.get('password', '')
    old_password_valid = stored_pwd == data['old_password'] or check_password_hash(stored_pwd, data['old_password'])
    if not old_password_valid:
        return jsonify({'message': 'Current password is incorrect'}), 400

    # Hash new password
    new_hashed_password = generate_password_hash(data['new_password'])

    # Update password in database
    result = db.users.update_one(
        {'phone_number': data['phone_number']},
        {'$set': {'password': new_hashed_password}}
    )

    if result.modified_count == 0:
        return jsonify({'message': 'Failed to update password'}), 500

    return jsonify({'message': 'Password changed successfully'}), 200


@users_bp.route('/users/create-payment-session', methods=['POST'])
def create_payment_session():
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['amount', 'user_id']
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields: amount, user_id'}), 400

        amount = data['amount']
        user_id = data['user_id']
        order_id = data.get('order_id', f"order_{user_id}_{int(datetime.now().timestamp())}")

        # Optional billing information for card payments
        billing_address = data.get('billing_address')
        card_holder_name = data.get('card_holder_name')
        payment_method = data.get('payment_method', 'upi')
        amount_unit = (data.get('amount_unit') or '').lower()  # 'rupees' or 'paise'

    # Normalize amount into paise for storage and for Stripe (Stripe expects smallest currency unit)
        try:
            def infer_amount_paise(val) -> int:
                v = float(val)
                # Explicit unit overrides
                if amount_unit == 'paise':
                    return int(round(v))
                if amount_unit == 'rupees':
                    return int(round(v * 100))
                # Heuristic fallback:
                # - If integer and large (>=1000) and divisible by 100, likely already paise
                if v.is_integer():
                    vi = int(v)
                    if vi >= 1000 and vi % 100 == 0:
                        return vi
                    # If small integer, treat as rupees
                    return int(vi * 100)
                # Decimal -> rupees
                return int(round(v * 100))

            amount_paise = infer_amount_paise(amount)
        except Exception:
            return jsonify({'error': 'Invalid amount value'}), 400

        # Validate amount (minimum 50 paise = ₹0.50)
        if amount_paise < 50:
            return jsonify({'error': 'Amount must be at least ₹0.50 (50 paise)'}), 400
        
        # Create Stripe session metadata
        session_metadata = {
            'user_id': user_id,
            'order_id': order_id,
            'platform': 'smartmart'
        }
        
        # Add billing information to metadata if provided
        if billing_address:
            session_metadata['billing_address'] = billing_address
        if card_holder_name:
            session_metadata['card_holder_name'] = card_holder_name
            
        # Let Stripe determine supported payment methods automatically

        # Create Stripe payment session (hosted checkout to ensure a URL is returned)
        session = stripe.checkout.Session.create(
            line_items=[{
                'price_data': {
                    'currency': 'inr',
                    'product_data': {
                        'name': f'SmartMart Order #{order_id}',
                        'description': f'Payment for order {order_id}'
                    },
                    'unit_amount': amount_paise,  # Amount in paise
                },
                'quantity': 1,
            }],
            mode='payment',
            success_url='smartmart://payment-success?session_id={CHECKOUT_SESSION_ID}',
            cancel_url='smartmart://payment-cancel?session_id={CHECKOUT_SESSION_ID}',
            metadata=session_metadata
        )

        # Safety: Some SDK versions return url only after retrieval; re-fetch if missing
        session_url = getattr(session, 'url', None)
        if not session_url:
            try:
                session = stripe.checkout.Session.retrieve(session.id)
                session_url = getattr(session, 'url', None)
            except Exception:
                session_url = None
        
        # Store payment session in database for tracking
        db = get_db()
        current_datetime = datetime.now()
        
        # Generate transaction ID
        transaction_id = f"TXN_{int(current_datetime.timestamp())}_{user_id}"
        
        # Create payment record in payments collection (initially Pending)
        payment_record = {
            'order_id': order_id,
            'user_id': user_id,
            # store canonical amount in paise
            'amount': amount_paise,
            'payment_method': payment_method,
            'payment_status': 'Pending',
            'transaction_id': transaction_id,
            'created_at': current_datetime,
            'updated_at': current_datetime,
            'session_id': session.id,
            'currency': 'INR',
            'stripe_session': session.id
        }
        
        # Add billing information if provided
        if billing_address:
            payment_record['billing_address'] = billing_address
        if card_holder_name:
            payment_record['card_holder_name'] = card_holder_name
        
        # Insert payment record
        payment_result = db.payments.insert_one(payment_record)
        payment_record_id = str(payment_result.inserted_id)
        
        # Create transaction record in transactions collection
        transaction_record = {
            'transaction_id': payment_record_id,
            'order_id': payment_record_id,
            'user_id': user_id,
            'customer_name': 'Unknown Customer',  # Will be updated when we get user details
            # store transaction amount in paise
            'amount': amount_paise,
            'payment_mode': (payment_method.title() if isinstance(payment_method, str) else payment_method),
            'payment_status': 'Completed',
            'transaction_date': current_datetime,
            'created_at': current_datetime,
            'updated_at': current_datetime,
            'gateway_response': {
                'gateway_name': 'Stripe',
                'gateway_transaction_id': session.id,
                'response_code': '200',
                'response_message': 'Payment session created successfully'
            }
        }
        
        # Get customer name if user exists
        user_details = db.users.find_one({'phone_number': user_id})
        if user_details:
            transaction_record['customer_name'] = user_details.get('name', 'Unknown Customer')
        
        # Insert transaction record
        db.transactions.insert_one(transaction_record)
        
        return jsonify({
            'success': True,
            'session_id': session.id,
            'client_secret': getattr(session, 'client_secret', None),
            'url': session_url,
            'payment_url': session_url,  # Explicit field for frontend
            # Return both canonical paise and rupee-friendly value
            'amount_paise': amount_paise,
            'amount': round(amount_paise / 100.0, 2),
            'currency': 'INR',
            'order_id': order_id
        }), 200
        
    except Exception as e:
        # Check if it's a Stripe-related error
        if 'stripe' in str(e).lower() or hasattr(e, 'user_message'):
            return jsonify({
                'error': f'Stripe error: {str(e)}',
                'success': False
            }), 400
        else:
            return jsonify({
                'error': f'Payment session creation failed: {str(e)}',
                'success': False
            }), 500


@users_bp.route('/users/payment-status/<session_id>', methods=['GET'])
def get_payment_status(session_id):
    """
    Check the status of a payment session
    """
    try:
        # Retrieve the session from Stripe
        session = stripe.checkout.Session.retrieve(session_id)

        # Update local database record
        db = get_db()
        current_datetime = datetime.now()

        # Find payment record by session_id
        payment_record = db.payments.find_one({'session_id': session_id})

        # Determine payment completion state. For UPI (async), the Checkout Session
        # may not have immediate 'paid' state; check associated PaymentIntent when present.
        stripe_payment_status = getattr(session, 'payment_status', None)
        payment_completed = False
        pi_status = None

        # If Checkout session reports payment_status == 'paid', consider completed
        if stripe_payment_status == 'paid':
            payment_completed = True
        else:
            # If there's a payment_intent attached, fetch it and inspect the status
            payment_intent_id = getattr(session, 'payment_intent', None)
            if payment_intent_id:
                try:
                    pi = stripe.PaymentIntent.retrieve(payment_intent_id)
                    pi_status = getattr(pi, 'status', None)
                    if pi_status in ('succeeded', 'requires_capture'):
                        payment_completed = True
                except Exception:
                    # ignore intent retrieval errors here; leave as pending
                    pi_status = None

        if payment_record:
            new_status = 'Completed' if payment_completed else 'Pending'

            # Update payment status in payments collection
            db.payments.update_one(
                {'session_id': session_id},
                {'$set': {
                    'payment_status': new_status,
                    'updated_at': current_datetime,
                    'stripe_payment_status': stripe_payment_status,
                    'stripe_payment_intent_status': pi_status
                }}
            )

            # Update transaction status in transactions collection
            payment_id = str(payment_record['_id'])
            db.transactions.update_one(
                {'$or': [
                    {'transaction_id': payment_id},
                    {'order_id': payment_id}
                ]},
                {'$set': {
                    'payment_status': new_status,
                    'updated_at': current_datetime,
                    'transaction_date': current_datetime if new_status == 'Completed' else payment_record.get('created_at', current_datetime),
                    'gateway_response.response_code': '200' if payment_completed else '102',
                    'gateway_response.response_message': 'Payment successful' if payment_completed else 'Payment pending',
                    'gateway_response.gateway_transaction_id': session.id
                }}
            )

        # Return enriched info so frontend can debug async payments (UPI)
        return jsonify({
            'session_id': session_id,
            'checkout_payment_status': stripe_payment_status,
            'payment_intent_status': pi_status,
            'payment_completed': payment_completed,
            'amount_total': getattr(session, 'amount_total', None),
            'currency': getattr(session, 'currency', None),
            'customer_email': session.customer_details.email if session.customer_details else None,
            'metadata': session.metadata
        }), 200
        
    except Exception as e:
        # Check if it's a Stripe-related error
        if 'stripe' in str(e).lower() or hasattr(e, 'user_message'):
            return jsonify({
                'error': f'Stripe error: {str(e)}',
                'success': False
            }), 400
        else:
            return jsonify({
                'error': f'Failed to retrieve payment status: {str(e)}',
                'success': False
            }), 500








