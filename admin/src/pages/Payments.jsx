import React, { useState, useEffect } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
import { HiFilter, HiCreditCard, HiCash } from 'react-icons/hi';

const Payments = () => {
  const [filterStatus, setFilterStatus] = useState('All');
  const [filterDate, setFilterDate] = useState('All');
  const [transactions, setTransactions] = useState([]);
  const [monthlyRevenue, setMonthlyRevenue] = useState([]);
  const [weeklyRevenue, setWeeklyRevenue] = useState([]);
  const [summary, setSummary] = useState({
    total_revenue: 0,
    total_transactions: 0,
    success_rate: 0
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchPaymentsData();
  }, [filterStatus, filterDate]);

  const fetchPaymentsData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch all data in parallel
      const [transactionsRes, monthlyRes, weeklyRes, summaryRes] = await Promise.all([
        fetch(`http://localhost:5000/admin/payments/transactions?status=${filterStatus}&date=${filterDate}`),
        fetch(`http://localhost:5000/admin/payments/monthly_revenue?status=${filterStatus}&date=${filterDate}`),
        fetch(`http://localhost:5000/admin/payments/weekly_revenue?status=${filterStatus}&date=${filterDate}`),
        fetch(`http://localhost:5000/admin/payments/summary?status=${filterStatus}&date=${filterDate}`)
      ]);

      if (!transactionsRes.ok || !monthlyRes.ok || !weeklyRes.ok || !summaryRes.ok) {
        throw new Error('Failed to fetch payments data');
      }

      const [transactionsData, monthlyData, weeklyData, summaryData] = await Promise.all([
        transactionsRes.json(),
        monthlyRes.json(),
        weeklyRes.json(),
        summaryRes.json()
      ]);

      console.log('📊 API Response Data:', {
        transactions: transactionsData,
        monthly: monthlyData,
        weekly: weeklyData,
        summary: summaryData
      });

      setTransactions(transactionsData.transactions || []);
      setMonthlyRevenue(monthlyData.monthly_revenue || []);
      setWeeklyRevenue(weeklyData.weekly_revenue || []);
      setSummary(summaryData);

    } catch (err) {
      setError(err.message);
      console.error('Error fetching payments data:', err);
    } finally {
      setLoading(false);
    }
  };

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

  // Transactions are already filtered by the backend based on filterStatus and filterDate
  const filteredTransactions = transactions;

  // Debug logging
  console.log('🔍 Current State:', {
    transactions: transactions.length,
    monthlyRevenue: monthlyRevenue.length,
    weeklyRevenue: weeklyRevenue.length,
    summary,
    loading,
    error
  });

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
            <p className="text-white text-2xl font-bold">₹{summary.total_revenue.toFixed(2)}</p>
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
            <p className="text-white text-2xl font-bold">{summary.total_transactions}</p>
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
            <p className="text-white text-2xl font-bold">{summary.success_rate}%</p>
          </div>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
          <h3 className="text-xl font-bold text-white mb-6">Monthly Revenue</h3>
          <div className="h-64">
            {loading ? (
              <div className="flex items-center justify-center h-full">
                <div className="text-gray-400">Loading monthly revenue...</div>
              </div>
            ) : error ? (
              <div className="flex items-center justify-center h-full">
                <div className="text-red-400">Error: {error}</div>
              </div>
            ) : monthlyRevenue.length > 0 ? (
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
            ) : (
              <div className="flex items-center justify-center h-full">
                <div className="text-gray-400">No monthly revenue data available</div>
              </div>
            )}
          </div>
        </div>

        <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
          <h3 className="text-xl font-bold text-white mb-6">Weekly Revenue Trend</h3>
          <div className="h-64">
            {loading ? (
              <div className="flex items-center justify-center h-full">
                <div className="text-gray-400">Loading weekly revenue...</div>
              </div>
            ) : error ? (
              <div className="flex items-center justify-center h-full">
                <div className="text-red-400">Error: {error}</div>
              </div>
            ) : weeklyRevenue.length > 0 ? (
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
            ) : (
              <div className="flex items-center justify-center h-full">
                <div className="text-gray-400">No weekly revenue data available</div>
              </div>
            )}
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
              {loading ? (
                <tr>
                  <td colSpan="7" className="py-8 px-6 text-center text-gray-400">
                    Loading transactions...
                  </td>
                </tr>
              ) : error ? (
                <tr>
                  <td colSpan="7" className="py-8 px-6 text-center text-red-400">
                    Error: {error}
                  </td>
                </tr>
              ) : filteredTransactions.length === 0 ? (
                <tr>
                  <td colSpan="7" className="py-8 px-6 text-center text-gray-400">
                    No transactions found
                  </td>
                </tr>
              ) : (
                filteredTransactions.map((transaction) => (
                  <tr key={transaction._id} className="border-b border-slate-600 hover:bg-slate-700 transition-colors">
                    <td className="py-4 px-6 text-white font-medium">{transaction.transaction_id}</td>
                    <td className="py-4 px-6 text-violet-400">{transaction.order_id}</td>
                    <td className="py-4 px-6 text-white">{transaction.customer_name}</td>
                    <td className="py-4 px-6 text-emerald-400 font-bold">₹{transaction.amount}</td>
                    <td className="py-4 px-6">
                      <div className="flex items-center space-x-2 text-white">
                        {getModeIcon(transaction.payment_mode)}
                        <span>{transaction.payment_mode}</span>
                      </div>
                    </td>
                    <td className="py-4 px-6">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(transaction.payment_status)}`}>
                        {transaction.payment_status}
                      </span>
                    </td>
                    <td className="py-4 px-6 text-gray-300">{transaction.transaction_date}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Payments;