import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    
    // Load dummy data if empty
    if (financeProvider.transactions.isEmpty) {
      financeProvider.loadDummyData();
    }

    if (financeProvider.transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first transaction to get started',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: financeProvider.transactions.take(5).length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = financeProvider.transactions[index];
          return _TransactionTile(transaction: transaction);
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        child: Icon(
          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${transaction.category} • ${dateFormat.format(transaction.date)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
