import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import MetricCard from '../components/MetricCard';
import { HiCurrencyDollar, HiClipboardList, HiCube, HiUsers } from 'react-icons/hi';

const Dashboard = () => {
  const salesData = [
    { name: 'Mon', sales: 4000 },
    { name: 'Tue', sales: 3000 },
    { name: 'Wed', sales: 5000 },
    { name: 'Thu', sales: 2780 },
    { name: 'Fri', sales: 1890 },
    { name: 'Sat', sales: 2390 },
    { name: 'Sun', sales: 3490 }
  ];

  const recentActivity = [
    { id: 1, action: 'New order #1234', user: 'John Smith', time: '2 mins ago', type: 'order' },
    { id: 2, action: 'Product "iPhone 15" updated', user: 'Admin', time: '5 mins ago', type: 'product' },
    { id: 3, action: 'Payment received #5678', user: 'Sarah Johnson', time: '10 mins ago', type: 'payment' },
    { id: 4, action: 'New user registered', user: 'Mike Wilson', time: '15 mins ago', type: 'user' },
    { id: 5, action: 'Inventory low alert', user: 'System', time: '20 mins ago', type: 'alert' }
  ];

  const getActivityColor = (type) => {
    switch (type) {
      case 'order': return 'text-emerald-400';
      case 'product': return 'text-violet-400';
      case 'payment': return 'text-blue-400';
      case 'user': return 'text-amber-400';
      case 'alert': return 'text-red-400';
      default: return 'text-gray-400';
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
          value="$45,820"
          trend="up"
          trendValue="12.5%"
          icon={HiCurrencyDollar}
          color="bg-gradient-to-r from-emerald-500 to-teal-600"
        />
        <MetricCard
          title="Active Orders"
          value="184"
          trend="up"
          trendValue="8.2%"
          icon={HiClipboardList}
          color="bg-gradient-to-r from-violet-500 to-purple-600"
        />
        <MetricCard
          title="Inventory Value"
          value="$128,430"
          trend="down"
          trendValue="3.1%"
          icon={HiCube}
          color="bg-gradient-to-r from-blue-500 to-indigo-600"
        />
        <MetricCard
          title="Customers"
          value="2,847"
          trend="up"
          trendValue="15.3%"
          icon={HiUsers}
          color="bg-gradient-to-r from-amber-500 to-orange-600"
        />
      </div>

      {/* Sales Chart */}
      <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
        <h3 className="text-xl font-bold text-white mb-6">Weekly Sales Overview</h3>
        <div className="h-80">
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
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-slate-800 rounded-2xl p-6 shadow-md">
        <h3 className="text-xl font-bold text-white mb-6">Recent Activity</h3>
        <div className="space-y-4">
          {recentActivity.map((activity) => (
            <div key={activity.id} className="flex items-center justify-between p-4 bg-slate-700 rounded-xl hover:bg-slate-600 transition-colors">
              <div className="flex items-center space-x-4">
                <div className={`w-2 h-2 rounded-full ${getActivityColor(activity.type).replace('text-', 'bg-')}`}></div>
                <div>
                  <p className="text-white font-medium">{activity.action}</p>
                  <p className="text-gray-400 text-sm">by {activity.user}</p>
                </div>
              </div>
              <span className="text-gray-400 text-sm">{activity.time}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;