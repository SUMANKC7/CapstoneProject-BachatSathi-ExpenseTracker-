import 'package:expensetrack/features/transactions/provider/add_entity_provider.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:expensetrack/pdf_generation/services/pdf_generator_service.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final personalTransactionProvider = Provider.of<AddTransactionProvider>(
        context,
        listen: false,
      );
      final partyProvider = Provider.of<PartiesProvider>(
        context,
        listen: false,
      );

      // Fetching data - you might want to enhance your repositories to fetch by date
      final personalTransactions = await personalTransactionProvider.repository
          .getTransactionsByDateRange(_startDate, _endDate);
      final partyTransactions = partyProvider.parties.where((party) {
        // Assuming 'date' is a string; you need to parse it
        try {
          final partyDate = party.date;
          return partyDate.isAfter(
                _startDate.subtract(const Duration(days: 1)),
              ) &&
              partyDate.isBefore(_endDate.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();

      // Generate and save the PDF
      final pdfFile = await PdfGeneratorService.generatePdf(
        personalTransactions: personalTransactions,
        partyTransactions: partyTransactions,
        startDate: _startDate,
        endDate: _endDate,
      );

      // Optionally, open the file
      await OpenFile.open(pdfFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report saved to ${pdfFile.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate report: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(DateFormat.yMMMd().format(_startDate)),
                const Text('to'),
                Text(DateFormat.yMMMd().format(_endDate)),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDateRange(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Generate PDF Report'),
                      onPressed: _generateReport,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
