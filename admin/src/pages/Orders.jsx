import React, { useState, useEffect } from 'react';
import { HiChevronDown, HiChevronUp, HiFilter } from 'react-icons/hi';

const API_URL = 'http://localhost:5000/admin/order';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [filterStatus, setFilterStatus] = useState('All');
  const [expandedOrders, setExpandedOrders] = useState([]);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const res = await fetch(`${API_URL}/get_orders`);
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
      case 'Failed': return 'bg-red-500 text-white';
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

  const filteredOrders = filterStatus === 'All'
    ? orders
    : orders.filter(order => {
        if (filterStatus === 'Done') {
          return order.delivery_status === 'Done';
        } else if (filterStatus === 'Delivered') {
          return order.delivery_status === 'Delivered';
        } else if (filterStatus === 'Pending') {
          return order.delivery_status === 'Pending';
        } else if (filterStatus === 'Cancelled') {
          return order.delivery_status === 'Cancelled';
        }
        return true;
      });

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white mb-2">Orders Management</h1>
          <p className="text-gray-400">Track and manage customer orders.</p>
        </div>
        <div className="mt-4 sm:mt-0 flex items-center space-x-4">
          <div className="relative">
            <HiFilter className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="pl-10 pr-8 py-2 bg-slate-800 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
            >
              <option value="All">All Orders</option>
              <option value="Done">Done</option>
              <option value="Delivered">Delivered</option>
              <option value="Pending">Pending</option>
              <option value="Cancelled">Cancelled</option>
            </select>
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
              {filteredOrders.map((order) => (
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
                      {order.delivery_status !== 'Done' && order.delivery_status !== 'Delivered' && (
                        <button
                          onClick={() => markAsDelivered(order.order_id)}
                          className="bg-emerald-600 text-white px-3 py-1 rounded-lg text-sm hover:bg-emerald-700 transition-colors"
                        >
                          Mark as Delivered
                        </button>
                      )}
                    </td>
                  </tr>
                  {/* You can add expanded order details here if needed */}
                </React.Fragment>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Orders;