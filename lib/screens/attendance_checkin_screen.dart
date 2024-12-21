import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/qr_services.dart';
import 'dart:async';

class AttendanceCheckInScreen extends StatefulWidget {
  @override
  _AttendanceCheckInScreenState createState() =>
      _AttendanceCheckInScreenState();
}

class _AttendanceCheckInScreenState extends State<AttendanceCheckInScreen> {
  final QRServices _qrServices = QRServices();
  String? _qrCode; // Lưu trữ mã QR đã tạo
  bool _isLoading = false;
  Timer? _timer; // Bộ đếm giờ tự động tạo QR mới
  int _timeLeft = 60; // Thời gian còn lại (giây)

  @override
  void initState() {
    super.initState();
    _startTimer(); // Bắt đầu bộ đếm giờ khi mở màn hình
    _generateAttendanceQR(); // Tạo mã QR ngay khi tải màn hình
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy bộ đếm giờ khi widget bị hủy
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Hủy bộ đếm giờ hiện tại nếu có
    _timeLeft = 120; // Đặt lại thời gian đếm ngược
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _generateAttendanceQR(); // Tạo mã QR mới
          _timeLeft = 60; // Đặt lại thời gian đếm ngược
        }
      });
    });
  }

  Future<void> _generateAttendanceQR() async {
    setState(() {
      _isLoading = true; // Hiển thị biểu tượng tải
    });

    try {
      final response = await _qrServices.generateAttendanceQRCode();
      if (response['success'] == true) {
        setState(() {
          _qrCode = response['qrCode']; // Lấy mã QR từ phản hồi
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response['message']}')),
        );
      }
    } catch (e) {
      print("Lỗi tạo mã QR điểm danh: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo mã QR điểm danh: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Ẩn biểu tượng tải
      });
    }
  }

  String _formatTimeLeft() {
    final minutes = _timeLeft ~/ 60; // Tính số phút
    final seconds = _timeLeft % 60; // Tính số giây còn lại
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'; // Định dạng MM:SS
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600; // Phát hiện thiết bị là tablet

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Điểm danh QR",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: theme.colorScheme.primary)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_qrCode != null) ...[
              Text(
                "Quét mã QR để điểm danh",
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _qrCode!,
                  version: QrVersions.auto,
                  embeddedImage: const AssetImage('assets/logo.png'),
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(120, 100),
                  ),
                  size: isTablet ? 400.0 : 250.0, // Tùy chỉnh kích thước QR trên tablet
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              "Thời gian còn lại: ${_formatTimeLeft()}",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: isTablet ? 28 : 20,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}