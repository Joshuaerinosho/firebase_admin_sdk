import 'package:clock/clock.dart';
import 'package:firebase_admin_sdk/src/auth/credential.dart';
import 'package:firebase_admin_sdk/src/auth/token_verifier.dart';
import 'package:firebase_admin_sdk/src/credential.dart';
import 'package:firebase_admin_sdk/firebase_admin.dart';
import 'package:firebase_admin_sdk/src/testing.dart';
import 'package:jose/jose.dart';

export 'firebase_admin.dart';

extension FirebaseAdminTestingX on FirebaseAdmin {
  Credential testCredentials() {
    return ServiceAccountMockCredential();
  }

  void setupTesting() {
    FirebaseTokenVerifier.factory = (app) => MockTokenVerifier(app);
    return setApplicationDefaultCredential(testCredentials());
  }

  String generateMockIdToken({
    required String projectId,
    required String uid,
    Map<String, dynamic>? overrides,
  }) {
    overrides ??= {};

    final ServiceAccountCredential certificateObject =
        Credentials.applicationDefault() as ServiceAccountCredential;

    final Map<String, dynamic> claims = {
      'aud': projectId,
      'exp': clock.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      'iss': 'https://securetoken.google.com/$projectId',
      'sub': uid,
      'auth_time': clock.now().millisecondsSinceEpoch ~/ 1000,
      ...overrides,
    };

    final JsonWebSignatureBuilder builder = JsonWebSignatureBuilder()
      ..jsonContent = claims
      ..setProtectedHeader(
        'kid',
        certificateObject.certificate.privateKey.keyId,
      )
      ..addRecipient(
        certificateObject.certificate.privateKey,
        algorithm: 'RS256',
      );

    return builder.build().toCompactSerialization();
  }
}
