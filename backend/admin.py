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
        'name', 'barcode', 'description', 'price',
        'stck_qty', 'image_url', 'is_active', 'created_at'
    ]
    if not data or not all(field in data for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400
    db = get_db()
    # Use barcode as product_id as per requirement
    product_id = data.get('barcode')
    if not product_id:
        return jsonify({'message': 'Barcode is required'}), 400
    # Duplicate checks
    if db.products.find_one({'product_id': product_id}):
        return jsonify({'message': 'Product ID already exists'}), 400
    if db.products.find_one({'barcode': data['barcode']}):
        return jsonify({'message': 'Barcode already exists'}), 400
    # Insert product
    db.products.insert_one({
        'product_id': product_id,
        'name': data['name'],
        'barcode': data['barcode'],
        'description': data['description'],
        'price': float(data['price']),
        'discount_id': data.get('discount_id', ''),
        'stck_qty': int(data['stck_qty']),
        'image_url': data['image_url'],
        'is_active': bool(data['is_active']),
        'created_at': data['created_at']
    })
    return jsonify({'message': 'Product added successfully'}), 201

@admin_bp.route('/admin/product/delete_product', methods=['DELETE'])
def delete_product():
    data = request.get_json(silent=True) or {}
    product_id = data.get('product_id') or data.get('barcode')
    if not product_id:
        return jsonify({'message': 'Missing product_id'}), 400
    db = get_db()
    result = db.products.delete_one({'product_id': product_id})
    if result.deleted_count == 0:
        return jsonify({'message': 'Product not found'}), 404
    return jsonify({'message': 'Product deleted successfully'}), 200

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
        # Compute last 7 days range [start_of_day 6 days ago, start_of_tomorrow)
        today = datetime.now().date()
        start_date = today.fromordinal(today.toordinal() - 6)
        start_dt = datetime(start_date.year, start_date.month, start_date.day)
        end_dt = datetime(today.year, today.month, today.day)  # start of today
        # end is start of tomorrow
        from datetime import timedelta
        end_dt = end_dt + timedelta(days=1)

        # Build aggregation to coerce 'date' (which may be string) to date and filter last 7 days
        pipeline = [
            {
                '$addFields': {
                    'orderDate': {
                        '$cond': [
                            {'$eq': [{'$type': '$date'}, 'date']},
                            '$date',
                            {'$toDate': '$date'}
                        ]
                    }
                }
            },
            {
                '$match': {
                    'orderDate': {'$gte': start_dt, '$lt': end_dt}
                }
            },
            {
                '$group': {
                    '_id': {'$dateToString': {'format': '%Y-%m-%d', 'date': '$orderDate'}},
                    'sales': {'$sum': '$total_amount'}
                }
            }
        ]

        results = list(db.orders.aggregate(pipeline))
        sales_by_date = {r['_id']: r['sales'] for r in results}

        # Prepare 7-day series chronologically
        day_names = ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat']
        sales_data = []
        for offset in range(6, -1, -1):
            d = today.fromordinal(today.toordinal() - offset)
            key = f"{d.year:04d}-{d.month:02d}-{d.day:02d}"
            name = day_names[d.weekday()] if hasattr(d, 'weekday') else ''
            # Python's weekday(): Mon=0..Sun=6; adjust to our labels
            # Convert: Mon(0)->'Mon', ... Sun(6)->'Sun'
            name = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun'][d.weekday()]
            sales_data.append({'name': name, 'sales': float(sales_by_date.get(key, 0))})

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

# Discount Management APIs
@admin_bp.route('/admin/discounts/get_discounts', methods=['GET'])
def get_discounts():
    db = get_db()
    try:
        discounts = list(db.discounts.find({}))
        for discount in discounts:
            discount['_id'] = str(discount['_id'])
            # Convert dates to string for JSON serialization
            if 'start_date' in discount:
                discount['start_date'] = discount['start_date'].strftime('%Y-%m-%d')
            if 'end_date' in discount:
                discount['end_date'] = discount['end_date'].strftime('%Y-%m-%d')
        return jsonify({'discounts': discounts}), 200
    except Exception as e:
        return jsonify({'message': f'Error fetching discounts: {str(e)}'}), 500

@admin_bp.route('/admin/discounts/add_discount', methods=['POST'])
def add_discount():
    data = request.get_json()
    required_fields = ['name', 'percentage', 'start_date', 'end_date', 'product_barcode']
    if not data or not all(field in data for field in required_fields):
        return jsonify({'message': 'Missing required fields'}), 400
    
    db = get_db()
    
    # Check if product exists
    product = db.products.find_one({'barcode': data['product_barcode']})
    if not product:
        return jsonify({'message': 'Product not found with this barcode'}), 404
    
    # Check if discount already exists for this product
    existing_discount = db.discounts.find_one({'product_barcode': data['product_barcode'], 'status': 'Active'})
    if existing_discount:
        return jsonify({'message': 'Product already has an active discount'}), 400
    
    # Create discount
    discount_data = {
        'name': data['name'],
        'percentage': int(data['percentage']),
        'start_date': datetime.strptime(data['start_date'], '%Y-%m-%d'),
        'end_date': datetime.strptime(data['end_date'], '%Y-%m-%d'),
        'product_barcode': data['product_barcode'],
        'product_name': product['name'],
        'status': 'Active',
        'created_at': datetime.now()
    }
    
    result = db.discounts.insert_one(discount_data)
    
    # Update product with discount_id
    db.products.update_one(
        {'barcode': data['product_barcode']},
        {'$set': {'discount_id': str(result.inserted_id)}}
    )
    
    return jsonify({'message': 'Discount added successfully', 'discount_id': str(result.inserted_id)}), 201

@admin_bp.route('/admin/discounts/update_discount', methods=['PUT'])
def update_discount():
    data = request.get_json()
    if not data or 'discount_id' not in data:
        return jsonify({'message': 'Missing discount_id'}), 400
    
    db = get_db()
    
    try:
        discount_id = ObjectId(data['discount_id'])
    except Exception:
        return jsonify({'message': 'Invalid discount_id'}), 400
    
    # Prepare update fields
    update_fields = {}
    if 'name' in data:
        update_fields['name'] = data['name']
    if 'percentage' in data:
        update_fields['percentage'] = int(data['percentage'])
    if 'start_date' in data:
        update_fields['start_date'] = datetime.strptime(data['start_date'], '%Y-%m-%d')
    if 'end_date' in data:
        update_fields['end_date'] = datetime.strptime(data['end_date'], '%Y-%m-%d')
    if 'status' in data:
        update_fields['status'] = data['status']
    
    if not update_fields:
        return jsonify({'message': 'No fields to update'}), 400
    
    result = db.discounts.update_one(
        {'_id': discount_id},
        {'$set': update_fields}
    )
    
    if result.matched_count == 0:
        return jsonify({'message': 'Discount not found'}), 404
    
    return jsonify({'message': 'Discount updated successfully'}), 200

@admin_bp.route('/admin/discounts/delete_discount', methods=['DELETE'])
def delete_discount():
    data = request.get_json()
    if not data or 'discount_id' not in data:
        return jsonify({'message': 'Missing discount_id'}), 400
    
    db = get_db()
    
    try:
        discount_id = ObjectId(data['discount_id'])
    except Exception:
        return jsonify({'message': 'Invalid discount_id'}), 400
    
    # Get discount details before deletion
    discount = db.discounts.find_one({'_id': discount_id})
    if not discount:
        return jsonify({'message': 'Discount not found'}), 404
    
    # Remove discount_id from product
    if 'product_barcode' in discount:
        db.products.update_one(
            {'barcode': discount['product_barcode']},
            {'$unset': {'discount_id': ''}}
        )
    
    # Delete discount
    result = db.discounts.delete_one({'_id': discount_id})
    
    if result.deleted_count == 0:
        return jsonify({'message': 'Discount not found'}), 404
    
    return jsonify({'message': 'Discount deleted successfully'}), 200

@admin_bp.route('/admin/discounts/toggle_status', methods=['PUT'])
def toggle_discount_status():
    data = request.get_json()
    if not data or 'discount_id' not in data:
        return jsonify({'message': 'Missing discount_id'}), 400
    
    db = get_db()
    
    try:
        discount_id = ObjectId(data['discount_id'])
    except Exception:
        return jsonify({'message': 'Invalid discount_id'}), 400
    
    # Get current discount
    discount = db.discounts.find_one({'_id': discount_id})
    if not discount:
        return jsonify({'message': 'Discount not found'}), 404
    
    # Toggle status
    new_status = 'Inactive' if discount['status'] == 'Active' else 'Active'
    
    result = db.discounts.update_one(
        {'_id': discount_id},
        {'$set': {'status': new_status}}
    )
    
    if result.matched_count == 0:
        return jsonify({'message': 'Discount not found'}), 404
    
    return jsonify({'message': f'Discount status changed to {new_status}'}), 200

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






