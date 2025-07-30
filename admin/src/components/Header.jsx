import React from 'react';
import { HiMenu, HiBell, HiUser, HiLogout } from 'react-icons/hi';
import Cookies from 'js-cookie';

const Header = ({ onMenuClick, username, onLogout }) => {
  const handleLogout = () => {
    // Clear cookies
    Cookies.remove('admin_username');
    Cookies.remove('admin_session');
    // Call logout function to redirect to login
    onLogout();
  };

  return (
    <header className="bg-slate-800 shadow-lg">
      <div className="flex items-center justify-between px-4 py-4">
        <div className="flex items-center">
          <button
            onClick={onMenuClick}
            className="text-gray-400 hover:text-white lg:hidden mr-4"
          >
            <HiMenu className="w-6 h-6" />
          </button>
          <h2 className="text-xl font-semibold text-white">Welcome back, {username}</h2>
        </div>
        
        <div className="flex items-center space-x-4">
          <button className="relative text-gray-400 hover:text-white transition-colors">
            <HiBell className="w-6 h-6" />
            <span className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></span>
          </button>
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-gradient-to-r from-violet-500 to-indigo-600 rounded-full flex items-center justify-center">
              <HiUser className="w-5 h-5 text-white" />
            </div>
            <span className="text-white text-sm">{username}</span>
            <button
              onClick={handleLogout}
              className="text-gray-400 hover:text-red-400 transition-colors ml-2"
              title="Logout"
            >
              <HiLogout className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;