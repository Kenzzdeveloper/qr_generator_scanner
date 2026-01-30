import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../store/qr_store.dart';

const Color primaryBlue = Color(0xFF2563EB);
const Color lightBlue = Color(0xFFEFF6FF);

class SettingScreen extends StatefulWidget {
  final AppUser user;

  const SettingScreen({
    super.key,
    required this.user,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late String userName;
  late String userRole;

  File? profileImage;

  final ImagePicker _picker = ImagePicker();

  // =======================
  // INIT
  // =======================
  @override
  void initState() {
    super.initState();

    userName = widget.user.name;
    userRole = widget.user.role;

    if (widget.user.imagePath != null) {
      profileImage = File(widget.user.imagePath!);
    }
  }

  // =======================
  // PICK IMAGE
  // =======================
  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  // =======================
  // EDIT NAME
  // =======================
  void _showEditNameSheet() {
    final controller = TextEditingController(text: userName);

    _showBottomSheet(
      title: "Nama",
      hint: "Masukkan nama kamu",
      controller: controller,
      onSave: () {
        setState(() {
          userName = controller.text.trim();
        });
      },
    );
  }

  // =======================
  // EDIT ROLE
  // =======================
  void _showEditRoleSheet() {
    final controller = TextEditingController(text: userRole);

    _showBottomSheet(
      title: "Jabatan",
      hint: "Contoh: Fullstack Developer",
      controller: controller,
      onSave: () {
        setState(() {
          userRole = controller.text.trim();
        });
      },
    );
  }

  // =======================
  // BOTTOM SHEET
  // =======================
  void _showBottomSheet({
    required String title,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            // INPUT
            TextField(
              controller: controller,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                labelText: title,
                floatingLabelBehavior: FloatingLabelBehavior.auto,

                filled: true,
                fillColor: Colors.grey.shade50,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: primaryBlue,
                    width: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onSave();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================
  // SAVE & EXIT
  // =======================
  void _saveAndExit() {
    Navigator.pop(
      context,
      AppUser(
        name: userName,
        role: userRole,
        imagePath: profileImage?.path,
      ),
    );
  }

  // =======================
  // UI
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: primaryBlue,
          ),
          onPressed: _saveAndExit,
        ),

        title: const Text(
          "Settings",
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // =======================
            // PROFILE
            // =======================
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: primaryBlue,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : const AssetImage(
                              'assets/images/profile.jpg',
                            ) as ImageProvider,
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickProfileImage,

                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =======================
            // NAME & ROLE
            // =======================
            Column(
              children: [
                GestureDetector(
                  onTap: _showEditNameSheet,

                  child: Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                GestureDetector(
                  onTap: _showEditRoleSheet,

                  child: Text(
                    userRole,
                    style: const TextStyle(
                      fontSize: 14,
                      color: primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // =======================
            // HISTORY
            // =======================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Scan History",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),

            const SizedBox(height: 12),

            QrStore.instance.historyList.isEmpty
                ? const Center(
                    child: Text("Belum ada history scan"),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      itemCount:
                          QrStore.instance.historyList.length,

                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),

                      itemBuilder: (context, index) {
                        final item =
                            QrStore.instance.historyList[index];

                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),

                            child: Image.memory(
                              item.imageBytes,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            ),
                          ),

                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          subtitle: Text(item.date),

                          trailing: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),

                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),

                            child: Text(
                              item.type,
                              style: const TextStyle(
                                fontSize: 10,
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
