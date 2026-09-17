import 'package:flutter/material.dart';
import 'package:saturn_app/models/account_data.dart';
import 'package:saturn_app/services/account_service.dart';
import 'package:saturn_app/services/api_client.dart';
import 'package:saturn_app/theme/colors.dart';
import 'package:saturn_app/widgets/app_card.dart';
import 'package:saturn_app/widgets/async_view.dart';
import 'package:saturn_app/widgets/bottom_nav_bar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _service = AccountService();
  late Future<AccountData> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAccountData();
  }

  void _reload() {
    setState(() {
      _future = _service.getAccountData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.gold),
              onSelected: (value) async {
                if (value == 'logout') {
                  final client = ApiClient();
                  try {
                    await client.post('/logout');
                  } catch (_) {

                  }
                  
                  await client.deleteToken();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/welcome', // or '/login'
                    (route) => false,
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('LogOut', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.slate,
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Verification'),
              Tab(text: 'Bank'),
              Tab(text: 'Security'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        bottomNavigationBar: const SaturnBottomNav(currentIndex: 4),
        body: AsyncView<AccountData>(
          future: _future,
          onRetry: _reload,
          builder: (context, data) => TabBarView(
            children: [
              _ProfileTab(data: data, onSaved: _reload),
              _VerificationTab(data: data, onUpdated: _reload),
              _BankTab(data: data, onUpdated: _reload),
              _SecurityTab(data: data, onUpdated: _reload),
              _DocumentsTab(documents: data.documents),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PROFILE TAB ---
class _ProfileTab extends StatefulWidget {
  final AccountData data;
  final VoidCallback onSaved;

  const _ProfileTab({required this.data, required this.onSaved});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _service = AccountService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  String? _selectedCountry;

  bool _isSubmitting = false;

  final List<String> _countries = ['Romania', 'Italy', 'France', 'Spain', 'Other'];

  @override
  void initState() {
    super.initState();
    final u = widget.data.user;
    _nameController = TextEditingController(text: u.name);
    _emailController = TextEditingController(text: u.email);
    _phoneController = TextEditingController(text: u.phone ?? '');
    _dobController = TextEditingController(text: u.dob ?? '');
    _addressController = TextEditingController(text: u.address ?? '');
    _selectedCountry = _countries.contains(u.country) ? u.country : 'Romania';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await _service.updateProfile({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'country': _selectedCountry,
        'address': _addressController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.data.user;
    final initial = u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.gold.withOpacity(0.2),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(u.email, style: const TextStyle(color: AppColors.slate, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Member since ${u.createdAt}', style: const TextStyle(color: AppColors.slate, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: u.kycStatus == 'verified' ? AppColors.green.withOpacity(0.15) : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  u.kycStatus[0].toUpperCase() + u.kycStatus.substring(1),
                  style: TextStyle(
                    color: u.kycStatus == 'verified' ? AppColors.green : AppColors.slate,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Personal information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _buildField('Full name', _nameController, required: true),
                _buildField('Email address', _emailController, required: true, isEmail: true),
                _buildField('Phone number', _phoneController, hint: '+40 7xx xxx xxx'),
                _buildField('Date of birth', _dobController, hint: 'YYYY-MM-DD'),
                const Text('Country of residence', style: TextStyle(fontSize: 12, color: AppColors.slate, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  dropdownColor: AppColors.cardBorder,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(''),
                  items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedCountry = val),
                ),
                const SizedBox(height: 16),
                _buildField('Address', _addressController, hint: 'Street, city, postal code'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                    onPressed: _isSubmitting ? null : _saveProfile,
                    child: _isSubmitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool required = false, bool isEmail = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(hint ?? ''),
            validator: (val) {
              if (required && (val == null || val.trim().isEmpty)) return 'This field is required';
              return null;
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.slate),
      filled: true,
      fillColor: Colors.black26,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.cardBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.cardBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.gold)),
    );
  }
}

// --- VERIFICATION TAB ---
class _VerificationTab extends StatelessWidget {
  final AccountData data;
  final VoidCallback onUpdated;

  const _VerificationTab({required this.data, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    final u = data.user;
    int verifiedSteps = (u.identityVerified ? 1 : 0) + (u.addressVerified ? 1 : 0) + (u.selfieVerified ? 1 : 0);
    double progress = verifiedSteps / 3.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verification ${progress == 1.0 ? "Level 2" : "Level 1"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        progress == 1.0 ? 'You can invest up to €50,000 per calendar year' : 'Complete verification.',
                        style: const TextStyle(color: AppColors.slate, fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: progress == 1.0 ? AppColors.green.withOpacity(0.15) : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      progress == 1.0 ? 'Verified' : 'In Progress',
                      style: TextStyle(color: progress == 1.0 ? AppColors.green : AppColors.slate, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.cardBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verification steps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildStepRow('Identity document', 'Passport or national ID', u.identityVerified),
              const Divider(color: AppColors.cardBorder),
              _buildStepRow('Proof of address', 'Utility bill or bank statement', u.addressVerified),
              const Divider(color: AppColors.cardBorder),
              _buildStepRow('Selfie verification', 'Live photo match', u.selfieVerified),
              const Divider(color: AppColors.cardBorder),
              _buildAccreditationRow(context, u.accreditedInvestor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(String title, String subtitle, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: AppColors.slate, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified ? AppColors.green.withOpacity(0.15) : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isVerified ? 'Verified' : 'Pending',
              style: TextStyle(color: isVerified ? AppColors.green : AppColors.slate, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAccreditationRow(BuildContext context, bool isAccredited) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accredited investor status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('Unlocks higher annual investment limits', style: TextStyle(color: AppColors.slate, fontSize: 12)),
            ],
          ),
          if (isAccredited)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: const Text('Verified', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), foregroundColor: AppColors.gold),
              onPressed: () async {
                await AccountService().requestAccreditation();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accreditation requested.')));
                onUpdated();
              },
              child: const Text('Request', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

// --- BANK TAB ---
class _BankTab extends StatelessWidget {
  final AccountData data;
  final VoidCallback onUpdated;

  const _BankTab({required this.data, required this.onUpdated});

  void _showAddBankModal(BuildContext context) {
    final bankNameCtrl = TextEditingController();
    final ibanCtrl = TextEditingController();
    String currency = 'EUR';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Bank Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            TextField(controller: bankNameCtrl, decoration: const InputDecoration(labelText: 'Bank Name', hintText: 'e.g. Revolut, ING, BCR')),
            const SizedBox(height: 12),
            TextField(controller: ibanCtrl, decoration: const InputDecoration(labelText: 'IBAN', hintText: 'RO49 RNCB 0000 0000 0000 0000')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: currency,
              items: ['EUR', 'RON', 'USD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => currency = v ?? 'EUR',
              decoration: const InputDecoration(labelText: 'Currency'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                  onPressed: () async {
                    await AccountService().addBankAccount({
                      'bank_name': bankNameCtrl.text,
                      'iban': ibanCtrl.text,
                      'currency': currency,
                    });
                    Navigator.pop(ctx);
                    onUpdated();
                  },
                  child: const Text('Save Account'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showWithdrawModal(BuildContext context) {
    if (data.bankAccounts.isEmpty) return;
    int selectedBankId = data.bankAccounts.first.id;
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedBankId,
              items: data.bankAccounts.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.bankName} (${b.maskedIban})'))).toList(),
              onChanged: (v) => selectedBankId = v!,
              decoration: const InputDecoration(labelText: 'Destination Bank'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Amount (€)', hintText: '100.00 (Max: €${data.user.balance.toStringAsFixed(2)})'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                  onPressed: () async {
                    await AccountService().withdrawFunds({
                      'bank_account_id': selectedBankId,
                      'amount': double.tryParse(amountCtrl.text) ?? 0,
                    });
                    Navigator.pop(ctx);
                    onUpdated();
                  },
                  child: const Text('Confirm Withdrawal'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Linked bank accounts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), foregroundColor: AppColors.gold),
                    onPressed: () => _showAddBankModal(context),
                    child: const Text('Add bank account', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (data.bankAccounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No bank accounts linked yet. Click "Add bank account" above to connect your bank.', style: TextStyle(color: AppColors.slate, fontSize: 13)),
                )
              else
                ...data.bankAccounts.map((b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.bankName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('${b.maskedIban} · ${b.currency}', style: const TextStyle(color: AppColors.slate, fontSize: 12)),
                            ],
                          ),
                          if (b.isPrimary)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Primary', style: TextStyle(fontSize: 11, color: AppColors.slate)),
                            ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Withdrawals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                'Withdrawals are sent to your verified primary bank account and typically arrive within 1–3 business days. Available cash: €${data.user.balance.toStringAsFixed(2)}.',
                style: const TextStyle(color: AppColors.slate, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                onPressed: (data.bankAccounts.isNotEmpty && data.user.balance > 0) ? () => _showWithdrawModal(context) : null,
                child: const Text('Withdraw funds'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- SECURITY TAB ---
class _SecurityTab extends StatefulWidget {
  final AccountData data;
  final VoidCallback onUpdated;

  const _SecurityTab({required this.data, required this.onUpdated});

  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  bool _twoFactorEnabled = true;

  Future<void> _updatePassword() async {
    try {
      await AccountService().updatePassword({
        'current_password': _currentPwdCtrl.text,
        'new_password': _newPwdCtrl.text,
        'new_password_confirmation': _confirmPwdCtrl.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully.')));
        _currentPwdCtrl.clear();
        _newPwdCtrl.clear();
        _confirmPwdCtrl.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Change password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(controller: _currentPwdCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Current password')),
              const SizedBox(height: 10),
              TextField(controller: _newPwdCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
              const SizedBox(height: 10),
              TextField(controller: _confirmPwdCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm new password')),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                onPressed: _updatePassword,
                child: const Text('Update password'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: SwitchListTile(
            title: const Text('Two-factor authentication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: const Text('Require a code from your authenticator app when logging in', style: TextStyle(color: AppColors.slate, fontSize: 12)),
            value: _twoFactorEnabled,
            activeColor: AppColors.gold,
            onChanged: (val) => setState(() => _twoFactorEnabled = val),
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Active sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ...widget.data.sessions.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(s.userAgent, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  if (s.isCurrent)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                      child: const Text('This device', style: TextStyle(color: AppColors.green, fontSize: 10)),
                                    ),
                                ],
                              ),
                              Text('IP: ${s.ipAddress}', style: const TextStyle(color: AppColors.slate, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (!s.isCurrent)
                          TextButton(
                            onPressed: () async {
                              await AccountService().logoutSession(s.id);
                              widget.onUpdated();
                            },
                            child: const Text('Log out', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                          ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// --- DOCUMENTS TAB ---
class _DocumentsTab extends StatelessWidget {
  final List<UserDocument> documents;

  const _DocumentsTab({required this.documents});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Document', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('')),
              ],
              rows: documents
                  .map(
                    (d) => DataRow(
                      cells: [
                        DataCell(Text(d.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text(d.type, style: const TextStyle(color: AppColors.slate))),
                        DataCell(Text(d.date, style: const TextStyle(color: AppColors.slate))),
                        DataCell(
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.cardBorder)),
                            onPressed: () {},
                            child: const Text('Download', style: TextStyle(fontSize: 11, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}