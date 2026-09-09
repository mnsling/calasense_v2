import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/pageheader.dart';
import 'signinpage.dart';

// ===============================================================
// PROFILE PAGE
// ===============================================================

class ProfilePage extends StatefulWidget {
  final VoidCallback? onOpenCollections;

  const ProfilePage({super.key, this.onOpenCollections});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  String username = 'User';
  String email = '';
  String? avatarUrl;

  bool loading = true;
  bool loggingOut = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => loading = false);
      }
      return;
    }

    try {
      final profile = await supabase
          .from('profiles')
          .select('username, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        username = profile?['username']?.toString().trim().isNotEmpty == true
            ? profile!['username']
            : 'User';

        avatarUrl = profile?['avatar_url'];
        email = user.email ?? '';
        loading = false;
      });
    } catch (e) {
      debugPrint('Load profile error: $e');

      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> logout() async {
    if (loggingOut) return;

    setState(() => loggingOut = true);

    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/bg2.png', fit: BoxFit.cover),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'My Profile',
                  subtitle: 'Manage your account and\npreferences.',
                ),

                const SizedBox(height: 28),

                // PROFILE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      AvatarWidget(size: 58, avatarUrl: avatarUrl),

                      const SizedBox(width: 14),

                      Expanded(
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF49784D),
                                strokeWidth: 2,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF315B34),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    email,
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // MENU
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      MenuTile(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        subtitle: 'Update your account details',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PersonalInformationPage(),
                            ),
                          );

                          loadProfile();
                        },
                      ),

                      MenuTile(
                        icon: Icons.bookmark_border,
                        title: 'My Collections',
                        subtitle: 'View and manage your collections',
                        onTap: widget.onOpenCollections,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7DADA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout, color: Color(0xFFD85C5C)),
                    ),
                    title: Text(
                      loggingOut ? 'Logging Out...' : 'Log Out',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD85C5C),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: logout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// PERSONAL INFORMATION PAGE
// ===============================================================

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final supabase = Supabase.instance.client;
  final picker = ImagePicker();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  String? avatarUrl;
  XFile? selectedImage;

  bool loading = true;
  bool saving = false;
  bool uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final profile = await supabase
        .from('profiles')
        .select('username, avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    if (!mounted) return;

    usernameController.text = profile?['username'] ?? '';
    emailController.text = user.email ?? '';
    avatarUrl = profile?['avatar_url'];

    setState(() => loading = false);
  }

  Future<void> choosePhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Change Profile Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF49784D),
                  ),
                  title: Text(
                    'Take Photo',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF49784D),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null) return;

      setState(() {
        selectedImage = image;
        uploadingPhoto = true;
      });

      final extension = image.path.split('.').last;
      final filePath =
          '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final file = File(image.path);

      await supabase.storage
          .from('avatars')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600'),
          );

      final url = supabase.storage.from('avatars').getPublicUrl(filePath);

      await supabase
          .from('profiles')
          .update({'avatar_url': url})
          .eq('id', user.id);

      if (!mounted) return;

      setState(() {
        avatarUrl = url;
        selectedImage = null;
        uploadingPhoto = false;
      });

      showMessage('Profile photo updated');
    } catch (e) {
      debugPrint('Upload error: $e');

      if (!mounted) return;

      setState(() => uploadingPhoto = false);

      showMessage('Unable to upload photo', error: true);
    }
  }

  Future<void> saveChanges() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    setState(() => saving = true);

    try {
      await supabase
          .from('profiles')
          .update({'username': usernameController.text.trim()})
          .eq('id', user.id);

      if (!mounted) return;

      showMessage('Profile updated');
    } catch (e) {
      showMessage('Unable to update profile', error: true);
    }

    if (mounted) {
      setState(() => saving = false);
    }
  }

  Future<void> changePassword() async {
    final controller = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Change Password',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (password == null || password.length < 6) return;

    await supabase.auth.updateUser(UserAttributes(password: password));

    if (!mounted) return;

    showMessage('Password updated');
  }

  void showMessage(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error
            ? const Color(0xFFD85C5C)
            : const Color(0xFF49784D),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg2.png', fit: BoxFit.cover),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const PageHeader(
                    title: 'Personal Information',
                    subtitle: 'Manage your account details',
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: loading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Column(
                            children: [
                              GestureDetector(
                                onTap: choosePhoto,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    AvatarWidget(
                                      size: 72,
                                      avatarUrl: selectedImage != null
                                          ? null
                                          : avatarUrl,
                                      localFile: selectedImage != null
                                          ? File(selectedImage!.path)
                                          : null,
                                    ),

                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF49784D),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              GestureDetector(
                                onTap: choosePhoto,
                                child: Text(
                                  uploadingPhoto
                                      ? 'Uploading...'
                                      : 'Change Photo',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              InputField(
                                label: 'Username',
                                icon: Icons.person_outline,
                                controller: usernameController,
                              ),

                              const SizedBox(height: 15),

                              InputField(
                                label: 'Email',
                                icon: Icons.mail_outline,
                                controller: emailController,
                                readOnly: true,
                              ),

                              const SizedBox(height: 15),

                              PasswordField(onChange: changePassword),

                              const SizedBox(height: 26),

                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: saving ? null : saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF49784D),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: saving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Save Changes',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// AVATAR
// ===============================================================

class AvatarWidget extends StatelessWidget {
  final double size;
  final String? avatarUrl;
  final File? localFile;

  const AvatarWidget({
    super.key,
    required this.size,
    this.avatarUrl,
    this.localFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE4EDE0),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: localFile != null
            ? Image.file(localFile!, fit: BoxFit.cover)
            : avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF49784D),
                    size: 30,
                  );
                },
              )
            : Icon(
                Icons.person_rounded,
                color: const Color(0xFF49784D),
                size: size * .5,
              ),
      ),
    );
  }
}

// ===============================================================
// MENU TILE
// ===============================================================

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFDCE8D8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF49784D)),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
      ),
    );
  }
}

// ===============================================================
// INPUT FIELD
// ===============================================================

class InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool readOnly;

  const InputField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(0, 0, 0, 0.22);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8D8),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: const Color(0xFF49784D), size: 19),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                style: GoogleFonts.poppins(fontSize: 10),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(0, 0, 0, 0.35),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ===============================================================
// PASSWORD FIELD
// ===============================================================

class PasswordField extends StatelessWidget {
  final VoidCallback onChange;

  const PasswordField({super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(0, 0, 0, 0.22);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8D8),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Color(0xFF49784D),
                size: 19,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '••••••••',
                        style: GoogleFonts.poppins(fontSize: 10),
                      ),
                    ),

                    TextButton(
                      onPressed: onChange,
                      child: Text(
                        'Change',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF49784D),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
