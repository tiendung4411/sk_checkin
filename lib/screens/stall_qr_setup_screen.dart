import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/qr_services.dart';

class StallQRSetupScreen extends StatefulWidget {
  final String ghcId; // Accept ghcId from the previous screen

  const StallQRSetupScreen({Key? key, required this.ghcId}) : super(key: key);

  @override
  _StallQRSetupScreenState createState() => _StallQRSetupScreenState();
}

class _StallQRSetupScreenState extends State<StallQRSetupScreen> {
  final QRServices _qrServices = QRServices();
  String? _qrCode; // Store the generated Stall QR code
  bool _isLoading = false;
  int _plays = 1; // Default number of plays
  int _pricePerPlay = 20000; // Default price per play
  int _totalAmount = 10000; // Default total amount

  final List<int> _priceOptions = [10000, 20000, 30000, 40000, 50000];

  @override
  void initState() {
    super.initState();
    _calculateTotal(); // Initialize the total amount
  }

  void _incrementPlays() {
    setState(() {
      _plays++;
      _calculateTotal();
    });
  }

  void _decrementPlays() {
    if (_plays > 1) {
      setState(() {
        _plays--;
        _calculateTotal();
      });
    }
  }

  void _calculateTotal() {
    _totalAmount = _plays * _pricePerPlay;
  }

  Future<void> _generateStallQR() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Calculate total amount
      _calculateTotal();

      // Send to backend
      final response = await _qrServices.generateGhcQRCode(
        widget.ghcId, // Pass the GHC ID
        _totalAmount, // Pass the total amount
      );

      if (response['success'] == true) {
        setState(() {
          _qrCode = response['qrCodeData']['qrCode']; // Extract QR code from response
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response['message']}')),
        );
      }
    } catch (e) {
      print("Lỗi tạo mã QR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo mã QR: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thiết lập QR Gian Hàng",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Number of Plays
            Text(
              "Số lượt chơi:",
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrementPlays,
                  icon: Icon(Icons.remove_circle_outline),
                  color: theme.colorScheme.primary,
                  iconSize: 40,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_plays',
                    style: theme.textTheme.headlineLarge,
                  ),
                ),
                IconButton(
                  onPressed: _incrementPlays,
                  icon: Icon(Icons.add_circle_outline),
                  color: theme.colorScheme.primary,
                  iconSize: 40,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price Per Play Dropdown
            Text(
              "Giá mỗi lượt chơi (VND):",
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            DropdownButton<int>(
              value: _pricePerPlay,
              onChanged: (value) {
                setState(() {
                  _pricePerPlay = value!;
                  _calculateTotal();
                });
              },
              items: _priceOptions.map((price) {
                return DropdownMenuItem(
                  value: price,
                  child: Text(
                    "${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ".")} VND",
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Total Amount
            Text(
              "Tổng số tiền: ${_totalAmount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ".")} VND",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 30),

            // Generate QR Button
            ElevatedButton(
              onPressed: _generateStallQR,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Tạo mã QR",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // QR Code with Frame
            if (_qrCode != null) ...[
              Text(
                "Quét mã QR bên dưới:",
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _qrCode!,
                  version: QrVersions.auto,
                  size: 250.0,
                  backgroundColor: Colors.white,
                  embeddedImage: AssetImage('assets/logo.png'),
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(100, 80),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}