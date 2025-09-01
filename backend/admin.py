from flask import Blueprint, request, jsonify
from db import get_db
from werkzeug.security import check_password_hash
from datetime import datetime
from bson import ObjectId

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

@admin_bp.route('/admin/order/get_orders', methods=['GET'])
def get_orders():
    db = get_db()
    pipeline = [
        {
            '$lookup': {
                'from': 'users',
                'localField': 'user_id',
                'foreignField': 'user_id',
                'as': 'user_info'
            }
        },
        {
            '$unwind': {
                'path': '$user_info',
                'preserveNullAndEmptyArrays': True
            }
        },
        {
            '$project': {
                '_id': 1,  # Keep _id for ObjectId
                'customer': '$user_info.name',
                'payment_status': {
                    '$cond': [
                        {'$eq': ['$payment_status', 'success']},
                        'Paid',
                        {'$cond': [{'$eq': ['$payment_status', 'failed']}, 'Failed', 'Unpaid']}
                    ]
                },
                'delivery_status': 1,
                'date': {'$ifNull': ['$date', '']},
                'total': '$total_amount'
            }
        }
    ]
    orders = list(db.orders.aggregate(pipeline))
    # Convert _id to string and assign to order_id
    for order in orders:
        order['order_id'] = str(order['_id'])
        del order['_id']
    return jsonify({'orders': orders}), 200

@admin_bp.route('/admin/order/mark_delivered', methods=['PUT'])
def mark_order_delivered():
    db = get_db()
    data = request.get_json()
    order_id = data.get('order_id')
    if not order_id:
        return jsonify({'message': 'Missing order_id'}), 400
    try:
        obj_id = ObjectId(order_id)
    except Exception:
        return jsonify({'message': 'Invalid order_id'}), 400
    result = db.orders.update_one({'_id': obj_id}, {'$set': {'delivery_status': 'Delivered'}})
    if result.matched_count == 0:
        return jsonify({'message': 'Order not found'}), 404
    return jsonify({'message': 'Order marked as delivered'}), 200

@admin_bp.route('/admin/dashboard/weekly_sales', methods=['GET'])
def get_weekly_sales():
    db = get_db()
    try:
        # Get the weekly sales data from the database
        weekly_sales = db.weekly_sales.find_one({})
        if not weekly_sales:
            return jsonify({'message': 'Weekly sales data not found'}), 404
        
        # Convert the data to the format expected by the frontend
        sales_data = [
            {'name': 'Sun', 'sales': weekly_sales.get('Sun', 0)},
            {'name': 'Mon', 'sales': weekly_sales.get('Mon', 0)},
            {'name': 'Tues', 'sales': weekly_sales.get('Tues', 0)},
            {'name': 'Wed', 'sales': weekly_sales.get('Wed', 0)},
            {'name': 'Thurs', 'sales': weekly_sales.get('Thurs', 0)},
            {'name': 'Fri', 'sales': weekly_sales.get('Fri', 0)},
            {'name': 'Sat', 'sales': weekly_sales.get('Sat', 0)}
        ]
        
        return jsonify({'sales_data': sales_data}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching weekly sales: {str(e)}'}), 500

@admin_bp.route('/admin/dashboard/user_count', methods=['GET'])
def get_user_count():
    db = get_db()
    try:
        count = db.users.count_documents({'role': 'users'})
        return jsonify({'user_count': count}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching user count: {str(e)}'}), 500

@admin_bp.route('/admin/dashboard/delivered_orders_count', methods=['GET'])
def get_delivered_orders_count():
    db = get_db()
    try:
        count = db.orders.count_documents({'delivery_status': 'Not Delivered'})
        return jsonify({'delivered_orders_count': count}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching delivered orders count: {str(e)}'}), 500

@admin_bp.route('/admin/dashboard/total_sales', methods=['GET'])
def get_total_sales():
    db = get_db()
    try:
        pipeline = [
            {'$group': {'_id': None, 'total': {'$sum': '$total_amount'}}}
        ]
        result = list(db.orders.aggregate(pipeline))
        total_sales = result[0]['total'] if result else 0
        return jsonify({'total_sales': total_sales}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching total sales: {str(e)}'}), 500

@admin_bp.route('/admin/dashboard/inventory_value', methods=['GET'])
def get_inventory_value():
    db = get_db()
    try:
        pipeline = [
            {'$project': {'value': {'$multiply': ['$price', '$stck_qty']}}},
            {'$group': {'_id': None, 'total_inventory_value': {'$sum': '$value'}}}
        ]
        result = list(db.products.aggregate(pipeline))
        total_inventory_value = result[0]['total_inventory_value'] if result else 0
        return jsonify({'total_inventory_value': total_inventory_value}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching inventory value: {str(e)}'}), 500

# Payments API Endpoints
@admin_bp.route('/admin/payments/transactions', methods=['GET'])
def get_transactions():
    db = get_db()
    try:
        # Get query parameters for filtering
        status_filter = request.args.get('status', 'All')
        date_filter = request.args.get('date', 'All')
        
        # Build filter query
        filter_query = {}
        
        if status_filter != 'All':
            filter_query['payment_status'] = status_filter
        
        if date_filter != 'All':
            if date_filter == 'Today':
                today = datetime.now().strftime('%Y-%m-%d')
                filter_query['transaction_date'] = {'$regex': today}
            elif date_filter == 'This Month':
                current_month = datetime.now().strftime('%Y-%m')
                filter_query['transaction_date'] = {'$regex': current_month}
        
        # Get transactions with pagination
        page = int(request.args.get('page', 1))
        limit = int(request.args.get('limit', 50))
        skip = (page - 1) * limit
        
        transactions = list(db.transactions.find(filter_query).sort('transaction_date', -1).skip(skip).limit(limit))
        
        # Convert ObjectId to string for JSON serialization
        for transaction in transactions:
            transaction['_id'] = str(transaction['_id'])
            # Convert datetime to string for frontend
            if 'transaction_date' in transaction:
                transaction['transaction_date'] = transaction['transaction_date'].strftime('%Y-%m-%d')
            if 'created_at' in transaction:
                transaction['created_at'] = transaction['created_at'].strftime('%Y-%m-%d')
            if 'updated_at' in transaction:
                transaction['updated_at'] = transaction['updated_at'].strftime('%Y-%m-%d')
        
        # Get total count for pagination
        total_count = db.transactions.count_documents(filter_query)
        
        return jsonify({
            'transactions': transactions,
            'total_count': total_count,
            'page': page,
            'limit': limit,
            'total_pages': (total_count + limit - 1) // limit
        }), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching transactions: {str(e)}'}), 500

@admin_bp.route('/admin/payments/monthly_revenue', methods=['GET'])
def get_monthly_revenue():
    db = get_db()
    try:
        # Get query parameters for filtering
        status_filter = request.args.get('status', 'All')
        date_filter = request.args.get('date', 'All')
        
        # Build filter query
        filter_query = {}
        
        if status_filter != 'All':
            filter_query['payment_status'] = status_filter
        
        if date_filter != 'All':
            if date_filter == 'Today':
                today = datetime.now().strftime('%Y-%m-%d')
                filter_query['transaction_date'] = {'$regex': today}
            elif date_filter == 'This Month':
                current_month = datetime.now().strftime('%Y-%m')
                filter_query['transaction_date'] = {'$regex': current_month}
        
        # Aggregate transactions by month for the current year
        current_year = datetime.now().year
        pipeline = [
            {'$match': {
                **filter_query,
                'payment_status': 'Completed',  # Only count completed transactions
                'transaction_date': {
                    '$gte': datetime(current_year, 1, 1),
                    '$lt': datetime(current_year + 1, 1, 1)
                }
            }},
            {'$group': {
                '_id': {
                    'year': {'$year': '$transaction_date'},
                    'month': {'$month': '$transaction_date'}
                },
                'total_revenue': {'$sum': '$amount'},
                'transaction_count': {'$sum': 1}
            }},
            {'$sort': {'_id.month': 1}}
        ]
        
        monthly_results = list(db.transactions.aggregate(pipeline))
        
        # Convert to frontend format
        revenue_data = []
        month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        
        for result in monthly_results:
            month_num = result['_id']['month']
            revenue_data.append({
                'month': month_names[month_num - 1],
                'revenue': result['total_revenue']
            })
        
        return jsonify({'monthly_revenue': revenue_data}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching monthly revenue: {str(e)}'}), 500

@admin_bp.route('/admin/payments/weekly_revenue', methods=['GET'])
def get_weekly_revenue():
    db = get_db()
    try:
        # Get query parameters for filtering
        status_filter = request.args.get('status', 'All')
        date_filter = request.args.get('date', 'All')
        
        # Build filter query
        filter_query = {}
        
        if status_filter != 'All':
            filter_query['payment_status'] = status_filter
        
        if date_filter != 'All':
            if date_filter == 'Today':
                today = datetime.now().strftime('%Y-%m-%d')
                filter_query['transaction_date'] = {'$regex': today}
            elif date_filter == 'This Month':
                current_month = datetime.now().strftime('%Y-%m')
                filter_query['transaction_date'] = {'$regex': current_month}
        
        # Calculate the start of the current year
        current_year = datetime.now().year
        year_start = datetime(current_year, 1, 1)
        
        # Aggregate transactions by week for the current year
        pipeline = [
            {'$match': {
                **filter_query,
                'payment_status': 'Completed',  # Only count completed transactions
                'transaction_date': {
                    '$gte': year_start,
                    '$lt': datetime(current_year + 1, 1, 1)
                }
            }},
            {'$group': {
                '_id': {
                    'year': {'$year': '$transaction_date'},
                    'week': {'$week': '$transaction_date'}
                },
                'total_revenue': {'$sum': '$amount'},
                'transaction_count': {'$sum': 1}
            }},
            {'$sort': {'_id.week': 1}},
            {'$limit': 12}  # Get last 12 weeks
        ]
        
        weekly_results = list(db.transactions.aggregate(pipeline))
        
        # Convert to frontend format
        revenue_data = []
        for result in weekly_results:
            week_num = result['_id']['week']
            revenue_data.append({
                'week': f'Week {week_num}',
                'revenue': result['total_revenue']
            })
        
        return jsonify({'weekly_revenue': revenue_data}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching weekly revenue: {str(e)}'}), 500

@admin_bp.route('/admin/payments/summary', methods=['GET'])
def get_payments_summary():
    db = get_db()
    try:
        # Get query parameters for filtering
        status_filter = request.args.get('status', 'All')
        date_filter = request.args.get('date', 'All')
        
        # Build filter query
        filter_query = {}
        
        if status_filter != 'All':
            filter_query['payment_status'] = status_filter
        
        if date_filter != 'All':
            if date_filter == 'Today':
                today = datetime.now().strftime('%Y-%m-%d')
                filter_query['transaction_date'] = {'$regex': today}
            elif date_filter == 'This Month':
                current_month = datetime.now().strftime('%Y-%m')
                filter_query['transaction_date'] = {'$regex': current_month}
        
        # Get filtered transactions
        filtered_transactions = list(db.transactions.find(filter_query))
        
        # Calculate summary statistics
        total_revenue = sum(t['amount'] for t in filtered_transactions if t['payment_status'] == 'Completed')
        total_transactions = len(filtered_transactions)
        successful_transactions = len([t for t in filtered_transactions if t['payment_status'] == 'Completed'])
        success_rate = (successful_transactions / total_transactions * 100) if total_transactions > 0 else 0
        
        summary = {
            'total_revenue': round(total_revenue, 2),
            'total_transactions': total_transactions,
            'successful_transactions': successful_transactions,
            'success_rate': round(success_rate, 1)
        }
        
        return jsonify(summary), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching payments summary: {str(e)}'}), 500






