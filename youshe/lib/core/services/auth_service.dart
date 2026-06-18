import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants.dart';
import '../services/logging_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LoggingService _log = LoggingService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _log.info('User signed in', tag: 'AuthService');
      return result;
    } catch (e) {
      _log.error('Sign in failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<UserCredential> signUp(String email, String password, String name, UserRole role) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await result.user?.updateDisplayName(name);
      await _firestore.collection(FirestoreCollections.users).doc(result.user!.uid).set({
        'email': email.trim(),
        'name': name,
        'role': role.value,
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _log.info('User signed up', tag: 'AuthService');
      return result;
    } catch (e) {
      _log.error('Sign up failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      await _ensureUserDoc(result.user!);
      _log.info('User signed in with Google', tag: 'AuthService');
      return result;
    } catch (e) {
      _log.error('Google sign-in failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<UserCredential> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      await _ensureUserDoc(result.user!);
      _log.info('User signed in anonymously', tag: 'AuthService');
      return result;
    } catch (e) {
      _log.error('Anonymous sign-in failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<void> _ensureUserDoc(User user) async {
    final docRef = _firestore.collection(FirestoreCollections.users).doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'role': UserRole.customer.value,
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _log.info('Created Firestore user doc for ${user.uid}', tag: 'AuthService');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _log.info('User signed out', tag: 'AuthService');
  }

  Future<UserRole> getUserRole(String uid) async {
    final doc = await _firestore.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) return UserRole.customer;
    return UserRoleExt.fromString(doc.data()!['role'] as String);
  }

  Stream<DocumentSnapshot> userStream(String uid) {
    return _firestore.collection(FirestoreCollections.users).doc(uid).snapshots();
  }

  Future<void> updateUserField(String uid, String field, dynamic value) async {
    await _firestore.collection(FirestoreCollections.users).doc(uid).update({field: value});
  }
}
