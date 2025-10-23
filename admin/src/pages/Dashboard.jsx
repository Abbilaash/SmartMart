import React, { useState, useEffect } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import MetricCard from '../components/MetricCard';
import { HiCurrencyDollar, HiClipboardList, HiCube, HiUsers } from 'react-icons/hi';

const Dashboard = () => {
  const [salesData, setSalesData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [userCount, setUserCount] = useState(null);
  const [deliveredOrdersCount, setDeliveredOrdersCount] = useState(null);
  const [totalSales, setTotalSales] = useState(null);
  const [inventoryValue, setInventoryValue] = useState(null);

  useEffect(() => {
    fetchWeeklySales();
    fetchUserCount();
    fetchDeliveredOrdersCount();
    fetchTotalSales();
    fetchInventoryValue();
  }, []);

  
  const fetchWeeklySales = async () => {
    try {
      setLoading(true);
      const response = await fetch('http://localhost:5000/admin/dashboard/weekly_sales');
      if (!response.ok) {
        throw new Error('Failed to fetch weekly sales data');
      }
      const data = await response.json();
      setSalesData(data.sales_data);
    } catch (err) {
      setError(err.message);
      console.error('Error fetching weekly sales:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchUserCount = async () => {
    try {
      const response = await fetch('http://localhost:5000/admin/dashboard/user_count');
      if (!response.ok) {
        throw new Error('Failed to fetch user count');
      }
      const data = await response.json();
      setUserCount(data.user_count);
    } catch (err) {
      console.error('Error fetching user count:', err);
    }
  };

  const fetchDeliveredOrdersCount = async () => {
    try {
      const response = await fetch('http://localhost:5000/admin/dashboard/delivered_orders_count');
      if (!response.ok) {
        throw new Error('Failed to fetch delivered orders count');
      }
      const data = await response.json();
      setDeliveredOrdersCount(data.delivered_orders_count);
    } catch (err) {
      console.error('Error fetching delivered orders count:', err);
    }
  };

  const fetchTotalSales = async () => {
    try {
      const response = await fetch('http://localhost:5000/admin/dashboard/total_sales');
      if (!response.ok) {
        throw new Error('Failed to fetch total sales');
      }
      const data = await response.json();
      setTotalSales(data.total_sales);
    } catch (err) {
      console.error('Error fetching total sales:', err);
    }
  };

  const fetchInventoryValue = async () => {
    try {
      const response = await fetch('http://localhost:5000/admin/dashboard/inventory_value');
      if (!response.ok) {
        throw new Error('Failed to fetch inventory value');
      }
      const data = await response.json();
      setInventoryValue(data.total_inventory_value);
    } catch (err) {
      console.error('Error fetching inventory value:', err);
    }
  };


  return (
    <div className="space-y-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-white mb-2">Dashboard Overview</h1>
        <p className="text-gray-400">Welcome back! Here's what's happening with your store today.</p>
      </div>

      {/* Metrics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <MetricCard
          title="Total Sales"
          value={totalSales !== null ? `₹${totalSales.toLocaleString()}` : '...'}
          icon={HiCurrencyDollar}
          color="bg-gradient-to-r from-emerald-500 to-teal-600"
        />
        <MetricCard
          title="Active Orders"
          value={deliveredOrdersCount !== null ? deliveredOrdersCount.toLocaleString() : '...'}
          icon={HiClipboardList}
          color="bg-gradient-to-r from-violet-500 to-purple-600"
        />
        <MetricCard
          title="Inventory Value"
          value={inventoryValue !== null ? `₹${inventoryValue.toLocaleString()}` : '...'}
          icon={HiCube}
          color="bg-gradient-to-r from-blue-500 to-indigo-600"
        />
        <MetricCard
          title="Customers"
          value={userCount !== null ? userCount.toLocaleString() : '...'}
          icon={HiUsers}
          color="bg-gradient-to-r from-amber-500 to-orange-600"
        />
      </div>

      {/* Sales Chart */}
      <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
        <h3 className="text-xl font-bold text-white mb-6">Weekly Sales Overview</h3>
        <div className="h-80">
          {loading ? (
            <div className="flex items-center justify-center h-full">
              <div className="text-gray-400">Loading sales data...</div>
            </div>
          ) : error ? (
            <div className="flex items-center justify-center h-full">
              <div className="text-red-400">Error: {error}</div>
            </div>
          ) : salesData.length > 0 ? (
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={salesData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="name" stroke="#9CA3AF" />
                <YAxis stroke="#9CA3AF" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#1F2937', 
                    border: 'none', 
                    borderRadius: '8px',
                    color: '#fff'
                  }} 
                />
                <Bar dataKey="sales" fill="#7c3aed" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex items-center justify-center h-full">
              <div className="text-gray-400">No sales data available</div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;