import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/data/filter_item.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/payment/screen/widgets/export_buttons.dart';
import 'package:istoreto/featured/payment/screen/widgets/filtter_bar.dart';
import 'package:istoreto/featured/payment/screen/widgets/order_list.dart';
import 'package:istoreto/featured/payment/screen/widgets/order_state_card.dart';
import 'package:istoreto/featured/payment/screen/widgets/search_field.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';

class VendorSalesScreen extends StatefulWidget {
  final String vendorId;
  const VendorSalesScreen({super.key, required this.vendorId});

  @override
  State<VendorSalesScreen> createState() => _VendorSalesScreenState();
}

class _VendorSalesScreenState extends State<VendorSalesScreen> {
  final RxBool filterByTime = true.obs;
  final RxString searchQuery = ''.obs;
  final Rx<FilterItem> selectedFilter = FilterItem('all', "filter.all".tr).obs;

  late final Future<List<OrderModel>> _ordersFuture;

  final Map<String, String> stateKeys = {
    'جاري': 'runing',
    'تم الدفع': 'paied',
    'تم التسليم': 'delivered',
    'يتم التحضير': 'Preparing',
  };

  List<FilterItem> getDateFilters(BuildContext context) {
    return [
      FilterItem('all', "filter.all".tr),
      FilterItem('Today', "filter.today".tr),
      FilterItem('This Week', "filter.week".tr),
      FilterItem('This month', "filter.month".tr),
    ];
  }

  List<FilterItem> getStateFilters(BuildContext context) {
    final stateKeys = ['runing', 'prepared', 'paied', 'delivered', 'unKnoun'];

    return [
      FilterItem('all', "filter.all".tr),
      ...stateKeys.map((key) => FilterItem(key, "orderState.$key".tr)),
    ];
  }

  List<FilterItem> get filters =>
      filterByTime.value ? getDateFilters(context) : getStateFilters(context);
  @override
  void initState() {
    super.initState();
    _ordersFuture = OrderController.instance.fetchVendorSales(widget.vendorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.lightContainer,
      appBar: CustomAppBar(
        title: 'order.orders'.tr,
        showActionButton: true,
        // elevation: 1,
      ),
      body: SafeArea(
        child: FutureBuilder<List<OrderModel>>(
          future: _ordersFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = snap.data ?? [];

            return Obx(() {
              final active = selectedFilter.value;
              final filtered = _applyFilter(orders, active);

              final result =
                  filtered.where((o) {
                    return true;
                  }).toList();

              final stats = <String, int>{};
              for (var o in filtered) {
                final s = OrderController.instance.getOrderState(o);
                stats[s] = (stats[s] ?? 0) + 1;
              }

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // 🔍 البحث + الفلترة
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SearchField(
                          onChanged:
                              (val) => searchQuery.value = val.toLowerCase(),
                        ),
                        const SizedBox(height: 10),
                        FilterToggleBar(
                          filterByTime: filterByTime,
                          onChanged: (val) {
                            filterByTime.value =
                                val; // ✅ هذا ضروري لتحديث RxBool
                            selectedFilter.value = filters.firstWhere(
                              (f) => f.key == 'all',
                            ); // لإعادة تعيين الفلتر عند التبديل
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔘 الفلاتر
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          filters.map((item) {
                            final selected =
                                selectedFilter.value.key == item.key;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: GestureDetector(
                                onTap: () => selectedFilter.value = item,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color:
                                            selected
                                                ? Colors.black
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    item.label,
                                    style: titilliumBold.copyWith(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight:
                                          selected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ExportButtonsRow(orders: orders),
                  const SizedBox(height: 16),

                  OrderStatsCard(stats: stats),
                  const SizedBox(height: 12),

                  OrderListView(
                    orders: result,
                  ), // ← هذا يستخدم shrinkWrap داخلياً
                ],
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildFilterButton(FilterItem item) {
    final selected = selectedFilter.value.key == item.key;
    return GestureDetector(
      onTap: () => selectedFilter.value = item,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            item.label,
            style: titilliumBold.copyWith(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  List<OrderModel> _applyFilter(List<OrderModel> orders, FilterItem active) {
    if (active.key == 'all') return orders;

    if (filterByTime.value) {
      final now = DateTime.now();
      return orders.where((o) {
        final d = o.orderDate;
        switch (active.key) {
          case 'Today':
            return d.year == now.year &&
                d.month == now.month &&
                d.day == now.day;
          case 'This Week':
            return now.difference(d).inDays <= 7;
          case 'This month':
            return d.year == now.year && d.month == now.month;
          default:
            return false;
        }
      }).toList();
    } else {
      final translated = "orderState.${active.key}".tr;
      return orders
          .where((o) => OrderController.instance.getOrderState(o) == translated)
          .toList();
    }
  }
}
