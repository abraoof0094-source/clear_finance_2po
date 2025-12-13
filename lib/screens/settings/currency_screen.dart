import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/preferences_provider.dart';

class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});

  final List<Map<String, String>> _currencies = const [
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;
    final prefs = context.watch<PreferencesProvider>();
    final currentCode = prefs.currencyCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: onBg),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Select Currency",
          style: TextStyle(color: onBg, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: _currencies.length,
        itemBuilder: (context, index) {
          final item = _currencies[index];
          final isSelected = item['code'] == currentCode;
          final activeColor = theme.colorScheme.primary;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withOpacity(0.1)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: activeColor, width: 2)
                  : Border.all(color: Colors.transparent),
            ),
            child: ListTile(
              onTap: () {
                context.read<PreferencesProvider>().setCurrency(
                  item['code']!,
                  item['symbol']!,
                );
                Navigator.pop(context);
              },
              leading: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : onBg.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  item['symbol']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : onBg,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                item['code']!,
                style: TextStyle(
                  color: onBg,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                item['name']!,
                style: TextStyle(
                  color: onBg.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle_rounded, color: activeColor)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
