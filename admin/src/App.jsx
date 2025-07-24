import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import ManageProducts from './pages/ManageProducts';
import Orders from './pages/Orders';
import Discounts from './pages/Discounts';
import Payments from './pages/Payments';

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-[#1e1e2f]">
        <Layout>
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