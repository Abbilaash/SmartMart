import React, { useState } from 'react';
import { HiPlus, HiPencil, HiTrash } from 'react-icons/hi';
import Modal from '../components/Modal';

const Discounts = () => {
  const [discounts, setDiscounts] = useState([
    {
      id: 1,
      code: 'SUMMER20',
      product: 'All Electronics',
      percentage: 20,
      startDate: '2024-06-01',
      endDate: '2024-08-31',
      status: 'Active'
    },
    {
      id: 2,
      code: 'NEWUSER10',
      product: 'All Products',
      percentage: 10,
      startDate: '2024-01-01',
      endDate: '2024-12-31',
      status: 'Active'
    },
    {
      id: 3,
      code: 'BLACKFRIDAY',
      product: 'Fashion Category',
      percentage: 50,
      startDate: '2023-11-24',
      endDate: '2023-11-26',
      status: 'Expired'
    },
    {
      id: 4,
      code: 'SPRING15',
      product: 'Home Category',
      percentage: 15,
      startDate: '2024-03-20',
      endDate: '2024-06-20',
      status: 'Active'
    }
  ]);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    code: '',
    product: '',
    percentage: '',
    startDate: '',
    endDate: ''
  });

  const handleAddDiscount = () => {
    setFormData({ code: '', product: '', percentage: '', startDate: '', endDate: '' });
    setIsModalOpen(true);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const newDiscount = {
      id: Date.now(),
      ...formData,
      percentage: parseInt(formData.percentage),
      status: new Date(formData.endDate) > new Date() ? 'Active' : 'Expired'
    };
    setDiscounts([...discounts, newDiscount]);
    setIsModalOpen(false);
  };

  const handleDeleteDiscount = (id) => {
    setDiscounts(discounts.filter(discount => discount.id !== id));
  };

  const getStatusColor = (status) => {
    return status === 'Active' ? 'bg-emerald-500 text-white' : 'bg-red-500 text-white';
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white mb-2">Discounts & Offers</h1>
          <p className="text-gray-400">Create and manage discount codes for your products.</p>
        </div>
        <button
          onClick={handleAddDiscount}
          className="mt-4 sm:mt-0 bg-gradient-to-r from-violet-500 to-purple-600 text-white px-6 py-3 rounded-xl font-medium hover:scale-105 transition-transform duration-200 flex items-center space-x-2"
        >
          <HiPlus className="w-5 h-5" />
          <span>Create New Discount</span>
        </button>
      </div>

      {/* Discounts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {discounts.map((discount) => (
          <div key={discount.id} className="bg-slate-800 rounded-2xl p-6 shadow-md hover:shadow-lg transition-all duration-300">
            <div className="flex items-start justify-between mb-4">
              <div className="flex-1">
                <div className="flex items-center space-x-3 mb-2">
                  <h3 className="text-xl font-bold text-white">{discount.code}</h3>
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(discount.status)}`}>
                    {discount.status}
                  </span>
                </div>
                <p className="text-gray-400 mb-2">{discount.product}</p>
                <div className="flex items-center space-x-2">
                  <span className="text-3xl font-bold text-emerald-400">{discount.percentage}%</span>
                  <span className="text-gray-400">OFF</span>
                </div>
              </div>
              <div className="flex space-x-2">
                <button className="text-blue-400 hover:text-blue-300 transition-colors">
                  <HiPencil className="w-5 h-5" />
                </button>
                <button 
                  onClick={() => handleDeleteDiscount(discount.id)}
                  className="text-red-400 hover:text-red-300 transition-colors"
                >
                  <HiTrash className="w-5 h-5" />
                </button>
              </div>
            </div>
            
            <div className="border-t border-slate-600 pt-4">
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-gray-400">Start Date</p>
                  <p className="text-white font-medium">{new Date(discount.startDate).toLocaleDateString()}</p>
                </div>
                <div>
                  <p className="text-gray-400">End Date</p>
                  <p className="text-white font-medium">{new Date(discount.endDate).toLocaleDateString()}</p>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Create Discount Modal */}
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} title="Create New Discount">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Discount Code</label>
            <input
              type="text"
              value={formData.code}
              onChange={(e) => setFormData({...formData, code: e.target.value.toUpperCase()})}
              className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
              placeholder="e.g., SAVE20"
              required
            />
          </div>
          
          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Product/Category</label>
            <select
              value={formData.product}
              onChange={(e) => setFormData({...formData, product: e.target.value})}
              className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
              required
            >
              <option value="">Select Product/Category</option>
              <option value="All Products">All Products</option>
              <option value="Electronics Category">Electronics Category</option>
              <option value="Fashion Category">Fashion Category</option>
              <option value="Home Category">Home Category</option>
              <option value="Sports Category">Sports Category</option>
            </select>
          </div>

          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Discount Percentage</label>
            <input
              type="number"
              value={formData.percentage}
              onChange={(e) => setFormData({...formData, percentage: e.target.value})}
              className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
              min="1"
              max="100"
              placeholder="e.g., 20"
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-2">Start Date</label>
              <input
                type="date"
                value={formData.startDate}
                onChange={(e) => setFormData({...formData, startDate: e.target.value})}
                className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
                required
              />
            </div>
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-2">End Date</label>
              <input
                type="date"
                value={formData.endDate}
                onChange={(e) => setFormData({...formData, endDate: e.target.value})}
                className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
                required
              />
            </div>
          </div>

          <div className="flex space-x-4 pt-4">
            <button
              type="button"
              onClick={() => setIsModalOpen(false)}
              className="flex-1 px-4 py-2 text-gray-300 border border-slate-600 rounded-lg hover:bg-slate-700 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="flex-1 bg-gradient-to-r from-violet-500 to-purple-600 text-white px-4 py-2 rounded-lg hover:scale-105 transition-transform"
            >
              Create Discount
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

export default Discounts;