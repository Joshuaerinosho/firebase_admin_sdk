import 'package:firebase_admin_sdk/firebase_admin.dart';
import 'package:http/http.dart';

import '../app.dart';

class AuthorizedHttpClient extends BaseClient {
  final App app;

  final Duration timeout;

  final Client client = Client();

  AuthorizedHttpClient(this.app, this.timeout);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final AccessToken accessTokenObj = await app.internals.getToken();

    request.headers['Authorization'] = 'Bearer ${accessTokenObj.accessToken}';

    return client.send(request).timeout(timeout);
  }
}
