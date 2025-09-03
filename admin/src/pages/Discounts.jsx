import React, { useState, useEffect } from 'react';
import { HiPlus, HiPencil, HiTrash, HiQrcode } from 'react-icons/hi';
import Modal from '../components/Modal';
import { useZxing } from 'react-zxing';

const Discounts = () => {
  const [discounts, setDiscounts] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isQrModalOpen, setIsQrModalOpen] = useState(false);
  const [editingDiscount, setEditingDiscount] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    percentage: '',
    start_date: '',
    end_date: '',
    product_barcode: ''
  });
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const API_BASE = 'http://127.0.0.1:5000';

  // Fetch discounts from backend
  const fetchDiscounts = async () => {
    try {
      const response = await fetch(`${API_BASE}/admin/discounts/get_discounts`);
      if (response.ok) {
        const data = await response.json();
        setDiscounts(data.discounts || []);
      } else {
        setError('Failed to fetch discounts');
      }
    } catch (err) {
      setError('Error fetching discounts');
      console.error(err);
    }
  };

  useEffect(() => {
    fetchDiscounts();
  }, []);

  const handleAddDiscount = () => {
    setFormData({ name: '', percentage: '', start_date: '', end_date: '', product_barcode: '' });
    setEditingDiscount(null);
    setIsModalOpen(true);
  };

  const handleEditDiscount = (discount) => {
    setEditingDiscount(discount);
    setFormData({
      name: discount.name,
      percentage: discount.percentage.toString(),
      start_date: discount.start_date,
      end_date: discount.end_date,
      product_barcode: discount.product_barcode
    });
    setIsEditModalOpen(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      const url = editingDiscount 
        ? `${API_BASE}/admin/discounts/update_discount`
        : `${API_BASE}/admin/discounts/add_discount`;
      
      const method = editingDiscount ? 'PUT' : 'POST';
      const body = editingDiscount 
        ? { ...formData, discount_id: editingDiscount._id }
        : formData;

      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });

      if (response.ok) {
        await fetchDiscounts();
        setIsModalOpen(false);
        setIsEditModalOpen(false);
        setFormData({ name: '', percentage: '', start_date: '', end_date: '', product_barcode: '' });
        setEditingDiscount(null);
      } else {
        const errorData = await response.json();
        setError(errorData.message || 'Failed to save discount');
      }
    } catch (err) {
      setError('Error saving discount');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleDeleteDiscount = async (id) => {
    if (!window.confirm('Are you sure you want to delete this discount?')) return;

    try {
      const response = await fetch(`${API_BASE}/admin/discounts/delete_discount`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ discount_id: id })
      });

      if (response.ok) {
        await fetchDiscounts();
      } else {
        setError('Failed to delete discount');
      }
    } catch (err) {
      setError('Error deleting discount');
      console.error(err);
    }
  };

  const handleToggleStatus = async (discount) => {
    try {
      const response = await fetch(`${API_BASE}/admin/discounts/toggle_status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ discount_id: discount._id })
      });

      if (response.ok) {
        await fetchDiscounts();
      } else {
        setError('Failed to toggle discount status');
      }
    } catch (err) {
      setError('Error toggling discount status');
      console.error(err);
    }
  };

  const getStatusColor = (status) => {
    return status === 'Active' ? 'bg-emerald-500 text-white' : 'bg-red-500 text-white';
  };

  const getStatusText = (discount) => {
    if (discount.status === 'Inactive') return 'Inactive';
    
    const currentDate = new Date();
    const startDate = new Date(discount.start_date);
    const endDate = new Date(discount.end_date);
    
    if (currentDate < startDate) return 'Pending';
    if (currentDate > endDate) return 'Expired';
    return 'Active';
  };

  const getStatusColorDynamic = (discount) => {
    const status = getStatusText(discount);
    switch (status) {
      case 'Active': return 'bg-emerald-500 text-white';
      case 'Pending': return 'bg-yellow-500 text-white';
      case 'Expired': return 'bg-red-500 text-white';
      case 'Inactive': return 'bg-gray-500 text-white';
      default: return 'bg-gray-500 text-white';
    }
  };

  // QR Code Scanner Component
  const QRScanner = ({ onScan, onClose }) => {
    const [scannedCode, setScannedCode] = useState('');
    const { ref } = useZxing({
      onDecodeResult(result) {
        const text = result.getText();
        if (text) {
          setScannedCode(text);
        }
      },
    });

    const handleConfirm = () => {
      if (scannedCode) {
        onScan(scannedCode);
        onClose();
      }
    };

    return (
      <div className="space-y-4">
        <div className="rounded-xl overflow-hidden border border-slate-700">
          <video ref={ref} className="w-full h-auto" />
        </div>
        {scannedCode ? (
          <div className="flex items-center gap-3">
            <div className="flex-1 px-3 py-2 bg-slate-800 text-white rounded-lg border border-slate-600">
              Scanned: <span className="font-mono">{scannedCode}</span>
            </div>
            <button
              type="button"
              onClick={handleConfirm}
              className="px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700"
            >
              Confirm
            </button>
            <button
              type="button"
              onClick={() => setScannedCode('')}
              className="px-4 py-2 border border-slate-600 text-gray-200 rounded-lg hover:bg-slate-700"
            >
              Rescan
            </button>
          </div>
        ) : (
          <div className="text-gray-400 text-sm">Scanning for QR codes...</div>
        )}
      </div>
    );
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

      {error && (
        <div className="bg-red-500 text-white px-4 py-2 rounded-lg">
          {error}
        </div>
      )}

      {/* Discounts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {discounts.map((discount) => (
          <div key={discount._id} className="bg-slate-800 rounded-2xl p-6 shadow-md hover:shadow-lg transition-all duration-300">
            <div className="flex items-start justify-between mb-4">
              <div className="flex-1">
                <div className="flex items-center space-x-3 mb-2">
                  <h3 className="text-xl font-bold text-white">{discount.name}</h3>
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColorDynamic(discount)}`}>
                    {getStatusText(discount)}
                  </span>
                </div>
                <p className="text-gray-400 mb-2">{discount.product_name}</p>
                <p className="text-gray-400 mb-2 text-sm">Barcode: {discount.product_barcode}</p>
                <div className="flex items-center space-x-2">
                  <span className="text-3xl font-bold text-emerald-400">{discount.percentage}%</span>
                  <span className="text-gray-400">OFF</span>
                </div>
              </div>
              <div className="flex space-x-2">
                <button 
                  onClick={() => handleEditDiscount(discount)}
                  className="text-blue-400 hover:text-blue-300 transition-colors"
                  title="Edit Discount"
                >
                  <HiPencil className="w-5 h-5" />
                </button>
                <button 
                  onClick={() => handleToggleStatus(discount)}
                  className={`px-2 py-1 rounded text-xs font-medium transition-colors ${
                    discount.status === 'Active' 
                      ? 'bg-red-500 text-white hover:bg-red-600' 
                      : 'bg-emerald-500 text-white hover:bg-emerald-600'
                  }`}
                  title={discount.status === 'Active' ? 'Deactivate' : 'Activate'}
                >
                  {discount.status === 'Active' ? 'Deactivate' : 'Activate'}
                </button>
                <button 
                  onClick={() => handleDeleteDiscount(discount._id)}
                  className="text-red-400 hover:text-red-300 transition-colors"
                  title="Delete Discount"
                >
                  <HiTrash className="w-5 h-5" />
                </button>
              </div>
            </div>
            
            <div className="border-t border-slate-600 pt-4">
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-gray-400">Start Date</p>
                  <p className="text-white font-medium">{new Date(discount.start_date).toLocaleDateString()}</p>
                </div>
                <div>
                  <p className="text-gray-400">End Date</p>
                  <p className="text-white font-medium">{new Date(discount.end_date).toLocaleDateString()}</p>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Create/Edit Discount Modal */}
      <Modal 
        isOpen={isModalOpen || isEditModalOpen} 
        onClose={() => {
          setIsModalOpen(false);
          setIsEditModalOpen(false);
          setEditingDiscount(null);
        }} 
        title={editingDiscount ? "Edit Discount" : "Create New Discount"}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Discount Name</label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({...formData, name: e.target.value})}
              className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
              placeholder="e.g., Summer Sale 20%"
              required
            />
          </div>
          
          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Product Barcode</label>
            <div className="flex gap-2">
              <input
                type="text"
                value={formData.product_barcode}
                onChange={(e) => setFormData({...formData, product_barcode: e.target.value})}
                className="flex-1 px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
                placeholder="Scan or enter barcode"
                required
              />
              <button
                type="button"
                onClick={() => setIsQrModalOpen(true)}
                className="px-3 py-2 rounded-lg bg-violet-600 text-white hover:bg-violet-700"
                title="Scan QR Code"
              >
                <HiQrcode className="w-5 h-5" />
              </button>
            </div>
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
                value={formData.start_date}
                onChange={(e) => setFormData({...formData, start_date: e.target.value})}
                className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
                required
              />
            </div>
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-2">End Date</label>
              <input
                type="date"
                value={formData.end_date}
                onChange={(e) => setFormData({...formData, end_date: e.target.value})}
                className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
                required
              />
            </div>
          </div>

          <div className="flex space-x-4 pt-4">
            <button
              type="button"
              onClick={() => {
                setIsModalOpen(false);
                setIsEditModalOpen(false);
                setEditingDiscount(null);
              }}
              className="flex-1 px-4 py-2 text-gray-300 border border-slate-600 rounded-lg hover:bg-slate-700 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="flex-1 bg-gradient-to-r from-violet-500 to-purple-600 text-white px-4 py-2 rounded-lg hover:scale-105 transition-transform disabled:opacity-50"
            >
              {isLoading ? 'Saving...' : (editingDiscount ? 'Update Discount' : 'Create Discount')}
            </button>
          </div>
        </form>
      </Modal>

      {/* QR Scanner Modal */}
      <Modal 
        isOpen={isQrModalOpen} 
        onClose={() => setIsQrModalOpen(false)} 
        title="Scan Product QR Code"
      >
        <QRScanner 
          onScan={(code) => {
            setFormData({...formData, product_barcode: code});
          }}
          onClose={() => setIsQrModalOpen(false)}
        />
      </Modal>
    </div>
  );
};

export default Discounts;