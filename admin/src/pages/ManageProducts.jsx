import React, { useState, useEffect } from 'react';
import { HiPlus, HiPencil, HiTrash, HiSearch } from 'react-icons/hi';
import Modal from '../components/Modal';
import { useZxing } from 'react-zxing';

const API_URL = 'http://localhost:5000/admin/product';

const ManageProducts = () => {
  const [products, setProducts] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isScanOpen, setIsScanOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    barcode: '',
    description: '',
    price: '',
    discount_id: '',
    stck_qty: '',
    is_active: true,
    created_at: ''
  });
  const [error, setError] = useState('');

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const res = await fetch(`${API_URL}/get_products`);
      const data = await res.json();
      setProducts(data.products || []);
    } catch (err) {
      setProducts([]);
    }
  };

  const filteredProducts = products.filter(product =>
    product.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    product.barcode.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleAddProduct = () => {
    setEditingProduct(null);
    setFormData({
      name: '',
      barcode: '',
      description: '',
      price: '',
      discount_id: '',
      stck_qty: '',
      is_active: true,
      created_at: new Date().toISOString()
    });
    setError('');
    setIsModalOpen(true);
  };

  const handleEditProduct = (product) => {
    setEditingProduct(product);
    setFormData({
      name: product.name,
      barcode: product.barcode,
      description: product.description,
      price: product.price,
      discount_id: product.discount_id,
      stck_qty: product.stck_qty,
      is_active: product.is_active,
      created_at: product.created_at
    });
    setError('');
    setIsModalOpen(true);
  };

  const handleDeleteProduct = async (productId) => {
    try {
      const res = await fetch(`${API_URL}/delete_product`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ product_id: productId })
      });
      if (res.ok) {
        fetchProducts();
      }
    } catch (err) {
      // noop
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    // Validate required fields (discount is optional; product_id is derived from barcode)
    if (!formData.name || !formData.barcode || !formData.price || !formData.stck_qty) {
      setError('Please fill all required fields.');
      return;
    }
    try {
      if (editingProduct) {
        // Update product
        const res = await fetch(`${API_URL}/update_product`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            ...formData,
            // Ensure product_id stays aligned with barcode
            product_id: formData.barcode,
            // Only include discount_id if provided
            discount_id: formData.discount_id || undefined,
            price: parseFloat(formData.price),
            stck_qty: parseInt(formData.stck_qty),
            is_active: Boolean(formData.is_active),
            created_at: formData.created_at || new Date().toISOString(),
            image_url: '' // Not used
          })
        });
        if (res.ok) {
          fetchProducts();
          setIsModalOpen(false);
        } else {
          const data = await res.json();
          setError(data.message || 'Failed to update product');
        }
      } else {
        // Add product
        const res = await fetch(`${API_URL}/add_product`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            ...formData,
            // Backend uses barcode as product_id
            product_id: formData.barcode,
            // Only include discount_id if provided
            discount_id: formData.discount_id || undefined,
            price: parseFloat(formData.price),
            stck_qty: parseInt(formData.stck_qty),
            is_active: Boolean(formData.is_active),
            created_at: formData.created_at || new Date().toISOString(),
            image_url: '' // Not used
          })
        });
        if (res.ok) {
          fetchProducts();
          setIsModalOpen(false);
        } else {
          const data = await res.json();
          setError(data.message || 'Failed to add product');
        }
      }
    } catch (err) {
      setError('Network error');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white mb-2">Manage Products</h1>
          <p className="text-gray-400">Add, edit, and manage your product inventory.</p>
        </div>
        <button
          onClick={handleAddProduct}
          className="mt-4 sm:mt-0 bg-gradient-to-r from-violet-500 to-purple-600 text-white px-6 py-3 rounded-xl font-medium hover:scale-105 transition-transform duration-200 flex items-center space-x-2"
        >
          <HiPlus className="w-5 h-5" />
          <span>Add Product</span>
        </button>
      </div>

      {/* Search Bar */}
      <div className="relative">
        <HiSearch className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
        <input
          type="text"
          placeholder="Search products..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-3 bg-slate-800 text-white rounded-xl border border-slate-600 focus:border-violet-500 focus:outline-none"
        />
      </div>

      {/* Products List View */}
      <div className="overflow-x-auto rounded-xl bg-slate-800">
        <table className="min-w-full divide-y divide-slate-700">
          <thead>
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Product ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Name</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Barcode</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Price</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Stock Qty</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Active</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-700">
            {filteredProducts.map((product) => (
              <tr key={product._id}>
                <td className="px-6 py-4 whitespace-nowrap text-white">{product.product_id}</td>
                <td className="px-6 py-4 whitespace-nowrap text-white">{product.name}</td>
                <td className="px-6 py-4 whitespace-nowrap text-white">{product.barcode}</td>
                <td className="px-6 py-4 whitespace-nowrap text-white">₹{product.price}</td>
                <td className="px-6 py-4 whitespace-nowrap text-white">{product.stck_qty}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 rounded-full text-xs ${product.is_active ? 'bg-emerald-500 text-white' : 'bg-red-500 text-white'}`}>
                    {product.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap flex space-x-2">
                  <button
                    onClick={() => handleEditProduct(product)}
                    className="bg-blue-600 text-white py-1 px-3 rounded-lg hover:bg-blue-700 transition-colors flex items-center space-x-1"
                  >
                    <HiPencil className="w-4 h-4" />
                    <span>Edit</span>
                  </button>
                  <button
                    onClick={() => handleDeleteProduct(product._id)}
                    className="bg-red-600 text-white py-1 px-3 rounded-lg hover:bg-red-700 transition-colors flex items-center space-x-1"
                  >
                    <HiTrash className="w-4 h-4" />
                    <span>Delete</span>
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Add/Edit Product Modal */}
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} title={editingProduct ? 'Edit Product' : 'Add New Product'}>
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Product ID removed; barcode will be used as product_id */}
          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Name</label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
              required
            />
          </div>
          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Barcode (also used as Product ID)</label>
            <div className="flex gap-2">
              <input
                type="text"
                value={formData.barcode}
                onChange={(e) => setFormData({ ...formData, barcode: e.target.value })}
                className="flex-1 px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
                placeholder="Scan or enter barcode"
                required
              />
              <button
                type="button"
                onClick={() => setIsScanOpen(true)}
                className="px-3 py-2 rounded-lg bg-violet-600 text-white hover:bg-violet-700"
                title="Scan with Camera"
              >
                Scan
              </button>
            </div>
          </div>
          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Description</label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              rows="2"
              className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
            ></textarea>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-2">Price (₹)</label>
              <input
                type="number"
                value={formData.price}
                onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
                required
              />
            </div>
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-2">Stock Qty</label>
              <input
                type="number"
                value={formData.stck_qty}
                onChange={(e) => setFormData({ ...formData, stck_qty: e.target.value })}
                className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
                required
              />
            </div>
          </div>
          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Discount ID</label>
            <input
              type="text"
              value={formData.discount_id}
              onChange={(e) => setFormData({ ...formData, discount_id: e.target.value })}
              className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
            />
          </div>
          <div>
            <label className="block text-gray-300 text-sm font-medium mb-2">Active</label>
            <select
              value={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.value === 'true' })}
              className="w-full px-3 py-2 bg-slate-700 text-white rounded-lg border border-slate-600 focus:border-violet-500 focus:outline-none"
            >
              <option value="true">Active</option>
              <option value="false">Inactive</option>
            </select>
          </div>
          {error && <div className="text-red-400 text-sm text-center">{error}</div>}
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
              {editingProduct ? 'Update Product' : 'Add Product'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Camera Scanner Modal */}
      <Modal isOpen={isScanOpen} onClose={() => setIsScanOpen(false)} title="Scan Barcode">
        <div className="space-y-4">
          <p className="text-gray-400 text-sm">Point your camera at the product barcode. The detected code will be filled automatically.</p>
          <BarcodeScanner
            onDetected={(value) => {
              setFormData((prev) => ({ ...prev, barcode: value }));
              setIsScanOpen(false);
            }}
          />
          <div className="flex justify-end">
            <button
              type="button"
              onClick={() => setIsScanOpen(false)}
              className="px-4 py-2 text-gray-300 border border-slate-600 rounded-lg hover:bg-slate-700 transition-colors"
            >
              Close
            </button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

// Inline component to handle camera feed + scanning
const BarcodeScanner = ({ onDetected }) => {
  const { ref } = useZxing({
    onDecodeResult(result) {
      const text = result.getText();
      if (text) onDetected(text);
    },
  });

  return (
    <div className="rounded-xl overflow-hidden border border-slate-700">
      <video ref={ref} className="w-full h-auto" />
    </div>
  );
};

export default ManageProducts;