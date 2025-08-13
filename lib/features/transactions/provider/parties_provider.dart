import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/services/add_entity_services.dart';
import 'package:flutter/material.dart';

class PartiesProvider with ChangeNotifier {
  final EntityRepository _repository;
  List<Party> _parties = [];
  List<Party> _cachedParties = [];
  String _searchQuery = '';
  TransactionStatus? _selectedFilter;
  bool _isOnline = true;
  bool _isLoading = true;
  String? _error;

  PartiesProvider(this._repository) {
    _initializeData();
    _checkConnectivity();
  }

  List<Party> get parties => _filteredParties;
  String get searchQuery => _searchQuery;
  TransactionStatus? get selectedFilter => _selectedFilter;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Party> get _filteredParties {
    List<Party> filtered = _parties;

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

  void _initializeData() {
    // Load cached data first
    _loadCachedData();

    // Then listen to real-time updates
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
        // Fallback to cached data on error
        if (_parties.isEmpty) {
          _parties = _cachedParties;
        }
        notifyListeners();
      },
    );
  }

  Future<void> _loadCachedData() async {
    try {
      _cachedParties = await _repository.getCachedEntities();
      if (_parties.isEmpty) {
        _parties = _cachedParties;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached data: $e');
    }
  }

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
    _isLoading = true;
    notifyListeners();

    await _checkConnectivity();
    await _loadCachedData();
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
