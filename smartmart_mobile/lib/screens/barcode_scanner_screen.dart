import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/cart_provider.dart';
import '../services/barcode_scanner_service.dart';
import '../models/product.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.upcA,
      BarcodeFormat.code128,
      BarcodeFormat.qrCode,
    ],
  );

  String? _lastScannedValue;
  Product? _scannedProduct;
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode or QR'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
            tooltip: 'Toggle torch',
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Switch camera',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryPurple, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MobileScanner(
                  controller: _controller,
                  onDetect: (BarcodeCapture capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isEmpty) return;
                    final Barcode first = barcodes.first;
                    final String? raw = first.rawValue;
                    if (raw == null) return;
                    
                    _processBarcode(raw);
                  },
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supported formats: EAN-13, UPC-A, Code128, and QR',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (_isProcessing)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Processing barcode...'),
                    ],
                  )
                else if (_scannedProduct != null)
                  _buildScannedProductInfo(context)
                else
                  Text(
                    _lastScannedValue == null
                        ? 'Point the camera at a code'
                        : 'Scanned: ${_lastScannedValue!}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _processBarcode(String barcodeData) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _lastScannedValue = barcodeData;
      _scannedProduct = null;
    });

    try {
      final product = BarcodeScannerService.scanProductFromBarcode(barcodeData);
      setState(() {
        _scannedProduct = product;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildScannedProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Found:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _scannedProduct!.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$${_scannedProduct!.currentPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _addToCart(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add to Cart'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cancelScan(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addToCart(BuildContext context) {
    if (_scannedProduct != null) {
      final cartProvider = context.read<CartProvider>();
      cartProvider.addItem(_scannedProduct!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_scannedProduct!.name} added to cart'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to home screen
      Navigator.of(context).pop();
    }
  }

  void _cancelScan() {
    setState(() {
      _scannedProduct = null;
      _lastScannedValue = null;
    });
  }
}
