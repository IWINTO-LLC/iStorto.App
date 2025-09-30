import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../payment/data/currency_repository.dart';
import '../../payment/data/currency_model.dart';

class CurrencyAdminController extends GetxController {
  static CurrencyAdminController get instance => Get.find();

  final CurrencyRepository _repository = CurrencyRepository();

  // Observable variables
  final RxList<CurrencyModel> currencies = <CurrencyModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAdding = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSortBy = 'name'.obs;
  final RxBool sortAscending = true.obs;

  // Pagination
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 20;

  // Text controllers for add/edit forms
  final TextEditingController nameController = TextEditingController();
  final TextEditingController isoController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCurrencies();
  }

  @override
  void onClose() {
    nameController.dispose();
    isoController.dispose();
    rateController.dispose();
    super.onClose();
  }

  // Load all currencies
  Future<void> loadCurrencies() async {
    try {
      isLoading.value = true;
      final fetchedCurrencies = await _repository.getAllCurrencies();
      currencies.assignAll(fetchedCurrencies);

      // Calculate total pages
      totalPages.value = (currencies.length / itemsPerPage).ceil();
    } catch (e) {
      debugPrint('Error loading currencies: $e');
      Get.snackbar(
        'Error',
        'Failed to load currencies: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add new currency
  Future<bool> addCurrency() async {
    try {
      isAdding.value = true;

      // Validate inputs
      if (nameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Currency name is required');
        return false;
      }

      if (isoController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Currency ISO code is required');
        return false;
      }

      if (isoController.text.trim().length != 3) {
        Get.snackbar('Error', 'ISO code must be 3 characters');
        return false;
      }

      final rate = double.tryParse(rateController.text.trim());
      if (rate == null || rate <= 0) {
        Get.snackbar('Error', 'Valid exchange rate is required');
        return false;
      }

      // Check if currency already exists
      final exists = await _repository.currencyExists(
        isoController.text.trim().toUpperCase(),
      );
      if (exists) {
        Get.snackbar('Error', 'Currency with this ISO code already exists');
        return false;
      }

      // Create new currency
      final newCurrency = CurrencyModel(
        name: nameController.text.trim(),
        iso: isoController.text.trim().toUpperCase(),
        usdToCoinExchangeRate: rate,
      );

      final createdCurrency = await _repository.createCurrency(newCurrency);
      if (createdCurrency != null) {
        currencies.add(createdCurrency);
        currencies.sort((a, b) => a.name.compareTo(b.name));

        // Clear form
        clearForm();

        Get.snackbar(
          'Success',
          'Currency added successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        Get.snackbar('Error', 'Failed to add currency');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding currency: $e');
      Get.snackbar(
        'Error',
        'Failed to add currency: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isAdding.value = false;
    }
  }

  // Delete currency
  Future<bool> deleteCurrency(String currencyId) async {
    try {
      isDeleting.value = true;

      final success = await _repository.deleteCurrency(currencyId);
      if (success) {
        currencies.removeWhere((currency) => currency.id == currencyId);

        Get.snackbar(
          'Success',
          'Currency deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        Get.snackbar('Error', 'Failed to delete currency');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting currency: $e');
      Get.snackbar(
        'Error',
        'Failed to delete currency: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // Update currency
  Future<bool> updateCurrency(CurrencyModel currency) async {
    try {
      isUpdating.value = true;

      final updatedCurrency = await _repository.updateCurrency(currency);
      if (updatedCurrency != null) {
        final index = currencies.indexWhere((c) => c.id == currency.id);
        if (index != -1) {
          currencies[index] = updatedCurrency;
        }

        Get.snackbar(
          'Success',
          'Currency updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        Get.snackbar('Error', 'Failed to update currency');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating currency: $e');
      Get.snackbar(
        'Error',
        'Failed to update currency: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Search currencies
  void searchCurrencies(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      loadCurrencies();
    } else {
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      isLoading.value = true;
      final searchResults = await _repository.searchCurrencies(query);
      currencies.assignAll(searchResults);
    } catch (e) {
      debugPrint('Error searching currencies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sort currencies
  void sortCurrencies(String sortBy, {bool ascending = true}) {
    selectedSortBy.value = sortBy;
    sortAscending.value = ascending;

    switch (sortBy) {
      case 'name':
        currencies.sort(
          (a, b) =>
              ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
        );
        break;
      case 'iso':
        currencies.sort(
          (a, b) => ascending ? a.iso.compareTo(b.iso) : b.iso.compareTo(a.iso),
        );
        break;
      case 'rate':
        currencies.sort(
          (a, b) =>
              ascending
                  ? a.usdToCoinExchangeRate.compareTo(b.usdToCoinExchangeRate)
                  : b.usdToCoinExchangeRate.compareTo(a.usdToCoinExchangeRate),
        );
        break;
    }
  }

  // Get paginated currencies
  List<CurrencyModel> get paginatedCurrencies {
    final startIndex = currentPage.value * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, currencies.length);
    return currencies.sublist(startIndex, endIndex);
  }

  // Go to next page
  void nextPage() {
    if (currentPage.value < totalPages.value - 1) {
      currentPage.value++;
    }
  }

  // Go to previous page
  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    isoController.clear();
    rateController.clear();
  }

  // Fill form for editing
  void fillFormForEdit(CurrencyModel currency) {
    nameController.text = currency.name;
    isoController.text = currency.iso;
    rateController.text = currency.usdToCoinExchangeRate.toString();
  }

  // Get currency statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await _repository.getCurrencyStatistics();
    } catch (e) {
      debugPrint('Error getting currency statistics: $e');
      return {};
    }
  }

  // Bulk delete currencies
  Future<bool> bulkDeleteCurrencies(List<String> currencyIds) async {
    try {
      isDeleting.value = true;

      int deletedCount = 0;
      for (final id in currencyIds) {
        final success = await _repository.deleteCurrency(id);
        if (success) {
          deletedCount++;
        }
      }

      if (deletedCount > 0) {
        currencies.removeWhere((currency) => currencyIds.contains(currency.id));

        Get.snackbar(
          'Success',
          '$deletedCount currencies deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        Get.snackbar('Error', 'Failed to delete currencies');
        return false;
      }
    } catch (e) {
      debugPrint('Error bulk deleting currencies: $e');
      Get.snackbar(
        'Error',
        'Failed to delete currencies: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
