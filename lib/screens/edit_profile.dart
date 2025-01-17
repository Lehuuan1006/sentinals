import 'package:flutter/material.dart';
import 'dart:convert'; // Để giải mã base64
import 'dart:typed_data'; // Để chuyển đổi base64 thành Uint8List

import 'package:flutter/material.dart';
import 'dart:convert'; // Để giải mã base64
import 'dart:typed_data'; // Để chuyển đổi base64 thành Uint8List

class EditProfileScreen extends StatelessWidget {
  final String? contactName;
  final String? email;
  final String? phoneNumber;
  final String? profileImage; // Chuỗi base64
  final String? role;

  const EditProfileScreen({
    Key? key,
    this.contactName,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Giải mã base64 thành Uint8List để hiển thị hình ảnh
    Uint8List? imageBytes;
    if (profileImage != null && profileImage!.isNotEmpty) {
      imageBytes = base64Decode(profileImage!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hiển thị ảnh đại diện
            if (imageBytes != null)
              CircleAvatar(
                radius: 60,
                backgroundImage: MemoryImage(imageBytes), // Hiển thị ảnh từ base64
              )
            else
              const CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
              ),
            const SizedBox(height: 20),

            // Hiển thị thông tin người dùng
            if (contactName != null && contactName!.isNotEmpty)
              _buildUserInfoItem('Tên liên hệ', contactName!),
            if (email != null && email!.isNotEmpty)
              _buildUserInfoItem('Email', email!),
            if (phoneNumber != null && phoneNumber!.isNotEmpty)
              _buildUserInfoItem('Số điện thoại', phoneNumber!),
            if (role != null && role!.isNotEmpty)
              _buildUserInfoItem('Vai trò', role!),
          ],
        ),
      ),
    );
  }

  // Widget để hiển thị từng thông tin người dùng
  Widget _buildUserInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}