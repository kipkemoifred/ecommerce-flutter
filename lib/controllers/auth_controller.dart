import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/app_snackbar.dart';
import '../core/services/firebase_service.dart';

class AuthController extends GetxController {
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxList<UserModel> allUsers = <UserModel>[].obs;

  bool get isLoggedIn => currentUser.value != null;
  String get currentRole => currentUser.value?.role ?? AppConstants.roleCustomer;
  bool get isCustomer => currentRole == AppConstants.roleCustomer;
  bool get isSeller => currentRole == AppConstants.roleSeller;
  bool get isAdmin => currentRole == AppConstants.roleAdmin;

  @override
  void onInit() {
    super.onInit();
    _listenToFirestore();
    _checkFirebaseAuthState();
  }

  void _checkFirebaseAuthState() {
    if (FirebaseService.auth != null) {
      FirebaseService.auth!.authStateChanges().listen((user) async {
        if (user != null) {
          final doc = await FirebaseService.usersCollection?.doc(user.uid).get();
          if (doc != null && doc.exists && doc.data() != null) {
            currentUser.value = UserModel.fromMap(doc.data()!);
          } else {
            final q = await FirebaseService.usersCollection?.where('email', isEqualTo: user.email).limit(1).get();
            if (q != null && q.docs.isNotEmpty) {
              currentUser.value = UserModel.fromMap(q.docs.first.data());
            }
          }
        }
      });
    }
  }

  void _listenToFirestore() async {
    // 1. Immediate fetch from Firebase backend
    try {
      final initialUsers = await FirebaseService.fetchUsers();
      if (initialUsers.isNotEmpty) {
        allUsers.assignAll(initialUsers);
        _syncCurrentUser(initialUsers);
      }
    } catch (e) {
      debugPrint('[AuthController] Error during initial fetch: $e');
    }

    // 2. Real-time stream listeners from Firebase backend
    FirebaseService.streamUsers().listen((firestoreUsers) {
      if (firestoreUsers.isNotEmpty) {
        allUsers.assignAll(firestoreUsers);
        _syncCurrentUser(firestoreUsers);
      }
    }, onError: (e) {
      debugPrint('[AuthController] Users stream error: $e');
    });
  }

  void _syncCurrentUser(List<UserModel> users) {
    if (currentUser.value != null) {
      final refreshed = users.firstWhereOrNull((u) => u.id == currentUser.value!.id);
      if (refreshed != null) {
        currentUser.value = refreshed;
      }
    } else if (users.isNotEmpty) {
      if (FirebaseService.auth?.currentUser != null) {
        final matched = users.firstWhereOrNull((u) => u.id == FirebaseService.auth!.currentUser!.uid);
        if (matched != null) currentUser.value = matched;
      }
      currentUser.value ??= users.firstWhereOrNull((u) => u.role == AppConstants.roleCustomer) ?? users.first;
    }
  }

  Future<bool> login(String email, String password, {String? targetRole}) async {
    isLoading.value = true;
    try {
      // 1. Attempt real Firebase Authentication
      if (FirebaseService.isFirebaseConfigured && FirebaseService.auth != null) {
        try {
          final cred = await FirebaseService.auth!.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          if (cred.user != null) {
            // Fetch live user profile from Firestore
            final doc = await FirebaseService.usersCollection?.doc(cred.user!.uid).get();
            if (doc != null && doc.exists && doc.data() != null) {
              final user = UserModel.fromMap(doc.data()!);
              if (!user.isActive) {
                AppSnackbar.show(
                  'Account Suspended',
                  'Your account has been deactivated by administrator.',
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade900,
                );
                await FirebaseService.auth?.signOut();
                return false;
              }
              currentUser.value = user;
              AppSnackbar.show('Welcome Back!', 'Logged in as ${user.name} (${user.role.toUpperCase()})');
              return true;
            }
          }
        } catch (e) {
          debugPrint('[AuthController] Firebase Auth attempt: $e');
        }
      }

      // 2. Query Firestore users collection for existing user record
      if (FirebaseService.isFirebaseConfigured && FirebaseService.usersCollection != null) {
        try {
          final query = await FirebaseService.usersCollection!
              .where('email', isEqualTo: email.trim())
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            final user = UserModel.fromMap(query.docs.first.data());
            if (!user.isActive) {
              AppSnackbar.show(
                'Account Suspended',
                'Your account has been deactivated by administrator.',
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade900,
              );
              return false;
            }
            currentUser.value = user;
            AppSnackbar.show('Welcome Back!', 'Logged in as ${user.name} (${user.role.toUpperCase()})');
            return true;
          }
        } catch (e) {
          debugPrint('[AuthController] Firestore email query: $e');
        }
      }

      // 3. Check memory / local synced accounts
      UserModel? existing = allUsers.firstWhereOrNull(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      );

      if (existing != null) {
        if (!existing.isActive) {
          AppSnackbar.show(
            'Account Suspended',
            'Your account has been deactivated by administrator.',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
          return false;
        }
        currentUser.value = existing;
      } else {
        // Create user in Firestore and memory
        final role = targetRole ?? AppConstants.roleCustomer;
        final newUser = UserModel(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@').first.capitalizeFirst ?? 'User',
          email: email.trim(),
          role: role,
        );
        allUsers.add(newUser);
        currentUser.value = newUser;
        FirebaseService.saveUser(newUser);
      }

      AppSnackbar.show(
        'Welcome Back!',
        'Logged in as ${currentUser.value!.name} (${currentUser.value!.role.toUpperCase()})',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      AppSnackbar.show('Login Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? storeName,
    String? storeDescription,
  }) async {
    isLoading.value = true;
    try {
      String uid = 'user_${DateTime.now().millisecondsSinceEpoch}';

      // 1. Create in Firebase Auth if available
      if (FirebaseService.isFirebaseConfigured && FirebaseService.auth != null) {
        try {
          final userCred = await FirebaseService.auth!.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          if (userCred.user != null) {
            uid = userCred.user!.uid;
            await userCred.user!.updateDisplayName(name.trim());
          }
        } catch (e) {
          debugPrint('[AuthController] Firebase Auth createUser: $e');
        }
      }

      // 2. Create in Firestore & local state
      final newUser = UserModel(
        id: uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        storeName: storeName ?? '',
        storeDescription: storeDescription ?? '',
        isVerified: role == AppConstants.roleSeller ? false : true,
      );

      allUsers.add(newUser);
      currentUser.value = newUser;
      await FirebaseService.saveUser(newUser);

      AppSnackbar.show(
        'Registration Successful!',
        'Account created for ${newUser.name} as ${newUser.role.toUpperCase()}',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      AppSnackbar.show('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    if (FirebaseService.isFirebaseConfigured && FirebaseService.auth != null) {
      try {
        await FirebaseService.auth!.signOut();
      } catch (_) {}
    }
    currentUser.value = null;
    AppSnackbar.show(
      'Logged Out',
      'You have been logged out safely.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Quick switch role utility for evaluating all three perspectives seamlessly
  void switchDemoRole(String role) {
    final liveUser = allUsers.firstWhereOrNull((u) => u.role == role);
    if (liveUser != null) {
      currentUser.value = liveUser;
      AppSnackbar.show(
        'Switched Role',
        'Now viewing as ${currentUser.value?.name} (${role.toUpperCase()})',
        backgroundColor: Colors.indigo.shade50,
        colorText: Colors.indigo.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      AppSnackbar.show(
        'Role Not Found',
        'No user with role ${role.toUpperCase()} found.',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade900,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void toggleUserStatus(String userId) {
    final index = allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = allUsers[index];
      allUsers[index] = user.copyWith(isActive: !user.isActive);
      if (currentUser.value?.id == userId) {
        currentUser.value = allUsers[index];
      }
      FirebaseService.updateUserStatus(userId, !user.isActive);
      AppSnackbar.show(
        'User Status Updated',
        'User ${user.name} is now ${!user.isActive ? 'Active' : 'Suspended'}',
      );
    }
  }

  void verifySeller(String sellerId) {
    final index = allUsers.indexWhere((u) => u.id == sellerId);
    if (index != -1) {
      final user = allUsers[index];
      allUsers[index] = user.copyWith(isVerified: true);
      FirebaseService.updateSellerVerification(sellerId, true);
      AppSnackbar.show('Seller Verified', '${user.storeName.isNotEmpty ? user.storeName : user.name} is now a verified seller!');
    }
  }
}
