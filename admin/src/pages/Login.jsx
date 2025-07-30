import React, { useState } from 'react';
import Cookies from 'js-cookie';

const Logo = () => (
  <div className="flex flex-col items-center mb-6">
    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" className="mb-2">
      <rect x="3" y="6" width="18" height="13" rx="2" fill="url(#paint0_linear)"/>
      <path d="M7 6V4a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v2" stroke="#fff" strokeWidth="2" strokeLinecap="round"/>
      <circle cx="8.5" cy="18.5" r="1.5" fill="#fff"/>
      <circle cx="15.5" cy="18.5" r="1.5" fill="#fff"/>
      <defs>
        <linearGradient id="paint0_linear" x1="3" y1="6" x2="21" y2="19" gradientUnits="userSpaceOnUse">
          <stop stopColor="#7c3aed" />
          <stop offset="1" stopColor="#6366f1" />
        </linearGradient>
      </defs>
    </svg>
    <span className="text-3xl font-extrabold bg-gradient-to-r from-violet-500 to-indigo-600 bg-clip-text text-transparent tracking-tight">SmartMart</span>
  </div>
);

const Login = ({ onLogin, username }) => {
  const [form, setForm] = useState({ username: '', password: '' });
  const [error, setError] = useState('');

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const res = await fetch('http://localhost:5000/admin/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (res.ok) {
        // Save session to cookies
        Cookies.set('admin_username', data.username, { expires: 7 }); // 7 days
        Cookies.set('admin_session', 'active', { expires: 7 });
        onLogin(data.username);
      } else {
        setError(data.message || 'Login failed');
      }
    } catch (err) {
      setError('Network error');
    }
  };

  if (username) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-[#1e1e2f]">
        <div className="bg-slate-800 p-8 rounded-2xl shadow-md w-full max-w-md text-center">
          <Logo />
          <h2 className="text-2xl font-bold text-white mb-4">Welcome, {username}!</h2>
          <p className="text-gray-400">You are now logged in as admin.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-[#1e1e2f]">
      <form onSubmit={handleSubmit} className="bg-slate-800 p-8 rounded-2xl shadow-md w-full max-w-md flex flex-col items-center">
        <Logo />
        <h2 className="text-2xl font-bold text-white mb-6 text-center">AdminLogin</h2>
        <div className="mb-4 w-full">
          <label className="block text-gray-400 mb-2">Username</label>
          <input
            type="text"
            name="username"
            value={form.username}
            onChange={handleChange}
            className="w-full px-4 py-2 rounded-lg bg-slate-900 text-white focus:outline-none focus:ring-2 focus:ring-violet-500"
            required
          />
        </div>
        <div className="mb-6 w-full">
          <label className="block text-gray-400 mb-2">Password</label>
          <input
            type="password"
            name="password"
            value={form.password}
            onChange={handleChange}
            className="w-full px-4 py-2 rounded-lg bg-slate-900 text-white focus:outline-none focus:ring-2 focus:ring-violet-500"
            required
          />
        </div>
        {error && <div className="mb-4 text-red-400 text-sm w-full text-center">{error}</div>}
        <button
          type="submit"
          className="w-full py-2 bg-gradient-to-r from-violet-500 to-indigo-600 text-white font-semibold rounded-lg shadow-md hover:from-violet-600 hover:to-indigo-700 transition-colors"
        >
          Login
        </button>
      </form>
    </div>
  );
};

export default Login;