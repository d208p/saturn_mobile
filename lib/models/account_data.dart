class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? dob;
  final String? country;
  final String? address;
  final String createdAt;
  final String kycStatus;
  final double balance;
  final bool identityVerified;
  final bool addressVerified;
  final bool selfieVerified;
  final bool accreditedInvestor;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.dob,
    this.country,
    this.address,
    required this.createdAt,
    required this.kycStatus,
    required this.balance,
    required this.identityVerified,
    required this.addressVerified,
    required this.selfieVerified,
    required this.accreditedInvestor,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      dob: json['dob'],
      country: json['country'],
      address: json['address'],
      createdAt: json['created_at'] ?? '',
      kycStatus: json['kyc_status'] ?? 'unverified',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      identityVerified: json['identity_verified'] ?? false,
      addressVerified: json['address_verified'] ?? false,
      selfieVerified: json['selfie_verified'] ?? false,
      accreditedInvestor: json['accredited_investor'] ?? false,
    );
  }
}

class UserBankAccount {
  final int id;
  final String bankName;
  final String maskedIban;
  final String currency;
  final bool isPrimary;

  UserBankAccount({
    required this.id,
    required this.bankName,
    required this.maskedIban,
    required this.currency,
    required this.isPrimary,
  });

  factory UserBankAccount.fromJson(Map<String, dynamic> json) {
    return UserBankAccount(
      id: json['id'],
      bankName: json['bank_name'] ?? '',
      maskedIban: json['masked_iban'] ?? '',
      currency: json['currency'] ?? 'EUR',
      isPrimary: json['is_primary'] ?? false,
    );
  }
}

class UserSession {
  final String id;
  final String userAgent;
  final String ipAddress;
  final int lastActivity;
  final bool isCurrent;

  UserSession({
    required this.id,
    required this.userAgent,
    required this.ipAddress,
    required this.lastActivity,
    required this.isCurrent,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'].toString(),
      userAgent: json['user_agent'] ?? 'Unknown Device',
      ipAddress: json['ip_address'] ?? '0.0.0.0',
      lastActivity: json['last_activity'] ?? 0,
      isCurrent: json['is_current'] ?? false,
    );
  }
}

class UserDocument {
  final String title;
  final String type;
  final String date;

  UserDocument({required this.title, required this.type, required this.date});

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class AccountData {
  final UserProfile user;
  final List<UserBankAccount> bankAccounts;
  final List<UserSession> sessions;
  final List<UserDocument> documents;

  AccountData({
    required this.user,
    required this.bankAccounts,
    required this.sessions,
    required this.documents,
  });
}