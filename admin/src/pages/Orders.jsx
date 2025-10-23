import React, { useState, useEffect } from 'react';
import { HiChevronDown, HiChevronUp, HiFilter, HiEye } from 'react-icons/hi';
import OrderDetailsModal from '../components/OrderDetailsModal';

const API_URL = 'http://localhost:5000/admin/order';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [paymentStatusFilter, setPaymentStatusFilter] = useState('All');
  const [amountFilter, setAmountFilter] = useState('All');
  const [amountValue, setAmountValue] = useState('');
  const [expandedOrders, setExpandedOrders] = useState([]);
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchOrders();
  }, [paymentStatusFilter, amountFilter, amountValue]);

  const fetchOrders = async () => {
    try {
      // Build query parameters
      const params = new URLSearchParams();
      if (paymentStatusFilter !== 'All') {
        params.append('payment_status', paymentStatusFilter);
      }
      if (amountFilter !== 'All' && amountValue) {
        params.append('amount_filter', amountFilter);
        params.append('amount_value', amountValue);
      }

      const url = `${API_URL}/get_orders${params.toString() ? '?' + params.toString() : ''}`;
      const res = await fetch(url);
      const data = await res.json();
      // Display newest orders first: reverse the received list
      const list = data.orders || [];
      setOrders(Array.isArray(list) ? list.slice().reverse() : []);
    } catch (err) {
      setOrders([]);
    }
  };

  const getPaymentStatusColor = (status) => {
    switch (status) {
      case 'Completed': return 'bg-emerald-500 text-white';
      case 'Unpaid': return 'bg-amber-500 text-white';
      default: return 'bg-gray-500 text-white';
    }
  };

  const getDeliveryStatusColor = (status) => {
    switch (status) {
      case 'Done': return 'bg-emerald-500 text-white';
      case 'Delivered': return 'bg-emerald-500 text-white';
      case 'Pending': return 'bg-blue-500 text-white';
      case 'Cancelled': return 'bg-red-500 text-white';
      default: return 'bg-gray-500 text-white';
    }
  };

  const getDeliveryStatusText = (status) => {
    switch (status) {
      case 'Done': return 'Done';
      case 'Delivered': return 'Delivered';
      case 'Pending': return 'Pending';
      case 'Cancelled': return 'Cancelled';
      default: return status || 'Unknown';
    }
  };

  const toggleOrderExpansion = (orderId) => {
    setExpandedOrders((prev) =>
      prev.includes(orderId)
        ? prev.filter((id) => id !== orderId)
        : [...prev, orderId]
    );
  };

  const markAsDelivered = async (orderId) => {
    try {
      await fetch(`${API_URL}/mark_delivered`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ order_id: orderId })
      });
      fetchOrders();
    } catch (err) {
      // handle error
    }
  };

  const viewOrderDetails = async (orderId) => {
    setLoading(true);
    try {
      const response = await fetch(`${API_URL}/get_order_details`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ order_id: orderId })
      });
      
      if (response.ok) {
        const data = await response.json();
        setSelectedOrder(data.order);
        setIsModalOpen(true);
      } else {
        console.error('Failed to fetch order details');
      }
    } catch (err) {
      console.error('Error fetching order details:', err);
    } finally {
      setLoading(false);
    }
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setSelectedOrder(null);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white mb-2">Orders Management</h1>
          <p className="text-gray-400">Track and manage customer orders.</p>
        </div>
        <div className="mt-4 sm:mt-0 flex flex-col sm:flex-row items-start sm:items-center space-y-4 sm:space-y-0 sm:space-x-4">
          {/* Payment Status Filter */}
          <div className="relative">
            <HiFilter className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <select
              value={paymentStatusFilter}
              onChange={(e) => setPaymentStatusFilter(e.target.value)}
              className="pl-10 pr-8 py-2 bg-slate-800 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
            >
              <option value="All">All Payment Status</option>
              <option value="Completed">Completed</option>
              <option value="Unpaid">Unpaid</option>
            </select>
          </div>

          {/* Amount Filter */}
          <div className="flex items-center space-x-2">
            <select
              value={amountFilter}
              onChange={(e) => setAmountFilter(e.target.value)}
              className="px-3 py-2 bg-slate-800 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
            >
              <option value="All">All Amounts</option>
              <option value="above">Above</option>
              <option value="below">Below</option>
            </select>
            
            {amountFilter !== 'All' && (
              <input
                type="number"
                value={amountValue}
                onChange={(e) => setAmountValue(e.target.value)}
                placeholder="Amount"
                className="px-3 py-2 bg-slate-800 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none w-24"
              />
            )}
          </div>
        </div>
      </div>
      {/* Orders Table */}
      <div className="bg-slate-800 rounded-2xl shadow-md overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-slate-700">
              <tr>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Order ID</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Customer</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Payment Status</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Delivery Status</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Date</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Total</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order) => (
                <React.Fragment key={order.order_id}>
                  <tr className="border-b border-slate-600 hover:bg-slate-700 transition-colors">
                    <td className="py-4 px-6">
                      <div className="flex items-center space-x-2">
                        <span className="text-white font-medium">
                          {order.order_id.length > 10 
                            ? '...' + order.order_id.slice(-10) 
                            : order.order_id}
                        </span>
                      </div>
                    </td>
                    <td className="py-4 px-6 text-white">{order.customer_name || order.customer || 'Unknown'}</td>
                    <td className="py-4 px-6">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getPaymentStatusColor(order.payment_status)}`}>
                        {order.payment_status}
                      </span>
                    </td>
                    <td className="py-4 px-6">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getDeliveryStatusColor(order.delivery_status)}`}>
                        {getDeliveryStatusText(order.delivery_status)}
                      </span>
                    </td>
                    <td className="py-4 px-6 text-gray-300">{order.order_date_string || order.date || 'N/A'}</td>
                    <td className="py-4 px-6 text-emerald-400 font-bold">₹{order.total_amount || order.total}</td>
                    <td className="py-4 px-6">
                      <div className="flex items-center space-x-2">
                        <button
                          onClick={() => viewOrderDetails(order.order_id)}
                          disabled={loading}
                          className="bg-blue-600 text-white px-3 py-1 rounded-lg text-sm hover:bg-blue-700 transition-colors flex items-center space-x-1 disabled:opacity-50"
                        >
                          <HiEye className="w-4 h-4" />
                          <span>View</span>
                        </button>
                        
                        {order.delivery_status !== 'Done' && order.delivery_status !== 'Delivered' && (
                          <button
                            onClick={() => markAsDelivered(order.order_id)}
                            className="bg-emerald-600 text-white px-3 py-1 rounded-lg text-sm hover:bg-emerald-700 transition-colors"
                          >
                            Mark as Delivered
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                  {/* You can add expanded order details here if needed */}
                </React.Fragment>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Order Details Modal */}
      <OrderDetailsModal
        isOpen={isModalOpen}
        onClose={closeModal}
        order={selectedOrder}
      />
    </div>
  );
};

export default Orders;