import 'dart:convert';

import 'package:cpsumotorpooldriverapp/services/api_config.dart';
import 'package:cpsumotorpooldriverapp/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      '${ApiConfig.storageNamespace}:auth_token': 'local-test-token',
    });
  });

  test(
    'change password requests an email using only the current password',
    () async {
      var requests = 0;
      final client = MockClient((request) async {
        requests++;
        expect(request.method, 'PUT');
        expect(request.url, ApiConfig.apiUri('change-password'));
        expect(request.headers['Authorization'], 'Bearer local-test-token');
        expect(jsonDecode(request.body), {
          'current_password': 'current-secret',
        });
        return http.Response('{"message":"Check your registered email."}', 200);
      });
      await http.runWithClient(
        () => AuthService.changePassword('current-secret'),
        () => client,
      );
      expect(requests, 1);
    },
  );

  test(
    'backend rejection is exposed instead of reporting email success',
    () async {
      const message = 'The current password is incorrect.';
      await http.runWithClient(
        () async {
          await expectLater(
            AuthService.changePassword('incorrect'),
            throwsA(
              isA<AuthException>().having(
                (error) => error.message,
                'message',
                message,
              ),
            ),
          );
        },
        () => MockClient(
          (_) async => http.Response(jsonEncode({'message': message}), 422),
        ),
      );
    },
  );
}
