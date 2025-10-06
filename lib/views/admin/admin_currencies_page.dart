import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/featured/currency/controller/currency_admin_controller.dart';
import 'package:istoreto/featured/payment/data/currency_model.dart';

class AdminCurrenciesPage extends StatelessWidget {
  const AdminCurrenciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CurrencyAdminController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'admin_zone_currencies'.tr,
        centerTitle: true,
        reset: IconButton(
          onPressed: () => _showAddCurrencyDialog(context, controller),
          icon: const Icon(Icons.add),
          tooltip: 'Add Currency',
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Search and filter section
              _buildSearchSection(controller),

              // Statistics section
              _buildStatisticsSection(controller),

              // Currencies list
              _buildCurrenciesList(controller),

              // Pagination
              _buildPaginationSection(controller),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCurrencyDialog(context, controller),
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchSection(CurrencyAdminController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: controller.searchCurrencies,
            decoration: InputDecoration(
              hintText: 'Search currencies...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // Sort options
          Row(
            children: [
              const Text('Sort by:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: controller.selectedSortBy.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.sortCurrencies(
                      value,
                      ascending: controller.sortAscending.value,
                    );
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(value: 'iso', child: Text('ISO Code')),
                  DropdownMenuItem(value: 'rate', child: Text('Exchange Rate')),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  controller.sortCurrencies(
                    controller.selectedSortBy.value,
                    ascending: !controller.sortAscending.value,
                  );
                },
                icon: Icon(
                  controller.sortAscending.value
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(CurrencyAdminController controller) {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.getStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Currencies',
                stats['total_currencies']?.toString() ?? '0',
                Icons.currency_exchange,
                Colors.blue,
              ),
              _buildStatItem(
                'Average Rate',
                stats['average_rate']?.toStringAsFixed(2) ?? '0.00',
                Icons.trending_up,
                Colors.green,
              ),
              _buildStatItem(
                'Highest Rate',
                stats['highest_rate']?.toStringAsFixed(2) ?? '0.00',
                Icons.arrow_upward,
                Colors.orange,
              ),
              _buildStatItem(
                'Lowest Rate',
                stats['lowest_rate']?.toStringAsFixed(2) ?? '0.00',
                Icons.arrow_downward,
                Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCurrenciesList(CurrencyAdminController controller) {
    if (controller.currencies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.currency_exchange, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No currencies found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Add your first currency to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.currencies.length,
      itemBuilder: (context, index) {
        final currency = controller.currencies[index];
        return _buildCurrencyCard(currency, controller);
      },
    );
  }

  Widget _buildCurrencyCard(
    CurrencyModel currency,
    CurrencyAdminController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: TColors.primary.withOpacity(0.1),
          child: Text(
            currency.iso,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: TColors.primary,
            ),
          ),
        ),
        title: Text(
          currency.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ISO: ${currency.iso}'),
            Text('Rate: ${currency.formattedExchangeRate}'),
            Text('Symbol: ${currency.symbol}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, currency, controller),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    dense: true,
                  ),
                ),
              ],
        ),
      ),
    );
  }

  Widget _buildPaginationSection(CurrencyAdminController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${controller.currentPage.value + 1} of ${controller.totalPages.value}',
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    controller.currentPage.value > 0
                        ? controller.previousPage
                        : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed:
                    controller.currentPage.value <
                            controller.totalPages.value - 1
                        ? controller.nextPage
                        : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
    String action,
    CurrencyModel currency,
    CurrencyAdminController controller,
  ) {
    switch (action) {
      case 'edit':
        _showEditCurrencyDialog(Get.context!, currency, controller);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(currency, controller);
        break;
    }
  }

  void _showAddCurrencyDialog(
    BuildContext context,
    CurrencyAdminController controller,
  ) {
    controller.clearForm();
    _showCurrencyDialog(context, controller, isEditing: false);
  }

  void _showEditCurrencyDialog(
    BuildContext context,
    CurrencyModel currency,
    CurrencyAdminController controller,
  ) {
    controller.fillFormForEdit(currency);
    _showCurrencyDialog(
      context,
      controller,
      isEditing: true,
      currency: currency,
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    CurrencyAdminController controller, {
    required bool isEditing,
    CurrencyModel? currency,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(isEditing ? 'Edit Currency' : 'Add New Currency'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Currency Name',
                  hintText: 'e.g., US Dollar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.isoController,
                decoration: const InputDecoration(
                  labelText: 'ISO Code',
                  hintText: 'e.g., USD',
                  border: OutlineInputBorder(),
                ),
                maxLength: 3,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.rateController,
                decoration: const InputDecoration(
                  labelText: 'Exchange Rate (to USD)',
                  hintText: 'e.g., 1.000000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isAdding.value || controller.isUpdating.value
                      ? null
                      : () async {
                        bool success;
                        if (isEditing && currency != null) {
                          final updatedCurrency = currency.copyWith(
                            name: controller.nameController.text.trim(),
                            iso:
                                controller.isoController.text
                                    .trim()
                                    .toUpperCase(),
                            usdToCoinExchangeRate:
                                double.tryParse(
                                  controller.rateController.text.trim(),
                                ) ??
                                currency.usdToCoinExchangeRate,
                          );
                          success = await controller.updateCurrency(
                            updatedCurrency,
                          );
                        } else {
                          success = await controller.addCurrency();
                        }

                        if (success) {
                          Get.back();
                        }
                      },
              child:
                  (controller.isAdding.value || controller.isUpdating.value)
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(isEditing ? 'Update' : 'Add'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    CurrencyModel currency,
    CurrencyAdminController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Currency'),
        content: Text(
          'Are you sure you want to delete "${currency.name}" (${currency.iso})?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isDeleting.value
                      ? null
                      : () async {
                        final success = await controller.deleteCurrency(
                          currency.id!,
                        );
                        if (success) {
                          Get.back();
                        }
                      },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  controller.isDeleting.value
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
