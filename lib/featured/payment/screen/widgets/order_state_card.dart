import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/utils/common/styles/styles.dart';

class OrderStatsCard extends StatefulWidget {
  final Map<String, int> stats;
  const OrderStatsCard({required this.stats, super.key});

  @override
  State<OrderStatsCard> createState() => _OrderStatsCardState();
}

class _OrderStatsCardState extends State<OrderStatsCard>
    with SingleTickerProviderStateMixin {
  bool showStats = false;

  @override
  Widget build(BuildContext context) {
    if (widget.stats.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 عنوان الإحصائيات قابل للضغط
            GestureDetector(
              onTap: () => setState(() => showStats = !showStats),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "📊 ${  'order.statics'.tr}",
                    style: titilliumBold.copyWith(fontSize: 16),
                  ),
                  Icon(
                    showStats ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                    size: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 🔄 الإحصائيات تظهر وتختفي تدريجيًا
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  showStats
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
              firstChild: Column(
                children:
                    widget.stats.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: titilliumRegular.copyWith(fontSize: 15),
                            ),
                            Text(
                              '${entry.value}',
                              style: titilliumBold.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
