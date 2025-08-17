import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/services/entity_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PartiesProvider with ChangeNotifier {
  final EntityRepositoryService _repository;
  List<AddParty> _parties = [];
  List<AddParty> _cachedParties = [];
  String _searchQuery = '';
  TransactionStatus? _selectedFilter;
  bool _isOnline = true;
  bool _isLoading = true;
  String? _error;

  // Form controllers
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final openingCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  // Form state
  bool isCreditInfoSelected = true;
  bool toReceive = true;

  PartiesProvider(this._repository) {
    _initializeData();
    _checkConnectivity();
  }

  List<AddParty> get parties => _filteredParties;
  String get searchQuery => _searchQuery;
  TransactionStatus? get selectedFilter => _selectedFilter;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AddParty> get _filteredParties {
    List<AddParty> filtered = _parties;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (party) =>
                party.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                party.phone.contains(_searchQuery) ||
                party.email.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply status filter
    if (_selectedFilter != null) {
      filtered = filtered
          .where((party) => party.status == _selectedFilter)
          .toList();
    }

    return filtered;
  }

  void toggleCreditInfo(bool value) {
    isCreditInfoSelected = value;
    notifyListeners();
  }

  void toggleReceiveGive(bool value) {
    toReceive = value;
    notifyListeners();
  }

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      dateCtrl.text = DateFormat.yMMMd().format(pickedDate);
      notifyListeners();
    }
  }

  void clearForm() {
    nameCtrl.clear();
    phoneCtrl.clear();
    emailCtrl.clear();
    addressCtrl.clear();
    openingCtrl.clear();
    dateCtrl.clear();
    isCreditInfoSelected = true;
    toReceive = true;
    notifyListeners();
  }

  Future<bool> saveEntity(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) return false;

      // Convert empty strings to default values
      final name = nameCtrl.text.trim();
      final phone = phoneCtrl.text.trim();
      final email = emailCtrl.text.trim();
      final address = addressCtrl.text.trim();
      final openingBalance = openingCtrl.text.trim();
      final date = dateCtrl.text.trim();

      if (name.isEmpty) {
        throw 'Party name is required';
      }

      await _repository.addEntity(
        name: name,
        phone: phone.isEmpty ? 'N/A' : phone,
        email: email.isEmpty ? 'N/A' : email,
        address: address.isEmpty ? 'N/A' : address,
        openingBalance: openingBalance.isEmpty ? '0' : openingBalance,
        date: date.isEmpty ? DateFormat.yMMMd().format(DateTime.now()) : date,
        isCreditInfoSelected: isCreditInfoSelected,
        toReceive: toReceive,
        category: '',
      );

      clearForm();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      debugPrint('Save entity error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    // Dispose all controllers when provider is disposed
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    openingCtrl.dispose();
    dateCtrl.dispose();
    super.dispose();
  }

  void _initializeData() {
    _loadCachedData();
    _repository.listenToEntities().listen(
      (parties) {
        _parties = parties;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        if (_parties.isEmpty) {
          _parties = _cachedParties;
        }
        notifyListeners();
      },
    );
  }

  // Future<void> _loadCachedData() async {
  //   try {
  //     _cachedParties = await _repository.getCachedEntities();
  //     if (_parties.isEmpty) {
  //       _parties = _cachedParties;
  //       _isLoading = false;
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     print('Error loading cached data: $e');
  //   }
  // }

  Future<void> _checkConnectivity() async {
    _isOnline = await _repository.isOnline();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(TransactionStatus? status) {
    _selectedFilter = status;
    notifyListeners();
  }

  Future<void> deleteParty(String id) async {
    try {
      await _repository.deleteEntity(id);
    } catch (e) {
      _error = 'Failed to delete party: $e';
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check connectivity status
      await _checkConnectivity();

      if (_isOnline) {
        try {
          // Try to fetch fresh data from server
          final freshParties = await _repository.fetchEntities();
          _parties = freshParties;

          // Update cache with fresh data
          await _repository.cacheEntities(freshParties);
          _error = null;
        } catch (e) {
          debugPrint('Online refresh failed: $e');
          _error = 'Failed to fetch latest data';
          // Fall back to cached data if online fetch fails
          await _loadCachedData();
        }
      } else {
        // Offline mode - load from cache only
        await _loadCachedData();
        _error = 'Offline - showing cached data';
      }
    } catch (e) {
      debugPrint('Refresh error: $e');
      _error = 'Failed to refresh data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      _cachedParties = await _repository.getCachedEntities();
      _parties = _cachedParties;
    } catch (e) {
      debugPrint('Cache load error: $e');
      _error = 'Failed to load cached data';
      _parties = []; // Clear parties if cache fails
      rethrow;
    }
  }

  double get totalToReceive {
    return _parties
        .where((party) => party.status == TransactionStatus.toReceive)
        .fold(0.0, (sum, party) => sum + party.openingBalance);
  }

  double get totalToGive {
    return _parties
        .where((party) => party.status == TransactionStatus.toGive)
        .fold(0.0, (sum, party) => sum + party.openingBalance);
  }

  Future<DateTime?> getLastSyncTime() async {
    return await _repository.getLastSyncTime();
  }
}
