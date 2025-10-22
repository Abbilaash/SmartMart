# SmartMart Application - Comprehensive Test Suites

## Table of Contents
1. [Admin Panel Test Suites](#admin-panel-test-suites)
2. [Mobile Application Test Suites](#mobile-application-test-suites)
3. [Backend API Test Suites](#backend-api-test-suites)
4. [Integration Test Suites](#integration-test-suites)

---

## Admin Panel Test Suites

### 1. Admin Login Feature

#### Test Case 1.1: Valid Admin Login
- **Summary**: Verify successful login with valid admin credentials
- **Dependencies**: Admin user exists in database, backend server running
- **Pre-condition**: Admin panel accessible, valid admin credentials available
- **Post-condition**: Admin dashboard loads, session established
- **Execution Steps**:
  1. Navigate to admin login page
  2. Enter valid username: "admin"
  3. Enter valid password: "admin123"
  4. Click "Login" button
- **Expected Output**: Redirect to dashboard, welcome message displayed
- **Actual Output**: [To be filled during testing]

#### Test Case 1.2: Invalid Admin Login - Wrong Password
- **Summary**: Verify login failure with incorrect password
- **Dependencies**: Admin user exists in database
- **Pre-condition**: Admin panel accessible
- **Post-condition**: Login form remains visible, error message shown
- **Execution Steps**:
  1. Navigate to admin login page
  2. Enter valid username: "admin"
  3. Enter invalid password: "wrongpass"
  4. Click "Login" button
- **Expected Output**: Error message "Invalid credentials", stay on login page
- **Actual Output**: [To be filled during testing]

#### Test Case 1.3: Invalid Admin Login - Wrong Username
- **Summary**: Verify login failure with non-existent username
- **Dependencies**: Backend server running
- **Pre-condition**: Admin panel accessible
- **Post-condition**: Login form remains visible, error message shown
- **Execution Steps**:
  1. Navigate to admin login page
  2. Enter invalid username: "fakeadmin"
  3. Enter any password: "password"
  4. Click "Login" button
- **Expected Output**: Error message "Invalid credentials", stay on login page
- **Actual Output**: [To be filled during testing]

#### Test Case 1.4: Empty Fields Login
- **Summary**: Verify validation for empty login fields
- **Dependencies**: Admin panel accessible
- **Pre-condition**: Login form loaded
- **Post-condition**: Form validation prevents submission
- **Execution Steps**:
  1. Navigate to admin login page
  2. Leave username field empty
  3. Leave password field empty
  4. Click "Login" button
- **Expected Output**: Form validation error, fields highlighted
- **Actual Output**: [To be filled during testing]

### 2. Dashboard Loading Feature

#### Test Case 2.1: Dashboard Metrics Loading
- **Summary**: Verify all dashboard metrics load correctly
- **Dependencies**: Admin logged in, backend APIs functional
- **Pre-condition**: Admin successfully logged in
- **Post-condition**: All metrics displayed with correct values
- **Execution Steps**:
  1. Login as admin
  2. Navigate to dashboard
  3. Wait for all metrics to load
  4. Verify weekly sales chart
  5. Verify user count metric
  6. Verify delivered orders count
  7. Verify total sales metric
  8. Verify inventory value metric
- **Expected Output**: All metrics display with data, loading spinners disappear
- **Actual Output**: [To be filled during testing]

#### Test Case 2.2: Dashboard API Error Handling
- **Summary**: Verify dashboard handles API errors gracefully
- **Dependencies**: Admin logged in, backend API down
- **Pre-condition**: Admin successfully logged in
- **Post-condition**: Error messages displayed, dashboard partially functional
- **Execution Steps**:
  1. Login as admin
  2. Stop backend server
  3. Navigate to dashboard
  4. Observe error handling
- **Expected Output**: Error messages for failed API calls, retry options
- **Actual Output**: [To be filled during testing]

#### Test Case 2.3: Dashboard Responsive Design
- **Summary**: Verify dashboard displays correctly on different screen sizes
- **Dependencies**: Admin logged in, responsive CSS implemented
- **Pre-condition**: Admin successfully logged in
- **Post-condition**: Dashboard adapts to screen size
- **Execution Steps**:
  1. Login as admin
  2. Navigate to dashboard
  3. Test on desktop (1920x1080)
  4. Test on tablet (768x1024)
  5. Test on mobile (375x667)
- **Expected Output**: Layout adapts appropriately, metrics remain readable
- **Actual Output**: [To be filled during testing]

#### Test Case 2.4: Dashboard Data Refresh
- **Summary**: Verify dashboard data refreshes when navigating back
- **Dependencies**: Admin logged in, data changes in backend
- **Pre-condition**: Admin on dashboard
- **Post-condition**: Updated data displayed
- **Execution Steps**:
  1. Login as admin
  2. Navigate to dashboard
  3. Note current metrics
  4. Navigate to products page
  5. Add a new product
  6. Navigate back to dashboard
- **Expected Output**: Inventory value updated, other metrics reflect changes
- **Actual Output**: [To be filled during testing]

### 3. Product Management Feature

#### Test Case 3.1: Add New Product
- **Summary**: Verify successful addition of new product
- **Dependencies**: Admin logged in, product form functional
- **Pre-condition**: Admin on products management page
- **Post-condition**: New product appears in product list
- **Execution Steps**:
  1. Navigate to "Manage Products" page
  2. Click "Add Product" button
  3. Fill product form:
     - Name: "Test Product"
     - Price: "100"
     - Barcode: "123456789"
     - Description: "Test description"
     - Stock: "50"
  4. Click "Save" button
- **Expected Output**: Success message, product appears in list
- **Actual Output**: [To be filled during testing]

#### Test Case 3.2: Add Product - Duplicate Barcode
- **Summary**: Verify validation prevents duplicate barcodes
- **Dependencies**: Admin logged in, existing product with same barcode
- **Pre-condition**: Product with barcode "123456789" exists
- **Post-condition**: Error message displayed, product not added
- **Execution Steps**:
  1. Navigate to "Manage Products" page
  2. Click "Add Product" button
  3. Fill product form with existing barcode: "123456789"
  4. Click "Save" button
- **Expected Output**: Error message "Barcode already exists"
- **Actual Output**: [To be filled during testing]

#### Test Case 3.3: Update Existing Product
- **Summary**: Verify successful product update
- **Dependencies**: Admin logged in, existing product
- **Pre-condition**: Product exists in database
- **Post-condition**: Updated product information saved
- **Execution Steps**:
  1. Navigate to "Manage Products" page
  2. Find existing product
  3. Click "Edit" button
  4. Update price from "100" to "150"
  5. Click "Save" button
- **Expected Output**: Success message, updated price displayed
- **Actual Output**: [To be filled during testing]

#### Test Case 3.4: Delete Product
- **Summary**: Verify successful product deletion
- **Dependencies**: Admin logged in, existing product
- **Pre-condition**: Product exists in database
- **Post-condition**: Product removed from list
- **Execution Steps**:
  1. Navigate to "Manage Products" page
  2. Find product to delete
  3. Click "Delete" button
  4. Confirm deletion in dialog
- **Expected Output**: Success message, product removed from list
- **Actual Output**: [To be filled during testing]

### 4. Order Management Feature

#### Test Case 4.1: View Orders List
- **Summary**: Verify orders list displays correctly
- **Dependencies**: Admin logged in, orders exist in database
- **Pre-condition**: Orders exist in system
- **Post-condition**: Orders list displayed with correct information
- **Execution Steps**:
  1. Navigate to "Orders" page
  2. Verify orders list loads
  3. Check order details displayed
  4. Verify pagination if applicable
- **Expected Output**: Orders list with customer info, amounts, status
- **Actual Output**: [To be filled during testing]

#### Test Case 4.2: Mark Order as Delivered
- **Summary**: Verify order status update to delivered
- **Dependencies**: Admin logged in, pending order exists
- **Pre-condition**: Order with "Pending" status exists
- **Post-condition**: Order status updated to "Delivered"
- **Execution Steps**:
  1. Navigate to "Orders" page
  2. Find order with "Pending" status
  3. Click "Mark as Delivered" button
  4. Confirm action
- **Expected Output**: Success message, status updated to "Delivered"
- **Actual Output**: [To be filled during testing]

#### Test Case 4.3: Order Details View
- **Summary**: Verify detailed order information display
- **Dependencies**: Admin logged in, order exists
- **Pre-condition**: Order exists in database
- **Post-condition**: Detailed order information displayed
- **Execution Steps**:
  1. Navigate to "Orders" page
  2. Click on specific order
  3. Verify order details page loads
  4. Check product list, quantities, prices
- **Expected Output**: Complete order details with products and totals
- **Actual Output**: [To be filled during testing]

#### Test Case 4.4: Order Search and Filter
- **Summary**: Verify order search and filtering functionality
- **Dependencies**: Admin logged in, multiple orders exist
- **Pre-condition**: Multiple orders with different statuses
- **Post-condition**: Filtered results displayed
- **Execution Steps**:
  1. Navigate to "Orders" page
  2. Use search field to find specific order
  3. Use status filter to show only "Delivered" orders
  4. Verify filtered results
- **Expected Output**: Only matching orders displayed
- **Actual Output**: [To be filled during testing]

### 5. Discount Management Feature

#### Test Case 5.1: Add New Discount
- **Summary**: Verify successful discount creation
- **Dependencies**: Admin logged in, discount form functional
- **Pre-condition**: Admin on discounts page
- **Post-condition**: New discount appears in discounts list
- **Execution Steps**:
  1. Navigate to "Discounts" page
  2. Click "Add Discount" button
  3. Fill discount form:
     - Name: "Summer Sale"
     - Percentage: "20"
     - Product Barcode: "123456789"
     - Start Date: Current date
     - End Date: Future date
  4. Click "Save" button
- **Expected Output**: Success message, discount appears in list
- **Actual Output**: [To be filled during testing]

#### Test Case 5.2: Update Discount Status
- **Summary**: Verify discount status toggle functionality
- **Dependencies**: Admin logged in, existing discount
- **Pre-condition**: Discount exists with "Active" status
- **Post-condition**: Discount status updated
- **Execution Steps**:
  1. Navigate to "Discounts" page
  2. Find existing discount
  3. Click "Toggle Status" button
  4. Verify status change
- **Expected Output**: Status toggled between Active/Inactive
- **Actual Output**: [To be filled during testing]

#### Test Case 5.3: Edit Discount Details
- **Summary**: Verify discount information update
- **Dependencies**: Admin logged in, existing discount
- **Pre-condition**: Discount exists in database
- **Post-condition**: Updated discount information saved
- **Execution Steps**:
  1. Navigate to "Discounts" page
  2. Find discount to edit
  3. Click "Edit" button
  4. Update percentage from "20" to "30"
  5. Click "Save" button
- **Expected Output**: Success message, updated percentage displayed
- **Actual Output**: [To be filled during testing]

#### Test Case 5.4: Delete Discount
- **Summary**: Verify discount deletion
- **Dependencies**: Admin logged in, existing discount
- **Pre-condition**: Discount exists in database
- **Post-condition**: Discount removed from list
- **Execution Steps**:
  1. Navigate to "Discounts" page
  2. Find discount to delete
  3. Click "Delete" button
  4. Confirm deletion
- **Expected Output**: Success message, discount removed
- **Actual Output**: [To be filled during testing]

---

## Mobile Application Test Suites

### 6. User Authentication Feature

#### Test Case 6.1: User Registration
- **Summary**: Verify successful user registration
- **Dependencies**: Mobile app installed, backend server running
- **Pre-condition**: App launched, registration form accessible
- **Post-condition**: User account created, redirected to login
- **Execution Steps**:
  1. Launch SmartMart mobile app
  2. Navigate to registration screen
  3. Enter phone number: "9876543210"
  4. Enter password: "password123"
  5. Enter name: "Test User"
  6. Tap "Register" button
- **Expected Output**: Success message, redirect to login screen
- **Actual Output**: [To be filled during testing]

#### Test Case 6.2: User Login
- **Summary**: Verify successful user login
- **Dependencies**: User account exists, mobile app functional
- **Pre-condition**: User registered in system
- **Post-condition**: User logged in, main screen displayed
- **Execution Steps**:
  1. Launch SmartMart mobile app
  2. Enter phone number: "9876543210"
  3. Enter password: "password123"
  4. Tap "Login" button
- **Expected Output**: Login successful, main screen with navigation
- **Actual Output**: [To be filled during testing]

#### Test Case 6.3: Invalid Login Credentials
- **Summary**: Verify login failure with wrong credentials
- **Dependencies**: Mobile app functional
- **Pre-condition**: App launched, login form displayed
- **Post-condition**: Error message shown, stay on login screen
- **Execution Steps**:
  1. Launch SmartMart mobile app
  2. Enter phone number: "9876543210"
  3. Enter wrong password: "wrongpass"
  4. Tap "Login" button
- **Expected Output**: Error message "Invalid credentials"
- **Actual Output**: [To be filled during testing]

#### Test Case 6.4: Auto-login Functionality
- **Summary**: Verify automatic login with saved credentials
- **Dependencies**: User previously logged in, credentials saved
- **Pre-condition**: User logged in previously, app closed
- **Post-condition**: User automatically logged in on app launch
- **Execution Steps**:
  1. Close SmartMart app
  2. Reopen SmartMart app
  3. Observe automatic login behavior
- **Expected Output**: User automatically logged in, main screen displayed
- **Actual Output**: [To be filled during testing]

### 7. Barcode Scanning Feature

#### Test Case 7.1: Successful Product Scan
- **Summary**: Verify successful product scanning and addition to cart
- **Dependencies**: User logged in, camera permission granted, product exists
- **Pre-condition**: User on home screen, product with valid barcode available
- **Post-condition**: Product added to cart, product details displayed
- **Execution Steps**:
  1. Login to mobile app
  2. Tap "Scan Product" button
  3. Point camera at product barcode
  4. Wait for scan confirmation
  5. Verify product details displayed
- **Expected Output**: Product scanned successfully, details shown with price
- **Actual Output**: [To be filled during testing]

#### Test Case 7.2: Scan Invalid Barcode
- **Summary**: Verify handling of invalid/unrecognized barcodes
- **Dependencies**: User logged in, camera functional
- **Pre-condition**: User on scan screen
- **Post-condition**: Error message displayed, scan continues
- **Execution Steps**:
  1. Login to mobile app
  2. Tap "Scan Product" button
  3. Point camera at invalid barcode
  4. Wait for scan attempt
- **Expected Output**: Error message "Product not found"
- **Actual Output**: [To be filled during testing]

#### Test Case 7.3: Scan Product with Discount
- **Summary**: Verify scanning product with active discount
- **Dependencies**: User logged in, product with active discount exists
- **Pre-condition**: Product has active discount in database
- **Post-condition**: Product displayed with discounted price
- **Execution Steps**:
  1. Login to mobile app
  2. Scan product with active discount
  3. Verify price display
  4. Check discount information shown
- **Expected Output**: Original price crossed out, discounted price highlighted
- **Actual Output**: [To be filled during testing]

#### Test Case 7.4: Camera Permission Handling
- **Summary**: Verify camera permission request and handling
- **Dependencies**: Mobile app installed, camera available
- **Pre-condition**: App launched, camera permission not granted
- **Post-condition**: Permission requested or error handled gracefully
- **Execution Steps**:
  1. Launch app (first time)
  2. Tap "Scan Product" button
  3. Observe permission request
  4. Grant or deny permission
- **Expected Output**: Permission dialog or appropriate error message
- **Actual Output**: [To be filled during testing]

### 8. Cart Management Feature

#### Test Case 8.1: Add Product to Cart
- **Summary**: Verify product addition to cart
- **Dependencies**: User logged in, product scanned
- **Pre-condition**: Product scanned successfully
- **Post-condition**: Product added to cart, cart count updated
- **Execution Steps**:
  1. Scan a product
  2. Tap "Add to Cart" button
  3. Navigate to cart screen
  4. Verify product in cart
- **Expected Output**: Product appears in cart with correct details
- **Actual Output**: [To be filled during testing]

#### Test Case 8.2: Remove Product from Cart
- **Summary**: Verify product removal from cart
- **Dependencies**: User logged in, product in cart
- **Pre-condition**: Cart contains products
- **Post-condition**: Product removed from cart
- **Execution Steps**:
  1. Navigate to cart screen
  2. Find product to remove
  3. Tap "Remove" button
  4. Confirm removal
- **Expected Output**: Product removed, cart updated
- **Actual Output**: [To be filled during testing]

#### Test Case 8.3: Update Product Quantity
- **Summary**: Verify quantity update in cart
- **Dependencies**: User logged in, product in cart
- **Pre-condition**: Cart contains products
- **Post-condition**: Quantity updated, total recalculated
- **Execution Steps**:
  1. Navigate to cart screen
  2. Find product with quantity controls
  3. Increase quantity using + button
  4. Verify total amount updated
- **Expected Output**: Quantity increased, total amount recalculated
- **Actual Output**: [To be filled during testing]

#### Test Case 8.4: Cart Total Calculation
- **Summary**: Verify accurate cart total calculation
- **Dependencies**: User logged in, multiple products in cart
- **Pre-condition**: Cart contains multiple products with different prices
- **Post-condition**: Total amount calculated correctly
- **Execution Steps**:
  1. Add multiple products to cart
  2. Navigate to cart screen
  3. Verify individual product totals
  4. Verify overall cart total
- **Expected Output**: Total matches sum of individual products
- **Actual Output**: [To be filled during testing]

### 9. Payment Processing Feature

#### Test Case 9.1: UPI Payment Success
- **Summary**: Verify successful UPI payment processing
- **Dependencies**: User logged in, items in cart, Stripe configured
- **Pre-condition**: Cart contains items, billing address provided
- **Post-condition**: Payment successful, order placed
- **Execution Steps**:
  1. Add items to cart
  2. Navigate to checkout
  3. Enter billing address
  4. Select UPI payment method
  5. Complete UPI payment
- **Expected Output**: Payment successful, order confirmation displayed
- **Actual Output**: [To be filled during testing]

#### Test Case 9.2: Card Payment Success
- **Summary**: Verify successful card payment processing
- **Dependencies**: User logged in, items in cart, Stripe configured
- **Pre-condition**: Cart contains items, billing address provided
- **Post-condition**: Payment successful, order placed
- **Execution Steps**:
  1. Add items to cart
  2. Navigate to checkout
  3. Enter billing address
  4. Select Card payment method
  5. Complete card payment via Stripe
- **Expected Output**: Payment successful, order confirmation displayed
- **Actual Output**: [To be filled during testing]

#### Test Case 9.3: Payment Failure Handling
- **Summary**: Verify payment failure handling
- **Dependencies**: User logged in, items in cart
- **Pre-condition**: Cart contains items, invalid payment method
- **Post-condition**: Payment failed, user returned to checkout
- **Execution Steps**:
  1. Add items to cart
  2. Navigate to checkout
  3. Enter billing address
  4. Select payment method
  5. Simulate payment failure
- **Expected Output**: Error message displayed, return to checkout
- **Actual Output**: [To be filled during testing]

#### Test Case 9.4: Payment Session Timeout
- **Summary**: Verify handling of payment session timeout
- **Dependencies**: User logged in, items in cart
- **Pre-condition**: Cart contains items, payment session created
- **Post-condition**: Session timeout handled gracefully
- **Execution Steps**:
  1. Add items to cart
  2. Navigate to checkout
  3. Create payment session
  4. Wait for session timeout
  5. Attempt to complete payment
- **Expected Output**: Timeout error, option to retry payment
- **Actual Output**: [To be filled during testing]

### 10. Order Management Feature

#### Test Case 10.1: View Order History
- **Summary**: Verify order history display
- **Dependencies**: User logged in, orders exist
- **Pre-condition**: User has placed orders previously
- **Post-condition**: Order history displayed correctly
- **Execution Steps**:
  1. Login to mobile app
  2. Navigate to "Purchases" tab
  3. Verify order list displayed
  4. Check order details
- **Expected Output**: Orders listed with dates, amounts, status
- **Actual Output**: [To be filled during testing]

#### Test Case 10.2: View Order Details
- **Summary**: Verify detailed order information display
- **Dependencies**: User logged in, order exists
- **Pre-condition**: Order exists in user's history
- **Post-condition**: Detailed order information displayed
- **Execution Steps**:
  1. Navigate to "Purchases" tab
  2. Tap on specific order
  3. Verify order details page
  4. Check product list and totals
- **Expected Output**: Complete order details with products and payment info
- **Actual Output**: [To be filled during testing]

#### Test Case 10.3: Order Status Updates
- **Summary**: Verify order status reflects current state
- **Dependencies**: User logged in, order exists
- **Pre-condition**: Order exists with specific status
- **Post-condition**: Correct status displayed
- **Execution Steps**:
  1. Navigate to "Purchases" tab
  2. Check order status
  3. Verify status matches backend
  4. Test status updates
- **Expected Output**: Status accurately reflects order state
- **Actual Output**: [To be filled during testing]

#### Test Case 10.4: Order Search and Filter
- **Summary**: Verify order search functionality
- **Dependencies**: User logged in, multiple orders exist
- **Pre-condition**: User has multiple orders
- **Post-condition**: Filtered results displayed
- **Execution Steps**:
  1. Navigate to "Purchases" tab
  2. Use search functionality
  3. Filter by date range
  4. Verify filtered results
- **Expected Output**: Only matching orders displayed
- **Actual Output**: [To be filled during testing]

---

## Backend API Test Suites

### 11. Authentication API Tests

#### Test Case 11.1: User Signup API
- **Summary**: Verify user signup API endpoint
- **Dependencies**: Backend server running, MongoDB connected
- **Pre-condition**: API endpoint accessible
- **Post-condition**: User created in database
- **Execution Steps**:
  1. Send POST request to `/users/signup`
  2. Include JSON body: `{"phone_number": "9876543210", "password": "password123", "name": "Test User"}`
  3. Verify response status 201
  4. Check database for user creation
- **Expected Output**: Status 201, success message, user in database
- **Actual Output**: [To be filled during testing]

#### Test Case 11.2: User Login API
- **Summary**: Verify user login API endpoint
- **Dependencies**: User exists in database
- **Pre-condition**: User registered in system
- **Post-condition**: Login successful, user data returned
- **Execution Steps**:
  1. Send POST request to `/users/login`
  2. Include JSON body: `{"phone_number": "9876543210", "password": "password123"}`
  3. Verify response status 200
  4. Check response contains user data
- **Expected Output**: Status 200, user data returned
- **Actual Output**: [To be filled during testing]

#### Test Case 11.3: Admin Login API
- **Summary**: Verify admin login API endpoint
- **Dependencies**: Admin user exists in database
- **Pre-condition**: Admin credentials available
- **Post-condition**: Admin login successful
- **Execution Steps**:
  1. Send POST request to `/admin/login`
  2. Include JSON body: `{"username": "admin", "password": "admin123"}`
  3. Verify response status 200
  4. Check admin session established
- **Expected Output**: Status 200, admin session created
- **Actual Output**: [To be filled during testing]

#### Test Case 11.4: Invalid Credentials API
- **Summary**: Verify API handles invalid credentials
- **Dependencies**: Backend server running
- **Pre-condition**: API endpoint accessible
- **Post-condition**: Error response returned
- **Execution Steps**:
  1. Send POST request to `/users/login`
  2. Include JSON body: `{"phone_number": "9876543210", "password": "wrongpass"}`
  3. Verify response status 401
  4. Check error message
- **Expected Output**: Status 401, "Invalid credentials" message
- **Actual Output**: [To be filled during testing]

### 12. Product Management API Tests

#### Test Case 12.1: Add Product API
- **Summary**: Verify product addition API endpoint
- **Dependencies**: Admin authenticated, backend running
- **Pre-condition**: Admin logged in, API accessible
- **Post-condition**: Product created in database
- **Execution Steps**:
  1. Send POST request to `/admin/products/add`
  2. Include JSON body with product details
  3. Verify response status 201
  4. Check database for product creation
- **Expected Output**: Status 201, product created successfully
- **Actual Output**: [To be filled during testing]

#### Test Case 12.2: Get Products API
- **Summary**: Verify product retrieval API endpoint
- **Dependencies**: Products exist in database
- **Pre-condition**: Products in database
- **Post-condition**: Product list returned
- **Execution Steps**:
  1. Send GET request to `/admin/products/get`
  2. Verify response status 200
  3. Check response contains product array
  4. Verify product data structure
- **Expected Output**: Status 200, array of products returned
- **Actual Output**: [To be filled during testing]

#### Test Case 12.3: Update Product API
- **Summary**: Verify product update API endpoint
- **Dependencies**: Product exists in database
- **Pre-condition**: Product exists, admin authenticated
- **Post-condition**: Product updated in database
- **Execution Steps**:
  1. Send PUT request to `/admin/products/update`
  2. Include product ID and updated data
  3. Verify response status 200
  4. Check database for updates
- **Expected Output**: Status 200, product updated successfully
- **Actual Output**: [To be filled during testing]

#### Test Case 12.4: Delete Product API
- **Summary**: Verify product deletion API endpoint
- **Dependencies**: Product exists in database
- **Pre-condition**: Product exists, admin authenticated
- **Post-condition**: Product removed from database
- **Execution Steps**:
  1. Send DELETE request to `/admin/products/delete`
  2. Include product ID
  3. Verify response status 200
  4. Check database for deletion
- **Expected Output**: Status 200, product deleted successfully
- **Actual Output**: [To be filled during testing]

### 13. Cart Management API Tests

#### Test Case 13.1: Add Product to Cart API
- **Summary**: Verify cart addition API endpoint
- **Dependencies**: User authenticated, product exists
- **Pre-condition**: User logged in, product available
- **Post-condition**: Product added to user's cart
- **Execution Steps**:
  1. Send POST request to `/users/carts/add_product`
  2. Include user ID and product ID
  3. Verify response status 200
  4. Check cart in database
- **Expected Output**: Status 200, product added to cart
- **Actual Output**: [To be filled during testing]

#### Test Case 13.2: Get Cart Products API
- **Summary**: Verify cart retrieval API endpoint
- **Dependencies**: User authenticated, cart contains products
- **Pre-condition**: User logged in, products in cart
- **Post-condition**: Cart products returned
- **Execution Steps**:
  1. Send POST request to `/users/carts/get_products`
  2. Include user ID
  3. Verify response status 200
  4. Check response contains cart products
- **Expected Output**: Status 200, cart products with details returned
- **Actual Output**: [To be filled during testing]

#### Test Case 13.3: Remove Product from Cart API
- **Summary**: Verify cart removal API endpoint
- **Dependencies**: User authenticated, product in cart
- **Pre-condition**: User logged in, product in cart
- **Post-condition**: Product removed from cart
- **Execution Steps**:
  1. Send POST request to `/users/carts/delete_product`
  2. Include user ID and product ID
  3. Verify response status 200
  4. Check cart in database
- **Expected Output**: Status 200, product removed from cart
- **Actual Output**: [To be filled during testing]

#### Test Case 13.4: Cart with Discounts API
- **Summary**: Verify cart API applies discounts correctly
- **Dependencies**: User authenticated, products with discounts in cart
- **Pre-condition**: Cart contains products with active discounts
- **Post-condition**: Discounted prices returned
- **Execution Steps**:
  1. Add products with discounts to cart
  2. Send GET request to cart API
  3. Verify response includes discounted prices
  4. Check discount calculations
- **Expected Output**: Products returned with applied discounts
- **Actual Output**: [To be filled during testing]

### 14. Payment API Tests

#### Test Case 14.1: Create Payment Session API
- **Summary**: Verify payment session creation API
- **Dependencies**: User authenticated, Stripe configured
- **Pre-condition**: User logged in, items in cart
- **Post-condition**: Stripe session created
- **Execution Steps**:
  1. Send POST request to `/users/create-payment-session`
  2. Include payment details and amount
  3. Verify response status 200
  4. Check Stripe session creation
- **Expected Output**: Status 200, Stripe session URL returned
- **Actual Output**: [To be filled during testing]

#### Test Case 14.2: Payment Status API
- **Summary**: Verify payment status checking API
- **Dependencies**: Payment session exists
- **Pre-condition**: Payment session created
- **Post-condition**: Payment status returned
- **Execution Steps**:
  1. Send GET request to `/users/payment-status/{session_id}`
  2. Verify response status 200
  3. Check payment status in response
  4. Verify status accuracy
- **Expected Output**: Status 200, accurate payment status
- **Actual Output**: [To be filled during testing]

#### Test Case 14.3: Order Placement API
- **Summary**: Verify order placement API
- **Dependencies**: User authenticated, payment completed
- **Pre-condition**: Payment successful, cart contains items
- **Post-condition**: Order created in database
- **Execution Steps**:
  1. Send POST request to `/users/orders/place_order`
  2. Include order details and payment info
  3. Verify response status 200
  4. Check order creation in database
- **Expected Output**: Status 200, order created successfully
- **Actual Output**: [To be filled during testing]

#### Test Case 14.4: Payment Amount Validation API
- **Summary**: Verify payment amount validation
- **Dependencies**: User authenticated, cart total calculated
- **Pre-condition**: Cart contains items with known total
- **Post-condition**: Payment amount matches cart total
- **Execution Steps**:
  1. Calculate cart total
  2. Create payment session with amount
  3. Verify amount matches cart total
  4. Check amount conversion (rupees to paise)
- **Expected Output**: Payment amount accurately reflects cart total
- **Actual Output**: [To be filled during testing]

---

## Integration Test Suites

### 15. End-to-End User Journey Tests

#### Test Case 15.1: Complete Purchase Flow
- **Summary**: Verify complete user purchase journey
- **Dependencies**: All systems functional, test data available
- **Pre-condition**: User registered, products available, discounts active
- **Post-condition**: Order completed successfully
- **Execution Steps**:
  1. User registers/logs in to mobile app
  2. Scans products with barcodes
  3. Adds products to cart
  4. Proceeds to checkout
  5. Enters billing address
  6. Selects payment method
  7. Completes payment
  8. Verifies order confirmation
- **Expected Output**: Complete purchase flow successful, order in admin panel
- **Actual Output**: [To be filled during testing]

#### Test Case 15.2: Admin Product Management Flow
- **Summary**: Verify complete admin product management
- **Dependencies**: Admin panel functional, backend APIs working
- **Pre-condition**: Admin logged in
- **Post-condition**: Product changes reflected in mobile app
- **Execution Steps**:
  1. Admin logs into admin panel
  2. Adds new product with barcode
  3. Creates discount for product
  4. Updates product details
  5. User scans product in mobile app
  6. Verifies discount applied
- **Expected Output**: Product changes immediately available in mobile app
- **Actual Output**: [To be filled during testing]

#### Test Case 15.3: Discount Application Flow
- **Summary**: Verify discount creation and application
- **Dependencies**: Admin panel and mobile app functional
- **Pre-condition**: Product exists, admin can create discounts
- **Post-condition**: Discount applied to scanned product
- **Execution Steps**:
  1. Admin creates discount for specific product
  2. Sets discount as active
  3. User scans product in mobile app
  4. Verifies discounted price displayed
  5. Adds product to cart
  6. Verifies discount in cart total
- **Expected Output**: Discount correctly applied throughout flow
- **Actual Output**: [To be filled during testing]

#### Test Case 15.4: Order Fulfillment Flow
- **Summary**: Verify complete order fulfillment process
- **Dependencies**: All systems functional
- **Pre-condition**: Order placed successfully
- **Post-condition**: Order marked as delivered
- **Execution Steps**:
  1. User places order via mobile app
  2. Order appears in admin panel
  3. Admin views order details
  4. Admin marks order as delivered
  5. User checks order status in mobile app
  6. Verifies status update
- **Expected Output**: Order status synchronized between systems
- **Actual Output**: [To be filled during testing]

### 16. Performance and Load Tests

#### Test Case 16.1: Concurrent User Load
- **Summary**: Verify system performance under concurrent users
- **Dependencies**: Load testing tools, multiple test accounts
- **Pre-condition**: System running normally
- **Post-condition**: System maintains performance
- **Execution Steps**:
  1. Simulate 50 concurrent users logging in
  2. Perform various operations simultaneously
  3. Monitor response times
  4. Check for errors or timeouts
- **Expected Output**: System handles load without degradation
- **Actual Output**: [To be filled during testing]

#### Test Case 16.2: Database Performance
- **Summary**: Verify database performance with large datasets
- **Dependencies**: Database with test data
- **Pre-condition**: Large number of products and orders
- **Post-condition**: Queries execute within acceptable time
- **Execution Steps**:
  1. Create 1000+ products in database
  2. Create 500+ orders
  3. Test product search performance
  4. Test order retrieval performance
  5. Monitor query execution times
- **Expected Output**: Queries complete within 2 seconds
- **Actual Output**: [To be filled during testing]

#### Test Case 16.3: API Response Times
- **Summary**: Verify API response times under normal load
- **Dependencies**: API testing tools
- **Pre-condition**: System running normally
- **Post-condition**: APIs respond within acceptable time
- **Execution Steps**:
  1. Test product API response times
  2. Test cart API response times
  3. Test payment API response times
  4. Test order API response times
  5. Monitor average response times
- **Expected Output**: All APIs respond within 1 second
- **Actual Output**: [To be filled during testing]

#### Test Case 16.4: Mobile App Performance
- **Summary**: Verify mobile app performance
- **Dependencies**: Mobile testing device
- **Pre-condition**: App installed and functional
- **Post-condition**: App performs smoothly
- **Execution Steps**:
  1. Test app startup time
  2. Test screen transition times
  3. Test barcode scanning performance
  4. Test payment processing time
  5. Monitor memory usage
- **Expected Output**: App performs smoothly without lag
- **Actual Output**: [To be filled during testing]

### 17. Security Tests

#### Test Case 17.1: Authentication Security
- **Summary**: Verify authentication security measures
- **Dependencies**: Security testing tools
- **Pre-condition**: System running
- **Post-condition**: Security measures working
- **Execution Steps**:
  1. Test password hashing
  2. Test session management
  3. Test brute force protection
  4. Test token expiration
- **Expected Output**: Security measures prevent unauthorized access
- **Actual Output**: [To be filled during testing]

#### Test Case 17.2: API Security
- **Summary**: Verify API security measures
- **Dependencies**: API security testing tools
- **Pre-condition**: APIs accessible
- **Post-condition**: APIs protected against common attacks
- **Execution Steps**:
  1. Test SQL injection protection
  2. Test XSS protection
  3. Test CSRF protection
  4. Test input validation
- **Expected Output**: APIs protected against security vulnerabilities
- **Actual Output**: [To be filled during testing]

#### Test Case 17.3: Payment Security
- **Summary**: Verify payment processing security
- **Dependencies**: Payment testing environment
- **Pre-condition**: Payment system configured
- **Post-condition**: Payment data secure
- **Execution Steps**:
  1. Test payment data encryption
  2. Test PCI compliance
  3. Test payment tokenization
  4. Test fraud detection
- **Expected Output**: Payment data handled securely
- **Actual Output**: [To be filled during testing]

#### Test Case 17.4: Data Privacy
- **Summary**: Verify user data privacy protection
- **Dependencies**: Privacy testing tools
- **Pre-condition**: User data in system
- **Post-condition**: Data privacy maintained
- **Execution Steps**:
  1. Test data encryption at rest
  2. Test data encryption in transit
  3. Test data access controls
  4. Test data retention policies
- **Expected Output**: User data protected according to privacy standards
- **Actual Output**: [To be filled during testing]

---

## Test Execution Guidelines

### Test Environment Setup
1. **Backend Server**: Ensure Flask server running on localhost:5000
2. **Database**: MongoDB running with test database
3. **Mobile App**: Flutter app built and installed on test device
4. **Admin Panel**: React app running on localhost:3000
5. **Stripe**: Test environment configured with test keys

### Test Data Requirements
- Test admin user: username="admin", password="admin123"
- Test products with various barcodes
- Test discounts with different percentages
- Test user accounts for mobile app testing
- Test payment methods (test cards, UPI test accounts)

### Test Execution Schedule
1. **Unit Tests**: Run before each feature development
2. **Integration Tests**: Run after feature completion
3. **End-to-End Tests**: Run before release
4. **Performance Tests**: Run weekly
5. **Security Tests**: Run monthly

### Test Reporting
- Document actual outputs for each test case
- Track test pass/fail rates
- Maintain test execution logs
- Update test cases based on findings

### Test Maintenance
- Update test cases when features change
- Add new test cases for new features
- Remove obsolete test cases
- Review and improve test coverage regularly

---

*This comprehensive test suite covers all major features of the SmartMart application. Each test case includes detailed execution steps and expected outcomes to ensure thorough testing of the system.*
