import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import ManageProducts from './pages/ManageProducts';
import Orders from './pages/Orders';
import Discounts from './pages/Discounts';
import Payments from './pages/Payments';
import Login from './pages/Login';
import Cookies from 'js-cookie';

function App() {
  const [username, setUsername] = useState('');

  useEffect(() => {
    // Check for existing session on component mount
    const savedUsername = Cookies.get('admin_username');
    const sessionActive = Cookies.get('admin_session');
    
    if (savedUsername && sessionActive === 'active') {
      setUsername(savedUsername);
    }
  }, []);

  const handleLogout = () => {
    setUsername('');
  };

  if (!username) {
    return <Login onLogin={setUsername} username={username} />;
  }

  return (
    <Router>
      <div className="min-h-screen bg-[#1e1e2f]">
        <Layout username={username} onLogout={handleLogout}>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/products" element={<ManageProducts />} />
            <Route path="/orders" element={<Orders />} />
            <Route path="/discounts" element={<Discounts />} />
            <Route path="/payments" element={<Payments />} />
          </Routes>
        </Layout>
      </div>
    </Router>
  );
}

export default App;