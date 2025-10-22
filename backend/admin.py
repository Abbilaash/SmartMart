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
                        {'$eq': ['$payment_status', 'Completed']},
                        'Completed',
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
        from datetime import timedelta
        start_date = today - timedelta(days=6)
        start_dt = datetime(start_date.year, start_date.month, start_date.day)
        end_dt = datetime(today.year, today.month, today.day) + timedelta(days=1)

        # Aggregate payments collection by created_at (which may be datetime)
        pipeline = [
            {
                '$addFields': {
                    'paymentDate': {
                        '$cond': [
                            {'$eq': [{'$type': '$created_at'}, 'date']},
                            '$created_at',
                            {'$toDate': '$created_at'}
                        ]
                    }
                }
            },
            {
                '$match': {
                    'paymentDate': {'$gte': start_dt, '$lt': end_dt}
                }
            },
            {
                '$group': {
                    '_id': {'$dateToString': {'format': '%Y-%m-%d', 'date': '$paymentDate'}},
                    'sales': {'$sum': '$amount'}
                }
            }
        ]

        results = list(db.payments.aggregate(pipeline))
        sales_by_date = {r['_id']: r['sales'] for r in results}

        # Prepare 7-day series chronologically
        sales_data = []
        for offset in range(6, -1, -1):
            d = today - timedelta(days=offset)
            key = f"{d.year:04d}-{d.month:02d}-{d.day:02d}"
            # Convert paise to rupees if amounts stored in paise (common case)
            total_paise = sales_by_date.get(key, 0)
            try:
                total_rupees = float(total_paise) if total_paise is not None else 0.0
            except Exception:
                # If already in rupees, just cast
                total_rupees = float(total_paise or 0)

            name = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun'][d.weekday()]
            sales_data.append({'name': name, 'sales': round(total_rupees, 2)})

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
        
        # date_filter may be 'All', a full day like '2025-10-16', or a month like '2025-10'
        if date_filter != 'All':
            # If user passed an exact day (YYYY-MM-DD)
            if isinstance(date_filter, str) and len(date_filter) == 10 and date_filter[4] == '-':
                filter_query['created_at'] = {'$regex': date_filter}
            # If user passed a month (YYYY-MM)
            elif isinstance(date_filter, str) and len(date_filter) == 7 and date_filter[4] == '-':
                filter_query['created_at'] = {'$regex': date_filter}
            else:
                # legacy handling: accept tokens like 'Today' or 'This Month'
                if date_filter == 'Today':
                    today = datetime.now().strftime('%Y-%m-%d')
                    filter_query['created_at'] = {'$regex': today}
                elif date_filter == 'This Month':
                    current_month = datetime.now().strftime('%Y-%m')
                    filter_query['created_at'] = {'$regex': current_month}
        
        # Get transactions (payments) with pagination
        page = int(request.args.get('page', 1))
        limit = int(request.args.get('limit', 50))
        skip = (page - 1) * limit

        payments_cursor = db.payments.find(filter_query).sort('created_at', -1).skip(skip).limit(limit)
        payments = list(payments_cursor)

        transactions = []
        for p in payments:
            # Build the transaction object expected by frontend
            t = {}
            t['_id'] = str(p.get('_id'))
            t['transaction_id'] = p.get('transaction_id') or p.get('txn_id') or ''
            t['order_id'] = p.get('order_id')

            # Resolve customer name from users collection if possible
            user_id = p.get('user_id')
            customer_name = None
            if user_id:
                user = db.users.find_one({'user_id': user_id}, {'name': 1})
                if user:
                    customer_name = user.get('name')
            t['customer_name'] = customer_name or p.get('customer_name') or ''

            # Amount: stored as paise -> convert to rupees float
            amt = p.get('amount', 0)
            try:
                # If amount is stored in smallest currency unit (paise), divide by 100
                t['amount'] = round(float(amt) / 100.0, 2)
            except Exception:
                t['amount'] = amt

            # payment_method in collection -> map to payment_mode expected by frontend
            pm = p.get('payment_method') or p.get('payment_mode') or ''
            if isinstance(pm, str):
                t['payment_mode'] = pm.title()  # 'card' -> 'Card'
            else:
                t['payment_mode'] = pm

            t['payment_status'] = p.get('payment_status')

            # transaction date from created_at
            created_at = p.get('created_at')
            if created_at and hasattr(created_at, 'strftime'):
                t['transaction_date'] = created_at.strftime('%Y-%m-%d')
            else:
                t['transaction_date'] = str(created_at or '')

            transactions.append(t)

        # Get total count for pagination (based on filter applied to payments)
        total_count = db.payments.count_documents(filter_query)

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
        
        # Build match conditions for pipeline (handle status and date filters reliably)
        from datetime import timedelta
        match_conditions = {}

        # Normalize status filter: if provided, map common "completed" labels to actual DB values
        if status_filter != 'All':
            sf = status_filter.lower()
            if sf in ('completed', 'paid', 'success'):
                # match any of the common success labels
                match_conditions['payment_status'] = {'$in': ['success', 'paid', 'Completed', 'Paid', 'completed', 'Success']}
            else:
                match_conditions['payment_status'] = status_filter

        # Date filter: convert tokens or explicit YYYY-MM(-DD) into a date range on payDate
        date_range = {}
        now = datetime.now()
        if date_filter != 'All':
            if date_filter == 'Today':
                start = datetime(now.year, now.month, now.day)
                end = start + timedelta(days=1)
                date_range = {'$gte': start, '$lt': end}
            elif date_filter == 'This Month':
                start = datetime(now.year, now.month, 1)
                # get start of next month
                if now.month == 12:
                    end = datetime(now.year + 1, 1, 1)
                else:
                    end = datetime(now.year, now.month + 1, 1)
                date_range = {'$gte': start, '$lt': end}
            else:
                # YYYY-MM-DD or YYYY-MM
                try:
                    if len(date_filter) == 10:
                        parts = [int(x) for x in date_filter.split('-')]
                        start = datetime(parts[0], parts[1], parts[2])
                        end = start + timedelta(days=1)
                        date_range = {'$gte': start, '$lt': end}
                    elif len(date_filter) == 7:
                        parts = [int(x) for x in date_filter.split('-')]
                        start = datetime(parts[0], parts[1], 1)
                        if parts[1] == 12:
                            end = datetime(parts[0] + 1, 1, 1)
                        else:
                            end = datetime(parts[0], parts[1] + 1, 1)
                        date_range = {'$gte': start, '$lt': end}
                except Exception:
                    date_range = {}

        # Aggregate payments by month for the current year (or filtered range)
        pipeline = [
            {'$addFields': {
                'payDate': {
                    '$cond': [
                        {'$eq': [{'$type': '$created_at'}, 'date']},
                        '$created_at',
                        {'$toDate': '$created_at'}
                    ]
                }
            }},
        ]

        # Build the $match stage
        match_stage = {}
        if match_conditions:
            match_stage.update(match_conditions)

        # If date_range exists, apply it on payDate
        if date_range:
            match_stage['payDate'] = date_range

        # If match_stage has entries, add to pipeline
        if match_stage:
            pipeline.append({'$match': match_stage})

        # Group by year+month
        pipeline.extend([
            {'$group': {
                '_id': {
                    'year': {'$year': '$payDate'},
                    'month': {'$month': '$payDate'}
                },
                'total_revenue': {'$sum': '$amount'},
                'transaction_count': {'$sum': 1}
            }},
            {'$sort': {'_id.month': 1}}
        ])

        monthly_results = list(db.payments.aggregate(pipeline))

        # Convert to frontend format, convert paise to rupees
        revenue_data = []
        month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

        for result in monthly_results:
            month_num = result['_id']['month']
            total_paise = result.get('total_revenue', 0) or 0
            try:
                revenue_rupees = float(total_paise) / 100.0
            except Exception:
                revenue_rupees = float(total_paise)

            revenue_data.append({
                'month': month_names[month_num - 1],
                'revenue': round(revenue_rupees, 2)
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

        # Aggregate payments by week for the current year
        pipeline = [
            {'$addFields': {
                'payDate': {
                    '$cond': [
                        {'$eq': [{'$type': '$created_at'}, 'date']},
                        '$created_at',
                        {'$toDate': '$created_at'}
                    ]
                }
            }},
            {'$match': {
                **filter_query,
                'payment_status': 'Completed',
                'payDate': {
                    '$gte': year_start,
                    '$lt': datetime(current_year + 1, 1, 1)
                }
            }},
            {'$group': {
                '_id': {
                    'year': {'$year': '$payDate'},
                    'week': {'$week': '$payDate'}
                },
                'total_revenue': {'$sum': '$amount'},
                'transaction_count': {'$sum': 1}
            }},
            {'$sort': {'_id.week': 1}},
            {'$limit': 12}  # Get last 12 weeks
        ]

        weekly_results = list(db.payments.aggregate(pipeline))

        # Convert to frontend format (convert paise to rupees)
        revenue_data = []
        for result in weekly_results:
            week_num = result['_id']['week']
            total_paise = result.get('total_revenue', 0) or 0
            try:
                revenue_rupees = float(total_paise) / 100.0
            except Exception:
                revenue_rupees = float(total_paise)

            revenue_data.append({
                'week': f'Week {week_num}',
                'revenue': round(revenue_rupees, 2)
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
        
        # Get filtered payments
        filtered_payments = list(db.payments.find(filter_query))

        # Calculate summary statistics (convert paise to rupees)
        total_paise = sum(p.get('amount', 0) for p in filtered_payments if p.get('payment_status') == 'Completed')
        try:
            total_revenue = float(total_paise) / 100.0
        except Exception:
            total_revenue = float(total_paise or 0)

        total_transactions = len(filtered_payments)
        successful_transactions = len([p for p in filtered_payments if p.get('payment_status') == 'Completed'])
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






