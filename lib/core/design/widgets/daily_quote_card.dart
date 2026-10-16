import 'package:flutter/material.dart';
import 'package:untitled/core/design/theme/app_color.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../../../services/daily_quotes.dart';

class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({super.key});

  int _getTodayQuoteIndex() {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final firstDay = DateTime.utc(2026, 1, 1);

    final days = today.difference(firstDay).inDays;

    return days % dailyQuotes.length;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    final quote = dailyQuotes[_getTodayQuoteIndex()];
    final quoteText = isArabic ? quote.ar : quote.en;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.grad1, AppColor.grad2, AppColor.grad3],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote Icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          // Quote Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizations.dailyQuoteTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  quoteText,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Align(
                  alignment: isArabic
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
