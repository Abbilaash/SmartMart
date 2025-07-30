import React, { useState } from 'react';
import Sidebar from './Sidebar';
import Header from './Header';

const Layout = ({ children, username, onLogout }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="flex h-screen bg-[#1e1e2f]">
      <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header onMenuClick={() => setSidebarOpen(true)} username={username} onLogout={onLogout} />
        <main className="flex-1 overflow-x-hidden overflow-y-auto bg-[#1e1e2f] p-4 lg:p-6">
          {children}
        </main>
      </div>
    </div>
  );
};

export default Layout;