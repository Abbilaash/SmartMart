import React from 'react';
import { HiX } from 'react-icons/hi';

const OrderDetailsModal = ({ isOpen, onClose, order }) => {
  if (!isOpen || !order) return null;

  const formatPrice = (price) => {
    // Price is already in rupees, just format it
    return `₹${price.toLocaleString('en-IN')}`;
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    try {
      const date = new Date(dateString);
      return date.toLocaleString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch {
      return dateString;
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
      <div className="bg-slate-800 rounded-2xl shadow-xl max-w-4xl w-full mx-4 max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-slate-600">
          <div>
            <h2 className="text-2xl font-bold text-white">Order Details</h2>
            <p className="text-gray-400">Order ID: {order._id}</p>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white transition-colors"
          >
            <HiX className="w-6 h-6" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto max-h-[calc(90vh-120px)]">
          {/* Order Information */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div className="bg-slate-700 rounded-lg p-4">
              <h3 className="text-lg font-semibold text-white mb-3">Customer Information</h3>
              <div className="space-y-2">
                <p className="text-gray-300">
                  <span className="font-medium">Name:</span> {order.customer_name || 'N/A'}
                </p>
                <p className="text-gray-300">
                  <span className="font-medium">User ID:</span> {order.user_id || 'N/A'}
                </p>
                <p className="text-gray-300">
                  <span className="font-medium">Order Date:</span> {formatDate(order.order_date)}
                </p>
              </div>
            </div>

            <div className="bg-slate-700 rounded-lg p-4">
              <h3 className="text-lg font-semibold text-white mb-3">Order Summary</h3>
              <div className="space-y-2">
                <p className="text-gray-300">
                  <span className="font-medium">Payment Method:</span> 
                  <span className="ml-2 capitalize">{order.payment_method || 'N/A'}</span>
                </p>
                <p className="text-gray-300">
                  <span className="font-medium">Payment Status:</span>
                  <span className={`ml-2 px-2 py-1 rounded-full text-xs font-medium ${
                    order.payment_status === 'Completed' 
                      ? 'bg-emerald-500 text-white' 
                      : 'bg-amber-500 text-white'
                  }`}>
                    {order.payment_status || 'N/A'}
                  </span>
                </p>
                <p className="text-gray-300">
                  <span className="font-medium">Delivery Status:</span>
                  <span className={`ml-2 px-2 py-1 rounded-full text-xs font-medium ${
                    order.delivery_status === 'Done' || order.delivery_status === 'Delivered'
                      ? 'bg-emerald-500 text-white'
                      : 'bg-blue-500 text-white'
                  }`}>
                    {order.delivery_status || 'N/A'}
                  </span>
                </p>
              </div>
            </div>
          </div>

          {/* Products */}
          <div className="bg-slate-700 rounded-lg p-4">
            <h3 className="text-lg font-semibold text-white mb-4">Products ({order.products?.length || 0})</h3>
            
            {order.products && order.products.length > 0 ? (
              <div className="space-y-4">
                {order.products.map((product, index) => (
                  <div key={index} className="bg-slate-600 rounded-lg p-4">
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      {/* Product Info */}
                      <div>
                        <h4 className="font-semibold text-white text-lg">{product.name}</h4>
                        <p className="text-gray-300 text-sm">Product ID: {product.product_id}</p>
                        <p className="text-gray-300 text-sm">Quantity: {product.quantity}</p>
                      </div>

                      {/* Pricing */}
                      <div className="space-y-2">
                        <div className="flex items-center space-x-2">
                          <span className="text-gray-400 text-sm">Original Price:</span>
                          <span className="text-gray-300 line-through">
                            {formatPrice(product.price)}
                          </span>
                        </div>
                        
                        {product.discount_price && product.discount_price !== product.price && (
                          <>
                            <div className="flex items-center space-x-2">
                              <span className="text-gray-400 text-sm">Discounted Price:</span>
                              <span className="text-emerald-400 font-semibold">
                                {formatPrice(product.discount_price)}
                              </span>
                            </div>
                            <div className="flex items-center space-x-2">
                              <span className="text-gray-400 text-sm">Discount:</span>
                              <span className="text-red-400 font-semibold">
                                {product.discount_percentage}% ({product.discount_name})
                              </span>
                            </div>
                          </>
                        )}
                      </div>

                      {/* Totals */}
                      <div className="space-y-2 text-right">
                        <div className="flex items-center justify-end space-x-2">
                          <span className="text-gray-400 text-sm">Item Total:</span>
                          <span className="text-emerald-400 font-bold text-lg">
                            {formatPrice(product.item_total)}
                          </span>
                        </div>
                        
                        {product.original_total && product.original_total !== product.item_total && (
                          <div className="flex items-center justify-end space-x-2">
                            <span className="text-gray-400 text-sm">Original Total:</span>
                            <span className="text-gray-300 line-through">
                              {formatPrice(product.original_total)}
                            </span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-gray-400 text-center py-8">No products found in this order.</p>
            )}
          </div>

          {/* Order Totals */}
          <div className="bg-slate-700 rounded-lg p-4 mt-6">
            <h3 className="text-lg font-semibold text-white mb-4">Order Totals</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="text-center">
                <p className="text-gray-400 text-sm">Total Amount</p>
                <p className="text-emerald-400 font-bold text-2xl">
                  {formatPrice(order.total_amount)}
                </p>
              </div>
              
              {order.original_total_amount && order.original_total_amount !== order.total_amount && (
                <>
                  <div className="text-center">
                    <p className="text-gray-400 text-sm">Original Amount</p>
                    <p className="text-gray-300 text-xl line-through">
                      {formatPrice(order.original_total_amount)}
                    </p>
                  </div>
                  
                  <div className="text-center">
                    <p className="text-gray-400 text-sm">Total Savings</p>
                    <p className="text-red-400 font-bold text-xl">
                      {formatPrice(order.total_savings)}
                    </p>
                  </div>
                </>
              )}
            </div>
          </div>

          {/* Address Information */}
          {(order.billing_address || order.delivery_address) && (
            <div className="bg-slate-700 rounded-lg p-4 mt-6">
              <h3 className="text-lg font-semibold text-white mb-4">Address Information</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {order.billing_address && (
                  <div>
                    <h4 className="font-medium text-white mb-2">Billing Address</h4>
                    <p className="text-gray-300">{order.billing_address}</p>
                  </div>
                )}
                {order.delivery_address && (
                  <div>
                    <h4 className="font-medium text-white mb-2">Delivery Address</h4>
                    <p className="text-gray-300">{order.delivery_address}</p>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex justify-end p-6 border-t border-slate-600">
          <button
            onClick={onClose}
            className="px-6 py-2 bg-violet-600 text-white rounded-lg hover:bg-violet-700 transition-colors"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

export default OrderDetailsModal;
