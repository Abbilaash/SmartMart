import React from 'react';
import { HiMenu, HiBell, HiUser } from 'react-icons/hi';

const Header = ({ onMenuClick }) => {
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
          <h2 className="text-xl font-semibold text-white">Welcome back, Admin</h2>
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
            <span className="text-white text-sm">John Doe</span>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;