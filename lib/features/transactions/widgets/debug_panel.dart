import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';

class DebugPanel extends StatelessWidget {
  const DebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartiesProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.bug_report, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Debug Info',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => provider.debugRefresh(),
                    icon: const Icon(Icons.refresh),
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: () => provider.debugPrintState(),
                    icon: const Icon(Icons.print),
                    iconSize: 20,
                  ),
                ],
              ),
              const Divider(),
              _buildDebugRow('Parties Count', '${provider.parties.length}'),
              _buildDebugRow('Is Loading', '${provider.isLoading}'),
              _buildDebugRow('Is Online', '${provider.isOnline}'),
              _buildDebugRow('Error', provider.error ?? 'None'),
              _buildDebugRow('Search Query', '"${provider.searchQuery}"'),
              _buildDebugRow('Filter', '${provider.selectedFilter ?? 'None'}'),
              
              if (provider.parties.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Recent Parties:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                ...provider.parties.take(3).map((party) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Text(
                    '• ${party.name} (${party.id})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                )),
              ],
              
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final lastSync = await provider.getLastSyncTime();
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Last Sync'),
                              content: Text(lastSync?.toString() ?? 'Never'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text('Last Sync', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.refreshData(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Force Refresh', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade100,
                        foregroundColor: Colors.green.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}