import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/services/entity_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class PartiesProvider with ChangeNotifier {
  final EntityRepositoryService _repository;

  List<AddParty> _parties = [];
  List<AddParty> _cachedParties = [];

  String _searchQuery = '';
  TransactionStatus? _selectedFilter;
  bool _isOnline = true;
  bool _isLoading = true;
  String? _error;

  // Stream subscription
  StreamSubscription<List<AddParty>>? _streamSubscription;

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
    debugPrint('🔄 PartiesProvider: Initializing...');
    _initializeData();
    _checkConnectivity();
  }

  // --- Getters ---
  List<AddParty> get parties {
    final filtered = _filteredParties;
    debugPrint(
      '📊 Provider: Getting ${filtered.length} parties (from ${_parties.length} total)',
    );
    return filtered;
  }

  String get searchQuery => _searchQuery;
  TransactionStatus? get selectedFilter => _selectedFilter;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AddParty> get _filteredParties {
    var filtered = _parties;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.phone.contains(_searchQuery) ||
                p.email.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_selectedFilter != null) {
      filtered = filtered.where((p) => p.status == _selectedFilter).toList();
    }

    return filtered;
  }

  // --- Form helpers ---
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

  // Enhanced Save Entity Method
  Future<bool> saveEntity(BuildContext context) async {
    debugPrint('💾 Provider: Starting save entity process...');

    try {
      if (!formKey.currentState!.validate()) {
        debugPrint('❌ Provider: Form validation failed');
        return false;
      }

      debugPrint('✅ Provider: Form validation passed');
      debugPrint(
        '📝 Provider: Form data - name: ${nameCtrl.text}, phone: ${phoneCtrl.text}, balance: ${openingCtrl.text}',
      );

      // Show loading indicator
      _setLoading(true);

      // Prepare AddParty object with proper date handling
      DateTime selectedDate;
      if (dateCtrl.text.isEmpty) {
        selectedDate = DateTime.now();
      } else {
        try {
          selectedDate = DateFormat.yMMMd().parse(dateCtrl.text);
        } catch (e) {
          debugPrint(
            '⚠️ Provider: Date parsing failed, using current date: $e',
          );
          selectedDate = DateTime.now();
        }
      }

      final party = AddParty(
        id: '', // Firestore will assign ID
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isEmpty ? 'N/A' : phoneCtrl.text.trim(),
        email: emailCtrl.text.trim().isEmpty ? 'N/A' : emailCtrl.text.trim(),
        address: addressCtrl.text.trim().isEmpty
            ? 'N/A'
            : addressCtrl.text.trim(),
        openingBalance: double.tryParse(openingCtrl.text.trim()) ?? 0,
        date: selectedDate,
        isCreditInfoSelected: isCreditInfoSelected,
        toReceive: toReceive,
        createdAt: DateTime.now(),
        avatarColor: AddParty.generateColor(nameCtrl.text.trim()),
        category: '',
      );

      debugPrint(
        '🎯 Provider: Party object created - ${party.name} with balance ${party.openingBalance}',
      );

      // Save using repository
      debugPrint('🚀 Provider: Calling repository addEntityFromParty...');
      await _repository.addEntityFromParty(party);

      debugPrint('✅ Provider: Repository save completed successfully');

      // Clear form after successful save
      clearForm();

      _setLoading(false);
      _error = null;

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Party added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      debugPrint('🎉 Provider: Save entity process completed successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Provider: Save entity error: $e');
      _setLoading(false);
      _error = e.toString();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    debugPrint('🔄 Provider: Disposing...');
    _streamSubscription?.cancel();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    openingCtrl.dispose();
    dateCtrl.dispose();
    super.dispose();
  }

  // Enhanced Data Initialization
  Future<void> _initializeData() async {
    debugPrint('🔄 Provider: Initializing data...');
    _setLoading(true);
    _error = null;

    // Load cached data first for immediate UI update
    await _loadCachedData();

    // Set up real-time listener
    await _setupStreamListener();
  }

  // Setup stream listener
  Future<void> _setupStreamListener() async {
    debugPrint('🎧 Provider: Setting up stream listener...');

    // Cancel existing subscription
    _streamSubscription?.cancel();

    _streamSubscription = _repository.listenToEntities().listen(
      (parties) {
        debugPrint(
          '📡 Provider: Stream update received - ${parties.length} parties',
        );

        if (parties.isNotEmpty) {
          debugPrint('Stream parties preview:');
          for (int i = 0; i < (parties.length > 3 ? 3 : parties.length); i++) {
            debugPrint('  ${i + 1}. ${parties[i].name} (${parties[i].id})');
          }
        }

        _parties = parties;
        _setLoading(false);
        _error = null;

        debugPrint(
          '✅ Provider: Updated local state with ${_parties.length} parties',
        );
        notifyListeners();
      },
      onError: (e) {
        debugPrint('❌ Provider: Stream error: $e');
        _error = e.toString();
        _setLoading(false);

        // If stream fails and we have no parties, try to use cached data
        if (_parties.isEmpty && _cachedParties.isNotEmpty) {
          debugPrint('🗂️ Provider: Using cached data as fallback');
          _parties = _cachedParties;
        }

        notifyListeners();
      },
    );
  }

  // Load cached data
  Future<void> _loadCachedData() async {
    debugPrint('📂 Provider: Loading cached data...');
    try {
      final cached = await _repository.getCachedEntities();
      debugPrint('📥 Provider: Loaded ${cached.length} entities from cache');

      if (cached.isNotEmpty) {
        _cachedParties = cached;
        _parties = cached;
        _setLoading(false);

        debugPrint('Cached parties preview:');
        for (int i = 0; i < (cached.length > 3 ? 3 : cached.length); i++) {
          debugPrint('  ${i + 1}. ${cached[i].name} (${cached[i].id})');
        }

        notifyListeners();
        debugPrint('✅ Provider: UI updated with cached data');
      } else {
        debugPrint('📭 Provider: No cached data found');
      }
    } catch (e) {
      debugPrint('❌ Provider: Cache load error: $e');
      _parties = [];
      _cachedParties = [];
      _setLoading(false);
      _error = 'Failed to load cached data: $e';
      notifyListeners();
    }
  }

  // Check connectivity
  Future<void> _checkConnectivity() async {
    debugPrint('🌐 Provider: Checking connectivity...');
    try {
      _isOnline = await _repository.isOnline();
      debugPrint('📶 Provider: Online status - $_isOnline');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Provider: Connectivity check failed: $e');
      _isOnline = false;
      notifyListeners();
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // --- Search & Filter ---
  void updateSearchQuery(String query) {
    debugPrint('🔍 Provider: Search query updated - "$query"');
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(TransactionStatus? status) {
    debugPrint('🏷️ Provider: Filter updated - $status');
    _selectedFilter = status;
    notifyListeners();
  }

  // --- Delete Party ---
  Future<void> deleteParty(String id) async {
    debugPrint('🗑️ Provider: Deleting party - $id');
    try {
      await _repository.deleteEntity(id);
      debugPrint('✅ Provider: Party deleted successfully');
    } catch (e) {
      debugPrint('❌ Provider: Delete failed: $e');
      _error = 'Failed to delete party: $e';
      notifyListeners();
    }
  }

  // --- Enhanced Refresh ---
  Future<void> refreshData() async {
    debugPrint('🔄 Provider: Refreshing data...');
    _setLoading(true);
    _error = null;

    await _checkConnectivity();

    if (_isOnline) {
      try {
        debugPrint('🌐 Provider: Fetching fresh data from server...');
        final freshParties = await _repository.fetchEntities();
        _parties = freshParties;
        _error = null;
        debugPrint(
          '✅ Provider: Fresh data loaded - ${freshParties.length} parties',
        );
      } catch (e) {
        debugPrint('❌ Provider: Online refresh failed: $e');
        _error = 'Failed to fetch latest data';
        await _loadCachedData();
      }
    } else {
      debugPrint('📱 Provider: Offline mode - loading cached data');
      await _loadCachedData();
      _error = 'Offline - showing cached data';
    }

    _setLoading(false);
    debugPrint('🏁 Provider: Refresh completed');
  }

  // --- Totals ---
  double get totalToReceive {
    return _parties
        .where((p) => p.status == TransactionStatus.toReceive)
        .fold(0.0, (sum, p) => sum + p.openingBalance);
  }

  double get totalToGive {
    return _parties
        .where((p) => p.status == TransactionStatus.toGive)
        .fold(0.0, (sum, p) => sum + p.openingBalance);
  }

  Future<DateTime?> getLastSyncTime() async {
    return await _repository.getLastSyncTime();
  }

  // Debug methods
  void debugRefresh() {
    debugPrint('🔧 Provider: Debug refresh triggered');
    refreshData();
  }

  void debugPrintState() {
    debugPrint('🔍 === Current Provider State ===');
    debugPrint('Total parties in _parties: ${_parties.length}');
    debugPrint('Total cached parties: ${_cachedParties.length}');
    debugPrint('Filtered parties count: ${parties.length}');
    debugPrint('Is loading: $_isLoading');
    debugPrint('Is online: $_isOnline');
    debugPrint('Error: $_error');
    debugPrint('Search query: "$_searchQuery"');
    debugPrint('Selected filter: $_selectedFilter');
    debugPrint('Stream subscription active: ${_streamSubscription != null}');
    debugPrint('================================');
  }

  // Force reload data
  Future<void> forceReload() async {
    debugPrint('🔄 Provider: Force reload initiated...');

    // Cancel existing stream
    _streamSubscription?.cancel();

    // Clear current data
    _parties.clear();
    _error = null;
    _setLoading(true);

    // Reload
    await _initializeData();
  }
}
