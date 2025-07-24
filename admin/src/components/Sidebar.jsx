import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { HiX, HiHome, HiCube, HiClipboardList, HiGift, HiCreditCard, HiLogout } from 'react-icons/hi';

const Sidebar = ({ isOpen, onClose }) => {
  const location = useLocation();

  const menuItems = [
    { path: '/', name: 'Dashboard', icon: HiHome },
    { path: '/products', name: 'Manage Products', icon: HiCube },
    { path: '/orders', name: 'Orders', icon: HiClipboardList },
    { path: '/discounts', name: 'Discounts', icon: HiGift },
    { path: '/payments', name: 'Payments', icon: HiCreditCard },
  ];

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && (
        <div 
          className="fixed inset-0 z-40 bg-black bg-opacity-50 lg:hidden"
          onClick={onClose}
        />
      )}
      
      {/* Sidebar */}
      <div className={`fixed inset-y-0 left-0 z-50 w-64 bg-slate-800 transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0 ${
        isOpen ? 'translate-x-0' : '-translate-x-full'
      }`}>
        <div className="flex items-center justify-between h-16 px-6 bg-slate-900">
          <h1 className="text-xl font-bold text-white">Admin Panel</h1>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white lg:hidden"
          >
            <HiX className="w-6 h-6" />
          </button>
        </div>
        
        <nav className="mt-8">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            
            return (
              <Link
                key={item.path}
                to={item.path}
                onClick={onClose}
                className={`flex items-center px-6 py-3 text-left transition-colors duration-200 ${
                  isActive
                    ? 'bg-violet-600 text-white border-r-4 border-violet-400'
                    : 'text-gray-300 hover:bg-slate-700 hover:text-white'
                }`}
              >
                <Icon className={`w-5 h-5 mr-3 ${isActive ? 'text-violet-200' : ''}`} />
                {item.name}
              </Link>
            );
          })}
          
          <button className="flex items-center w-full px-6 py-3 mt-8 text-gray-300 hover:bg-red-600 hover:text-white transition-colors duration-200">
            <HiLogout className="w-5 h-5 mr-3" />
            Logout
          </button>
        </nav>
      </div>
    </>
  );
};

export default Sidebar;