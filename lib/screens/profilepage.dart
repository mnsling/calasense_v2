// lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/pageheader.dart';
import 'signinpage.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onOpenCollections;

  const ProfilePage({super.key, this.onOpenCollections});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const double pagePadding = 24.0;

  final SupabaseClient _supabase = Supabase.instance.client;

  String _username = 'User';
  String _email = '';
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _username = 'User';
          _email = '';
          _isLoading = false;
        });

        return;
      }

      final profile = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      final username = profile?['username']?.toString().trim();

      setState(() {
        _username = username != null && username.isNotEmpty ? username : 'User';

        _email = user.email ?? '';

        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading profile: $error');

      if (!mounted) return;

      final user = _supabase.auth.currentUser;

      setState(() {
        _username = 'User';
        _email = user?.email ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _supabase.auth.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (route) => false,
      );
    } catch (error) {
      debugPrint('Logout error: $error');

      if (!mounted) return;

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/bg2.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),

        // =====================================================
        // PAGE CONTENT
        // =====================================================
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              pagePadding,
              28,
              pagePadding,
              35,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // SHARED HEADER
                // =================================================
                const PageHeader(
                  title: 'My Profile',
                  subtitle:
                      'Manage your account and\n'
                      'preferences.',
                ),

                const SizedBox(height: 28),

                // =================================================
                // USER CARD
                // =================================================
                _ProfileCard(
                  username: _username,
                  email: _email,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 14),

                // =================================================
                // MENU CARD
                // =================================================
                Container(
                  width: double.infinity,
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
                      _ProfileMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Information',
                        subtitle: 'Update your account details',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PersonalInformationPage(),
                            ),
                          );
                        },
                      ),

                      _ProfileMenuItem(
                        icon: Icons.bookmark_border_rounded,
                        title: 'My Collections',
                        subtitle: 'View and manage your collections',
                        onTap: widget.onOpenCollections,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // =================================================
                // LOGOUT CARD
                // =================================================
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: _isLoggingOut ? null : _logout,
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7DADA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFD85C5C),
                              size: 20,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Text(
                            _isLoggingOut ? 'Logging Out...' : 'Log Out',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD85C5C),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// =============================================================
// PROFILE CARD
// =============================================================

class _ProfileCard extends StatelessWidget {
  final String username;
  final String email;
  final bool isLoading;

  const _ProfileCard({
    required this.username,
    required this.email,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Generic avatar because signup currently
          // does not contain a profile image.
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFE4EDE0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF49784D),
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF49784D),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF315B34),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// PROFILE MENU ITEM
// =============================================================

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE8D8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF49784D), size: 20),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// PERSONAL INFORMATION PAGE
// =============================================================

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState
    extends State<PersonalInformationPage> {
  static const double pagePadding = 24.0;

  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  String _originalUsername = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // =============================================================
  // LOAD PROFILE DATA
  // =============================================================

  Future<void> _loadProfile() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        return;
      }

      final profile = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      final username =
          profile?['username']?.toString().trim() ?? '';

      _usernameController.text = username;
      _emailController.text = user.email ?? '';

      _originalUsername = username;

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      debugPrint(
        'Error loading personal information: $error',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // =============================================================
  // SAVE USERNAME
  // =============================================================

  Future<void> _saveChanges() async {
    final user = _supabase.auth.currentUser;

    if (user == null || _isSaving) return;

    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      _showMessage(
        'Username cannot be empty.',
        isError: true,
      );
      return;
    }

    if (username.length < 3) {
      _showMessage(
        'Username must be at least 3 characters.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _supabase
          .from('profiles')
          .update({
            'username': username,
          })
          .eq('id', user.id);

      if (!mounted) return;

      _originalUsername = username;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Profile updated successfully.',
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      if (error.code == '23505') {
        _showMessage(
          'That username is already taken.',
          isError: true,
        );
      } else {
        _showMessage(
          'Unable to update profile.',
          isError: true,
        );
      }

      debugPrint('Profile update error: $error');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Unable to update profile.',
        isError: true,
      );

      debugPrint('Profile update error: $error');
    }
  }

  // =============================================================
  // CHANGE PASSWORD
  // =============================================================

  Future<void> _showChangePasswordDialog() async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController =
        TextEditingController();

    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    bool isUpdatingPassword = false;

    await showDialog(
      context: context,
      barrierDismissible: !isUpdatingPassword,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            Future<void> updatePassword() async {
              final newPassword =
                  newPasswordController.text.trim();

              final confirmPassword =
                  confirmPasswordController.text.trim();

              if (newPassword.isEmpty ||
                  confirmPassword.isEmpty) {
                _showMessage(
                  'Please complete both password fields.',
                  isError: true,
                );
                return;
              }

              if (newPassword.length < 6) {
                _showMessage(
                  'Password must be at least 6 characters.',
                  isError: true,
                );
                return;
              }

              if (newPassword != confirmPassword) {
                _showMessage(
                  'Passwords do not match.',
                  isError: true,
                );
                return;
              }

              setDialogState(() {
                isUpdatingPassword = true;
              });

              try {
                await _supabase.auth.updateUser(
                  UserAttributes(
                    password: newPassword,
                  ),
                );

                if (!mounted) return;

                Navigator.of(dialogContext).pop();

                _showMessage(
                  'Password updated successfully.',
                );
              } on AuthException catch (error) {
                setDialogState(() {
                  isUpdatingPassword = false;
                });

                _showMessage(
                  error.message,
                  isError: true,
                );
              } catch (error) {
                setDialogState(() {
                  isUpdatingPassword = false;
                });

                _showMessage(
                  'Unable to change password.',
                  isError: true,
                );

                debugPrint(
                  'Password update error: $error',
                );
              }
            }

            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  24,
                  22,
                  22,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF315B34),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Enter your new password below.',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 9.5,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      'New Password',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF303030),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller:
                          newPasswordController,
                      obscureText:
                          obscureNewPassword,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        hintStyle:
                            GoogleFonts.poppins(
                          color:
                              Colors.grey.shade400,
                          fontSize: 9.5,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureNewPassword =
                                  !obscureNewPassword;
                            });
                          },
                          icon: Icon(
                            obscureNewPassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                            size: 18,
                            color:
                                Colors.grey.shade500,
                          ),
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide: BorderSide(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide:
                              const BorderSide(
                            color:
                                Color(0xFF49784D),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'Confirm New Password',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF303030),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller:
                          confirmPasswordController,
                      obscureText:
                          obscureConfirmPassword,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Confirm new password',
                        hintStyle:
                            GoogleFonts.poppins(
                          color:
                              Colors.grey.shade400,
                          fontSize: 9.5,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureConfirmPassword =
                                  !obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                            size: 18,
                            color:
                                Colors.grey.shade500,
                          ),
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide: BorderSide(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide:
                              const BorderSide(
                            color:
                                Color(0xFF49784D),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isUpdatingPassword
                                    ? null
                                    : () {
                                        Navigator.pop(
                                          dialogContext,
                                        );
                                      },
                            style:
                                OutlinedButton.styleFrom(
                              minimumSize:
                                  const Size(
                                double.infinity,
                                43,
                              ),
                              foregroundColor:
                                  const Color(
                                0xFF49784D,
                              ),
                              side: const BorderSide(
                                color:
                                    Color(0xFF49784D),
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  8,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style:
                                  GoogleFonts.poppins(
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                isUpdatingPassword
                                    ? null
                                    : updatePassword,
                            style:
                                ElevatedButton.styleFrom(
                              minimumSize:
                                  const Size(
                                double.infinity,
                                43,
                              ),
                              backgroundColor:
                                  const Color(
                                0xFF49784D,
                              ),
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  8,
                                ),
                              ),
                            ),
                            child:
                                isUpdatingPassword
                                    ? const SizedBox(
                                        width: 17,
                                        height: 17,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Update',
                                        style: GoogleFonts
                                            .poppins(
                                          fontSize: 10,
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  // =============================================================
  // PROFILE PICTURE
  // =============================================================

  void _chooseProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile picture upload coming next',
        ),
      ),
    );
  }

  // =============================================================
  // MESSAGE
  // =============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFD85C5C)
            : const Color(0xFF49784D),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // =====================================================
          // BACKGROUND
          // =====================================================
          Image.asset(
            'assets/images/bg2.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          // =====================================================
          // CONTENT
          // =====================================================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                pagePadding,
                28,
                pagePadding,
                35,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // BACK BUTTON
                  // =================================================
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius:
                        BorderRadius.circular(30),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Align(
                        alignment:
                            Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =================================================
                  // HEADER
                  // =================================================
                  const PageHeader(
                    title: 'Personal Information',
                    subtitle:
                        'Manage your account details',
                  ),

                  const SizedBox(height: 28),

                  // =================================================
                  // CARD
                  // =================================================
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      24,
                      18,
                      24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.all(35),
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Color(0xFF49784D),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              // =====================================
                              // PROFILE PHOTO
                              // =====================================
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration:
                                        const BoxDecoration(
                                      color:
                                          Color(0xFFE4EDE0),
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons
                                          .person_rounded,
                                      color:
                                          Color(0xFF49784D),
                                      size: 36,
                                    ),
                                  ),

                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child:
                                        GestureDetector(
                                      onTap:
                                          _chooseProfilePicture,
                                      child: Container(
                                        width: 25,
                                        height: 25,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              const Color(
                                            0xFF49784D,
                                          ),
                                          shape:
                                              BoxShape.circle,
                                          border:
                                              Border.all(
                                            color:
                                                Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child:
                                            const Icon(
                                          Icons
                                              .camera_alt_rounded,
                                          color:
                                              Colors.white,
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              GestureDetector(
                                onTap:
                                    _chooseProfilePicture,
                                child: Text(
                                  'Change Photo',
                                  style:
                                      GoogleFonts.poppins(
                                    color: Colors
                                        .grey.shade600,
                                    fontSize: 8,
                                    fontWeight:
                                        FontWeight.w400,
                                    letterSpacing:
                                        -0.2,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // =====================================
                              // USERNAME
                              // =====================================
                              _InformationField(
                                label: 'Username',
                                icon: Icons
                                    .person_outline_rounded,
                                controller:
                                    _usernameController,
                              ),

                              const SizedBox(height: 15),

                              // =====================================
                              // EMAIL
                              // =====================================
                              _InformationField(
                                label: 'Email',
                                icon: Icons
                                    .mail_outline_rounded,
                                controller:
                                    _emailController,
                                readOnly: true,
                              ),

                              const SizedBox(height: 15),

                              // =====================================
                              // PASSWORD
                              // =====================================
                              _PasswordField(
                                onChangePassword:
                                    _showChangePasswordDialog,
                              ),

                              const SizedBox(height: 28),

                              // =====================================
                              // SAVE BUTTON
                              // =====================================
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : _saveChanges,
                                  style: ElevatedButton
                                      .styleFrom(
                                    backgroundColor:
                                        const Color(
                                      0xFF49784D,
                                    ),
                                    foregroundColor:
                                        Colors.white,
                                    disabledBackgroundColor:
                                        const Color(
                                      0xFF49784D,
                                    ).withValues(
                                      alpha: 0.6,
                                    ),
                                    elevation: 0,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(8),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2,
                                            color: Colors
                                                .white,
                                          ),
                                        )
                                      : Text(
                                          'Save Changes',
                                          style:
                                              GoogleFonts
                                                  .poppins(
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight
                                                    .w500,
                                            letterSpacing:
                                                -0.2,
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

// =============================================================
// INFORMATION FIELD
// =============================================================

class _InformationField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool readOnly;

  const _InformationField({
    required this.label,
    required this.icon,
    required this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF303030),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8D8),
                borderRadius:
                    BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 19,
                color:
                    const Color(0xFF49784D),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color:
                      const Color(0xFF333333),
                  letterSpacing: -0.2,
                ),
                decoration: InputDecoration(
                  filled: readOnly,
                  fillColor: readOnly
                      ? const Color(0xFFF8F8F8)
                      : Colors.white,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(
                      color:
                          Color(0xFF49784D),
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

// =============================================================
// PASSWORD FIELD
// =============================================================

class _PasswordField extends StatelessWidget {
  final VoidCallback onChangePassword;

  const _PasswordField({
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.poppins(
            color: const Color(0xFF303030),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8D8),
                borderRadius:
                    BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 19,
                color: Color(0xFF49784D),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Container(
                height: 38,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius:
                      BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '••••••••',
                        style:
                            GoogleFonts.poppins(
                          color: const Color(
                            0xFF333333,
                          ),
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap:
                          onChangePassword,
                      child: Text(
                        'Change',
                        style:
                            GoogleFonts.poppins(
                          color: const Color(
                            0xFF49784D,
                          ),
                          fontSize: 8.5,
                          fontWeight:
                              FontWeight.w500,
                          letterSpacing: -0.2,
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