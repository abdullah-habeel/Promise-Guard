import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '364103523068-28qhkl7fqq73oqp61gthko4j9leeustd.apps.googleusercontent.com',
);

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = 'Google sign-in failed. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
        Get.offAllNamed(AppRoutes.home);
      } else {
        errorMessage.value = e.message ?? 'Sign in failed. Try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void continueAsGuest() {
    Get.offAllNamed(AppRoutes.home);
  }
}