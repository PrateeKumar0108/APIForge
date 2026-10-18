import 'package:flutter_test/flutter_test.dart';
import 'package:apiforge/core/networking/request_models.dart';
import 'package:apiforge/features/environments/domain/services/variable_substitution_engine.dart';

void main() {
  group('VariableSubstitutionEngine', () {
    test('substitutes {{variables}} in string templates', () {
      final template = 'https://{{host}}:{{port}}/api/{{version}}/users';
      final vars = {'host': 'api.example.com', 'port': '8443', 'version': 'v2'};

      final result = VariableSubstitutionEngine.substitute(template, vars);

      expect(result, equals('https://api.example.com:8443/api/v2/users'));
    });

    test('preserves unmatched {{variable}} placeholders', () {
      final template = 'https://{{host}}/items/{{itemId}}';
      final vars = {'host': 'api.example.com'};

      final result = VariableSubstitutionEngine.substitute(template, vars);

      expect(result, equals('https://api.example.com/items/{{itemId}}'));
    });

    test('finds unresolved variables in template', () {
      final template = '{{baseUrl}}/users/{{userId}}?token={{authToken}}';
      final vars = {'baseUrl': 'https://api.example.com', 'userId': '123'};

      final unresolved = VariableSubstitutionEngine.findUnresolvedVariables(
        template,
        vars,
      );

      expect(unresolved, equals(['authToken']));
    });

    test(
      'applies variable precedence: request overrides environment and workspace defaults',
      () {
        final request = HttpRequestData(
          method: 'GET',
          url: '{{baseUrl}}/status',
          headers: [KeyValuePair(key: 'X-App-Env', value: '{{envName}}')],
          queryParams: [KeyValuePair(key: 'limit', value: '{{defaultLimit}}')],
        );

        final workspaceDefaults = {
          'baseUrl': 'http://localhost:3000',
          'envName': 'local',
          'defaultLimit': '20',
        };

        final environmentVariables = {
          'baseUrl': 'https://production.api.com',
          'envName': 'production',
        };

        final requestVariables = {
          'baseUrl': 'https://request.local',
          'envName': 'request-local',
          'defaultLimit': '7',
        };

        final result = VariableSubstitutionEngine.substituteRequest(
          request: request,
          requestVariables: requestVariables,
          environmentVariables: environmentVariables,
          workspaceDefaults: workspaceDefaults,
        );

        expect(result.request.url, equals('https://request.local/status'));
        expect(result.request.headers.first.value, equals('request-local'));
        expect(result.request.queryParams.first.value, equals('7'));
        expect(result.unresolvedVariables, isEmpty);
      },
    );

    test('interpolates JSON body content without breaking formatting', () {
      final request = HttpRequestData(
        method: 'POST',
        url: 'https://api.example.com/login',
        bodyType: BodyType.json,
        bodyContent: '{"user":"{{username}}","role":"admin"}',
      );

      final vars = {'username': 'prateek'};
      final result = VariableSubstitutionEngine.substituteRequest(
        request: request,
        environmentVariables: vars,
      );

      expect(
        result.request.bodyContent,
        equals('{"user":"prateek","role":"admin"}'),
      );
    });
  });
}
