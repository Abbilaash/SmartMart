import React, { useState } from 'react';
import { HiChevronDown, HiChevronUp, HiFilter } from 'react-icons/hi';

const Orders = () => {
  const [orders, setOrders] = useState([
    {
      id: '#12345',
      customer: 'John Smith',
      paymentStatus: 'Paid',
      deliveryStatus: 'Delivered',
      date: '2024-01-15',
      total: 299.99,
      items: [
        { name: 'iPhone 15 Pro', quantity: 1, price: 999 },
        { name: 'Phone Case', quantity: 2, price: 25 }
      ],
      expanded: false
    },
    {
      id: '#12346',
      customer: 'Sarah Johnson',
      paymentStatus: 'Paid',
      deliveryStatus: 'Pending',
      date: '2024-01-14',
      total: 1199.99,
      items: [
        { name: 'MacBook Air M2', quantity: 1, price: 1199 }
      ],
      expanded: false
    },
    {
      id: '#12347',
      customer: 'Mike Wilson',
      paymentStatus: 'Failed',
      deliveryStatus: 'Cancelled',
      date: '2024-01-14',
      total: 89.99,
      items: [
        { name: 'Coffee Maker', quantity: 1, price: 89 }
      ],
      expanded: false
    },
    {
      id: '#12348',
      customer: 'Emma Davis',
      paymentStatus: 'Paid',
      deliveryStatus: 'Pending',
      date: '2024-01-13',
      total: 199.99,
      items: [
        { name: 'Wireless Headphones', quantity: 1, price: 199 }
      ],
      expanded: false
    },
    {
      id: '#12349',
      customer: 'James Brown',
      paymentStatus: 'Unpaid',
      deliveryStatus: 'Pending',
      date: '2024-01-13',
      total: 120.00,
      items: [
        { name: 'Nike Air Max', quantity: 1, price: 120 }
      ],
      expanded: false
    }
  ]);

  const [filterStatus, setFilterStatus] = useState('All');

  const getPaymentStatusColor = (status) => {
    switch (status) {
      case 'Paid': return 'bg-emerald-500 text-white';
      case 'Unpaid': return 'bg-amber-500 text-white';
      case 'Failed': return 'bg-red-500 text-white';
      default: return 'bg-gray-500 text-white';
    }
  };

  const getDeliveryStatusColor = (status) => {
    switch (status) {
      case 'Delivered': return 'bg-emerald-500 text-white';
      case 'Pending': return 'bg-blue-500 text-white';
      case 'Cancelled': return 'bg-red-500 text-white';
      default: return 'bg-gray-500 text-white';
    }
  };

  const toggleOrderExpansion = (orderId) => {
    setOrders(orders.map(order =>
      order.id === orderId ? { ...order, expanded: !order.expanded } : order
    ));
  };

  const markAsDelivered = (orderId) => {
    setOrders(orders.map(order =>
      order.id === orderId ? { ...order, deliveryStatus: 'Delivered' } : order
    ));
  };

  const filteredOrders = filterStatus === 'All' 
    ? orders 
    : orders.filter(order => order.deliveryStatus === filterStatus);

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
              <option value="Pending">Pending</option>
              <option value="Delivered">Delivered</option>
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
                <React.Fragment key={order.id}>
                  <tr className="border-b border-slate-600 hover:bg-slate-700 transition-colors">
                    <td className="py-4 px-6">
                      <div className="flex items-center space-x-2">
                        <button
                          onClick={() => toggleOrderExpansion(order.id)}
                          className="text-gray-400 hover:text-white"
                        >
                          {order.expanded ? <HiChevronUp className="w-4 h-4" /> : <HiChevronDown className="w-4 h-4" />}
                        </button>
                        <span className="text-white font-medium">{order.id}</span>
                      </div>
                    </td>
                    <td className="py-4 px-6 text-white">{order.customer}</td>
                    <td className="py-4 px-6">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getPaymentStatusColor(order.paymentStatus)}`}>
                        {order.paymentStatus}
                      </span>
                    </td>
                    <td className="py-4 px-6">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getDeliveryStatusColor(order.deliveryStatus)}`}>
                        {order.deliveryStatus}
                      </span>
                    </td>
                    <td className="py-4 px-6 text-gray-300">{order.date}</td>
                    <td className="py-4 px-6 text-emerald-400 font-bold">${order.total}</td>
                    <td className="py-4 px-6">
                      {order.deliveryStatus === 'Pending' && (
                        <button
                          onClick={() => markAsDelivered(order.id)}
                          className="bg-emerald-600 text-white px-3 py-1 rounded-lg text-sm hover:bg-emerald-700 transition-colors"
                        >
                          Mark as Delivered
                        </button>
                      )}
                    </td>
                  </tr>
                  {order.expanded && (
                    <tr>
                      <td colSpan="7" className="py-4 px-6 bg-slate-700">
                        <div className="space-y-2">
                          <h4 className="font-medium text-white mb-3">Order Items:</h4>
                          {order.items.map((item, index) => (
                            <div key={index} className="flex items-center justify-between py-2 px-4 bg-slate-600 rounded-lg">
                              <div className="flex items-center space-x-3">
                                <span className="text-white">{item.name}</span>
                                <span className="text-gray-400">x{item.quantity}</span>
                              </div>
                              <span className="text-emerald-400 font-medium">${item.price}</span>
                            </div>
                          ))}
                        </div>
                      </td>
                    </tr>
                  )}
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