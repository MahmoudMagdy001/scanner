// ignore_for_file: avoid_classes_with_only_static_members

import 'package:get_storage/get_storage.dart';

import '../../features/login/presentation/login_view.dart';
import '../router/router.dart';
import 'user_model.dart';

abstract class AppStorage {
  static final GetStorage _box = GetStorage();

  // Safe optimization: In-memory cache for frequently accessed user info
  // Reduces storage read overhead while maintaining data consistency
  static UserModel? _cachedUserModel;

  static Future<void> init() async {
    await GetStorage.init();
  }

  static UserModel? get getUserInfo {
    // Safe optimization: Return cached value if available
    if (_cachedUserModel != null) {
      return _cachedUserModel;
    }

    UserModel? profileModel;
    if (_box.hasData('user')) {
      try {
        profileModel = UserModel.fromJson(_box.read('user'));
        _cachedUserModel = profileModel; // Cache for next access
      } catch (e) {
        // Failed to parse user info
      }
    }

    return profileModel;
  }

  static bool get isLogged => getUserInfo != null;

  static Future<void> cacheUserInfo(UserModel userModel) async {
    await _box.write('user', userModel.toJson());
    _cachedUserModel = userModel; // Update in-memory cache
  }

  static Future<void> cacheImagePath(String imagePath) async {
    await _box.write('image', imagePath);
  }

  static String? get getImagePath => _box.read('image');

  static int? get getUserId => getUserInfo?.data?.user!.id;

  static String? get getToken => getUserInfo?.data!.token;

  static User? get getUserData => getUserInfo!.data!.user!;

  // Base URL Storage
  static Future<void> cacheBaseUrl(String baseUrl) async {
    await _box.write('baseUrl', baseUrl);
  }

  static String? get getBaseUrl => _box.read('baseUrl');

  static bool get hasBaseUrl => _box.hasData('baseUrl');

  static final productsDetails = <Map>[];

  static Future<void> signOut() async {
    await _box.erase();
    _cachedUserModel = null; // Clear in-memory cache
    MagicRouter.navigateAndPopAll(const LogInView());
  }
}
