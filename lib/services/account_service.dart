import 'package:saturn_app/models/account_data.dart';
import 'package:saturn_app/services/api_client.dart';

class AccountService {
  final ApiClient _client = ApiClient();

  Future<AccountData> getAccountData() async {
    final res = await _client.get('/account');
    final json = res as Map<String, dynamic>;

    return AccountData(
      user: UserProfile.fromJson(json['user']),
      bankAccounts: (json['bank_accounts'] as List? ?? [])
          .map((b) => UserBankAccount.fromJson(b))
          .toList(),
      sessions: (json['sessions'] as List? ?? [])
          .map((s) => UserSession.fromJson(s))
          .toList(),
      documents: (json['documents'] as List? ?? [])
          .map((d) => UserDocument.fromJson(d))
          .toList(),
    );
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _client.put('/account/profile', body: data);
  }

  Future<void> updatePassword(Map<String, dynamic> data) async {
    await _client.put('/account/password', body: data);
  }

  Future<void> addBankAccount(Map<String, dynamic> data) async {
    await _client.post('/account/bank', body: data);
  }

  Future<void> withdrawFunds(Map<String, dynamic> data) async {
    await _client.post('/account/withdraw', body: data);
  }

  Future<void> requestAccreditation() async {
    await _client.post('/account/accreditation');
  }

  Future<void> logoutSession(String sessionId) async {
    await _client.delete('/account/sessions/$sessionId');
  }
}