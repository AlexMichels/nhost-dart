import 'package:graphql/client.dart';
import 'package:nhost_dart_sdk/client.dart';
import 'package:nhost_graphql_adapter/nhost_graphql.dart';

class GqlAdminTestHelper {
  GqlAdminTestHelper(String apiUrl, String gqlUrl) {
    // Used to verify, retrieve, or clear backend state.
    client = createNhostGraphQLClient(
      gqlUrl,
      NhostClient(baseUrl: apiUrl).auth,
      defaultRequestHeaders: {
        'X-Hasura-Admin-Secret': 'hejsan',
      },
    );
  }

  GraphQLClient client;

  /// Clears the users table in the test backend
  Future<void> clearUsers() async {
    await client.mutate(clearUsersMutation);
  }

  Future<String> getChangeTicketForUser(String userId) async {
    final result = await client.query(
      QueryOptions(
        document: queryChangeTicketForUser,
        variables: {
          'userId': userId,
        },
      ),
    );
    return result.data['users'].first['account']['ticket'];
  }
}

final clearUsersMutation = MutationOptions(
  document: gql('''
    mutation clear_users {
      delete_users(where: {}) {
        affected_rows
      }
    }
  '''),
);

final queryChangeTicketForUser = gql(r'''
  query ChangeTickerForUser($userId: uuid!) {
    users(where: {id: {_eq: $userId}}) {
      account {
        ticket
      }
    }
  }
''');
