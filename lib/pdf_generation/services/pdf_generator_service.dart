import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGeneratorService {
  static final PdfColor incomeColor = PdfColor.fromInt(
    const Color(0xFF4CAF50).value,
  );
  static final PdfColor expenseColor = PdfColor.fromInt(
    const Color(0xFFf44336).value,
  );
  static final PdfColor netFlowPositiveColor = PdfColor.fromInt(
    const Color(0xFF8BC34A).value,
  );
  static final PdfColor netFlowNegativeColor = PdfColor.fromInt(
    const Color(0xFFE91E63).value,
  );

  static Future<File> generatePdf({
    required List<AllTransactionModel> personalTransactions,
    required List<AddParty> partyTransactions,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final boldFontData = await rootBundle.load(
      "assets/fonts/OpenSans-Bold.ttf",
    );
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(boldFontData);

    final pdfTheme = pw.ThemeData.withFont(base: ttf, bold: boldTtf);

    pdf.addPage(
      pw.MultiPage(
        theme: pdfTheme,
        header: (context) => _buildHeader('Personal Transactions Report'),
        build: (context) => [
          _buildSectionHeader('Summary'),
          _buildPersonalSummary(personalTransactions, currencyFormat),
          if (personalTransactions.isNotEmpty) ...[
            _buildSectionHeader('Visualizations'),
            _buildCategoryBarChart(personalTransactions, currencyFormat),
            pw.SizedBox(height: 30),
            _buildMonthlyTrendsLineChart(personalTransactions, currencyFormat),
          ],
          _buildSectionHeader('All Transactions'),
          _buildPersonalTransactionsTable(personalTransactions, currencyFormat),
        ],
      ),
    );
    pdf.addPage(
      pw.MultiPage(
        theme: pdfTheme,
        header: (context) => _buildHeader('Party Transactions Report'),
        build: (context) => [
          _buildSectionHeader('Summary'),
          _buildPartySummary(partyTransactions, currencyFormat),
          _buildSectionHeader('Party Details'),
          _buildPartyTransactionsTable(partyTransactions, currencyFormat),
        ],
      ),
    );
    pdf.addPage(
      pw.MultiPage(
        theme: pdfTheme,
        header: (context) => _buildHeader('Journal Entries'),
        build: (context) => [
          _buildJournalEntriesTable(
            personalTransactions,
            partyTransactions,
            currencyFormat,
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // --- Helper widgets and tables are unchanged ---
  static pw.Widget _buildHeader(String title) {
    /* ... */
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 20.0),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    /* ... */
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey700,
        ),
      ),
    );
  }

  static pw.Widget _buildPersonalSummary(
    List<AllTransactionModel> txs,
    NumberFormat fmt,
  ) {
    /* ... */
    double totalIncome = txs
        .where((t) => !t.expense && t.amount.isFinite)
        .fold(0.0, (sum, item) => sum + item.amount);
    double totalExpense = txs
        .where((t) => t.expense && t.amount.isFinite)
        .fold(0.0, (sum, item) => sum + item.amount);
    double netFlow = totalIncome - totalExpense;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _summaryRow('Total Income:', fmt.format(totalIncome), PdfColors.green),
        _summaryRow('Total Expense:', fmt.format(totalExpense), PdfColors.red),
        pw.Divider(),
        _summaryRow(
          'Net Flow:',
          fmt.format(netFlow),
          netFlow >= 0 ? PdfColors.green : PdfColors.red,
        ),
      ],
    );
  }

  static pw.Table _buildPersonalTransactionsTable(
    List<AllTransactionModel> txs,
    NumberFormat fmt,
  ) {
    /* ... */
    final headers = ['Date', 'Title', 'Category', 'Income', 'Expense'];
    final data = txs.map((tx) {
      return [
        DateFormat.yMMMd().format(tx.date),
        tx.title,
        tx.category,
        !tx.expense ? fmt.format(tx.amount) : '',
        tx.expense ? fmt.format(tx.amount) : '',
      ];
    }).toList();
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildPartySummary(
    List<AddParty> parties,
    NumberFormat fmt,
  ) {
    /* ... */
    double totalToReceive = parties
        .where((p) => p.toReceive)
        .fold(0.0, (sum, item) => sum + item.openingBalance);
    double totalToGive = parties
        .where((p) => !p.toReceive)
        .fold(0.0, (sum, item) => sum + item.openingBalance);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _summaryRow(
          'Total to Receive:',
          fmt.format(totalToReceive),
          PdfColors.blue,
        ),
        _summaryRow(
          'Total to Give:',
          fmt.format(totalToGive),
          PdfColors.orange,
        ),
      ],
    );
  }

  static pw.Table _buildPartyTransactionsTable(
    List<AddParty> parties,
    NumberFormat fmt,
  ) {
    /* ... */
    final headers = ['Date', 'Party Name', 'Phone', 'Amount', 'Status'];
    final data = parties.map((party) {
      return [
        DateFormat.yMMMd().format(party.date),
        party.name,
        party.phone,
        fmt.format(party.openingBalance),
        party.toReceive ? 'To Receive' : 'To Give',
      ];
    }).toList();
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {3: pw.Alignment.centerRight},
    );
  }

  static pw.Table _buildJournalEntriesTable(
    List<AllTransactionModel> personal,
    List<AddParty> parties,
    NumberFormat fmt,
  ) {
    /* ... */
    final headers = ['Date', 'Description', 'Debit', 'Credit'];
    List<List<String>> data = [];
    for (var tx in personal) {
      if (tx.expense) {
        data.add([
          DateFormat.yMMMd().format(tx.date),
          '${tx.title} (Expense)',
          fmt.format(tx.amount),
          '',
        ]);
      } else {
        data.add([
          DateFormat.yMMMd().format(tx.date),
          '${tx.title} (Income)',
          '',
          fmt.format(tx.amount),
        ]);
      }
    }
    for (var party in parties) {
      try {
        if (party.toReceive) {
          data.add([
            DateFormat.yMMMd().format(party.date),
            'Lent to ${party.name}',
            fmt.format(party.openingBalance),
            '',
          ]);
        } else {
          data.add([
            DateFormat.yMMMd().format(party.date),
            'Borrowed from ${party.name}',
            '',
            fmt.format(party.openingBalance),
          ]);
        }
      } catch (e) {}
    }
    data.sort(
      (a, b) => DateFormat.yMMMd()
          .parse(a[0])
          .compareTo(DateFormat.yMMMd().parse(b[0])),
    );
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _summaryRow(String title, String value, PdfColor color) {
    /* ... */
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(
            value,
            style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- Chart Generation Methods (REBUILT WITH DATA SANITIZATION) ---

  static pw.Widget _buildCategoryBarChart(
    List<AllTransactionModel> transactions,
    NumberFormat currencyFormat,
  ) {
    final Map<String, double> categoryTotals = {};

    // --- FIX #1: Sanitize data BEFORE processing ---
    final validTransactions = transactions.where(
      (tx) => tx.expense && tx.amount.isFinite,
    );

    for (var tx in validTransactions) {
      final category = tx.category.isEmpty ? 'Uncategorized' : tx.category;
      categoryTotals.update(
        category,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    // --- FIX #2: Check if there is ANY valid data left ---
    if (categoryTotals.isEmpty) {
      return pw.Center(
        child: pw.Text("No valid expense data to display in chart."),
      );
    }

    final categoryKeys = categoryTotals.keys.toList();
    final data = List<pw.PointChartValue>.generate(categoryKeys.length, (
      index,
    ) {
      final value = categoryTotals[categoryKeys[index]]!;
      return pw.PointChartValue(index.toDouble(), value);
    });

    double maxAmount = data.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    if (maxAmount == 0) maxAmount = 10;

    final yAxisTicks = List<double>.generate(6, (i) => (maxAmount / 5) * i);

    return pw.Container(
      height: 250,
      child: pw.Chart(
        title: pw.Text('Expenses by Category'),
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis(
            List<int>.generate(categoryKeys.length, (i) => i),
          ),
          yAxis: pw.FixedAxis(yAxisTicks),
        ),
        datasets: [pw.BarDataSet(color: PdfColors.blue, data: data)],
      ),
    );
  }

  static pw.Widget _buildMonthlyTrendsLineChart(
    List<AllTransactionModel> transactions,
    NumberFormat currencyFormat,
  ) {
    final Map<String, Map<String, double>> monthlyMap = {};

    // --- FIX #1: Sanitize data BEFORE processing ---
    final validTransactions = transactions.where((tx) => tx.amount.isFinite);

    for (final transaction in validTransactions) {
      final monthKey = DateFormat('yyyy-MM').format(transaction.date);
      monthlyMap.putIfAbsent(monthKey, () => {'income': 0.0, 'expense': 0.0});
      if (transaction.expense) {
        monthlyMap[monthKey]!['expense'] =
            (monthlyMap[monthKey]!['expense'] ?? 0.0) + transaction.amount;
      } else {
        monthlyMap[monthKey]!['income'] =
            (monthlyMap[monthKey]!['income'] ?? 0.0) + transaction.amount;
      }
    }

    // --- FIX #2: Check if there is ANY valid data left ---
    if (monthlyMap.isEmpty) {
      return pw.Center(
        child: pw.Text("No valid transaction data for trend chart."),
      );
    }

    final sortedKeys = monthlyMap.keys.toList()..sort();
    final incomeData = List<pw.PointChartValue>.generate(
      sortedKeys.length,
      (i) => pw.PointChartValue(
        i.toDouble(),
        monthlyMap[sortedKeys[i]]!['income']!,
      ),
    );
    final expenseData = List<pw.PointChartValue>.generate(
      sortedKeys.length,
      (i) => pw.PointChartValue(
        i.toDouble(),
        monthlyMap[sortedKeys[i]]!['expense']!,
      ),
    );
    final netFlowData = List<pw.PointChartValue>.generate(sortedKeys.length, (
      i,
    ) {
      final net =
          monthlyMap[sortedKeys[i]]!['income']! -
          monthlyMap[sortedKeys[i]]!['expense']!;
      return pw.PointChartValue(i.toDouble(), net);
    });

    final allValues = [
      ...incomeData.map((d) => d.y),
      ...expenseData.map((d) => d.y),
      ...netFlowData.map((d) => d.y),
    ];

    double minY = allValues.reduce((a, b) => a < b ? a : b);
    double maxY = allValues.reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      minY -= 5;
      maxY += 5;
    }
    if (minY == maxY) {
      // Handles case where both were 0
      maxY = minY + 10;
    }
    final range = maxY - minY;
    final yAxisTicks = List<double>.generate(6, (i) => minY + (range / 5) * i);

    return pw.Container(
      height: 250,
      child: pw.Chart(
        title: pw.Text('Monthly Financial Trends'),
        right: pw.ChartLegend(),
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis(List<int>.generate(sortedKeys.length, (i) => i)),
          yAxis: pw.FixedAxis(yAxisTicks),
        ),
        datasets: [
          pw.LineDataSet(
            legend: 'Income',
            color: incomeColor,
            data: incomeData,
          ),
          pw.LineDataSet(
            legend: 'Expense',
            color: expenseColor,
            data: expenseData,
          ),
          pw.LineDataSet(
            legend: 'Net Flow',
            color: netFlowData.isNotEmpty && netFlowData.last.y >= 0
                ? netFlowPositiveColor
                : netFlowNegativeColor,
            data: netFlowData,
            isCurved: true,
          ),
        ],
      ),
    );
  }
}
