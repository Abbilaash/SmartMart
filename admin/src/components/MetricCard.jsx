import React from 'react';
import { HiTrendingUp, HiTrendingDown } from 'react-icons/hi';

const MetricCard = ({ title, value, trend, trendValue, icon: Icon, color }) => {
  return (
    <div className="bg-slate-800 rounded-2xl p-6 shadow-md hover:shadow-lg transition-shadow duration-300">
      <div className="flex items-center justify-between mb-4">
        <div className={`p-3 rounded-xl ${color}`}>
          <Icon className="w-6 h-6 text-white" />
        </div>
        <div className={`flex items-center text-sm ${trend === 'up' ? 'text-emerald-400' : 'text-red-400'}`}>
          {trend === 'up' ? <HiTrendingUp className="w-4 h-4 mr-1" /> : <HiTrendingDown className="w-4 h-4 mr-1" />}
          {trendValue}
        </div>
      </div>
      <div>
        <p className="text-gray-400 text-sm mb-1">{title}</p>
        <p className="text-white text-2xl font-bold">{value}</p>
      </div>
    </div>
  );
};

export default MetricCard;