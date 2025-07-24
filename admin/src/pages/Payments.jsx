import React, { useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
import { HiFilter, HiCreditCard, HiCash } from 'react-icons/hi';

const Payments = () => {
  const [filterStatus, setFilterStatus] = useState('All');
  const [filterDate, setFilterDate] = useState('All');

  const transactions = [
    { id: 'TXN001', orderId: '#12345', amount: 299.99, mode: 'Card', status: 'Completed', date: '2024-01-15', customer: 'John Smith' },
    { id: 'TXN002', orderId: '#12346', amount: 1199.99, mode: 'UPI', status: 'Completed', date: '2024-01-14', customer: 'Sarah Johnson' },
    { id: 'TXN003', orderId: '#12347', amount: 89.99, mode: 'Cash', status: 'Failed', date: '2024-01-14', customer: 'Mike Wilson' },
    { id: 'TXN004', orderId: '#12348', amount: 199.99, mode: 'Card', status: 'Pending', date: '2024-01-13', customer: 'Emma Davis' },
    { id: 'TXN005', orderId: '#12349', amount: 120.00, mode: 'UPI', status: 'Completed', date: '2024-01-13', customer: 'James Brown' },
    { id: 'TXN006', orderId: '#12350', amount: 459.99, mode: 'Card', status: 'Completed', date: '2024-01-12', customer: 'Lisa Garcia' },
    { id: 'TXN007', orderId: '#12351', amount: 75.50, mode: 'Cash', status: 'Completed', date: '2024-01-12', customer: 'David Lee' }
  ];

  const monthlyRevenue = [
    { month: 'Jan', revenue: 45000 },
    { month: 'Feb', revenue: 52000 },
    { month: 'Mar', revenue: 48000 },
    { month: 'Apr', revenue: 61000 },
    { month: 'May', revenue: 55000 },
    { month: 'Jun', revenue: 67000 }
  ];

  const weeklyRevenue = [
    { week: 'Week 1', revenue: 12000 },
    { week: 'Week 2', revenue: 15000 },
    { week: 'Week 3', revenue: 18000 },
    { week: 'Week 4', revenue: 22000 }
  ];

  const getStatusColor = (status) => {
    switch (status) {
      case 'Completed': return 'bg-emerald-500 text-white';
      case 'Pending': return 'bg-amber-500 text-white';
      case 'Failed': return 'bg-red-500 text-white';
      default: return 'bg-gray-500 text-white';
    }
  };

  const getModeIcon = (mode) => {
    switch (mode) {
      case 'Card': return <HiCreditCard className="w-4 h-4" />;
      case 'Cash': return <HiCash className="w-4 h-4" />;
      default: return <div className="w-4 h-4 bg-violet-500 rounded-full"></div>;
    }
  };

  const filteredTransactions = transactions.filter(transaction => {
    const statusMatch = filterStatus === 'All' || transaction.status === filterStatus;
    const dateMatch = filterDate === 'All' || transaction.date.includes(filterDate);
    return statusMatch && dateMatch;
  });

  const totalRevenue = filteredTransactions.reduce((sum, transaction) => 
    transaction.status === 'Completed' ? sum + transaction.amount : sum, 0
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white mb-2">Payments & Transactions</h1>
          <p className="text-gray-400">Track and manage payment transactions.</p>
        </div>
        
        <div className="mt-4 sm:mt-0 flex items-center space-x-4">
          <div className="relative">
            <HiFilter className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="pl-10 pr-8 py-2 bg-slate-800 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
            >
              <option value="All">All Status</option>
              <option value="Completed">Completed</option>
              <option value="Pending">Pending</option>
              <option value="Failed">Failed</option>
            </select>
          </div>
          
          <select
            value={filterDate}
            onChange={(e) => setFilterDate(e.target.value)}
            className="px-3 py-2 bg-slate-800 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
          >
            <option value="All">All Dates</option>
            <option value="2024-01-15">Today</option>
            <option value="2024-01">This Month</option>
          </select>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
          <div className="flex items-center justify-between mb-4">
            <div className="p-3 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-600">
              <HiCreditCard className="w-6 h-6 text-white" />
            </div>
          </div>
          <div>
            <p className="text-gray-400 text-sm mb-1">Total Revenue</p>
            <p className="text-white text-2xl font-bold">${totalRevenue.toFixed(2)}</p>
          </div>
        </div>
        
        <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
          <div className="flex items-center justify-between mb-4">
            <div className="p-3 rounded-xl bg-gradient-to-r from-violet-500 to-purple-600">
              <HiCreditCard className="w-6 h-6 text-white" />
            </div>
          </div>
          <div>
            <p className="text-gray-400 text-sm mb-1">Total Transactions</p>
            <p className="text-white text-2xl font-bold">{filteredTransactions.length}</p>
          </div>
        </div>
        
        <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
          <div className="flex items-center justify-between mb-4">
            <div className="p-3 rounded-xl bg-gradient-to-r from-amber-500 to-orange-600">
              <HiCreditCard className="w-6 h-6 text-white" />
            </div>
          </div>
          <div>
            <p className="text-gray-400 text-sm mb-1">Success Rate</p>
            <p className="text-white text-2xl font-bold">
              {((filteredTransactions.filter(t => t.status === 'Completed').length / filteredTransactions.length) * 100).toFixed(1)}%
            </p>
          </div>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
          <h3 className="text-xl font-bold text-white mb-6">Monthly Revenue</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={monthlyRevenue}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="month" stroke="#9CA3AF" />
                <YAxis stroke="#9CA3AF" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#1F2937', 
                    border: 'none', 
                    borderRadius: '8px',
                    color: '#fff'
                  }} 
                />
                <Bar dataKey="revenue" fill="#10b981" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
          <h3 className="text-xl font-bold text-white mb-6">Weekly Revenue Trend</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={weeklyRevenue}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="week" stroke="#9CA3AF" />
                <YAxis stroke="#9CA3AF" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#1F2937', 
                    border: 'none', 
                    borderRadius: '8px',
                    color: '#fff'
                  }} 
                />
                <Line type="monotone" dataKey="revenue" stroke="#7c3aed" strokeWidth={3} dot={{ fill: '#7c3aed' }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Transactions Table */}
      <div className="bg-slate-800 rounded-2xl shadow-md overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-600">
          <h3 className="text-xl font-bold text-white">Recent Transactions</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-slate-700">
              <tr>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Transaction ID</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Order ID</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Customer</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Amount</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Mode</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Status</th>
                <th className="text-left py-4 px-6 text-gray-300 font-medium">Date</th>
              </tr>
            </thead>
            <tbody>
              {filteredTransactions.map((transaction) => (
                <tr key={transaction.id} className="border-b border-slate-600 hover:bg-slate-700 transition-colors">
                  <td className="py-4 px-6 text-white font-medium">{transaction.id}</td>
                  <td className="py-4 px-6 text-violet-400">{transaction.orderId}</td>
                  <td className="py-4 px-6 text-white">{transaction.customer}</td>
                  <td className="py-4 px-6 text-emerald-400 font-bold">${transaction.amount}</td>
                  <td className="py-4 px-6">
                    <div className="flex items-center space-x-2 text-white">
                      {getModeIcon(transaction.mode)}
                      <span>{transaction.mode}</span>
                    </div>
                  </td>
                  <td className="py-4 px-6">
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(transaction.status)}`}>
                      {transaction.status}
                    </span>
                  </td>
                  <td className="py-4 px-6 text-gray-300">{transaction.date}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Payments;