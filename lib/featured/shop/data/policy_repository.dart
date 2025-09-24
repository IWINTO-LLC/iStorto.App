import 'package:supabase_flutter/supabase_flutter.dart';

class PolicyRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // إنشاء سياسة جديدة
  Future<Map<String, dynamic>?> createPolicy(
    Map<String, dynamic> policyData,
  ) async {
    try {
      final response =
          await _client
              .from('store_policies')
              .insert(policyData)
              .select()
              .single();

      return response;
    } catch (e) {
      print('Error creating policy: $e');
      return null;
    }
  }

  // الحصول على سياسة البائع
  Future<Map<String, dynamic>?> getPolicyByVendorId(String vendorId) async {
    try {
      final response =
          await _client
              .from('store_policies')
              .select()
              .eq('vendor_id', vendorId)
              .maybeSingle();

      return response;
    } catch (e) {
      print('Error getting policy by vendor ID: $e');
      return null;
    }
  }

  // تحديث سياسة البائع
  Future<Map<String, dynamic>?> updatePolicy(
    String vendorId,
    Map<String, dynamic> policyData,
  ) async {
    try {
      final response =
          await _client
              .from('store_policies')
              .update(policyData)
              .eq('vendor_id', vendorId)
              .select()
              .single();

      return response;
    } catch (e) {
      print('Error updating policy: $e');
      return null;
    }
  }

  // حذف سياسة البائع
  Future<bool> deletePolicy(String vendorId) async {
    try {
      await _client.from('store_policies').delete().eq('vendor_id', vendorId);

      return true;
    } catch (e) {
      print('Error deleting policy: $e');
      return false;
    }
  }

  // الحصول على جميع السياسات
  Future<List<Map<String, dynamic>>> getAllPolicies() async {
    try {
      final response = await _client
          .from('store_policies')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((policy) => policy as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting all policies: $e');
      return [];
    }
  }

  // البحث في السياسات
  Future<List<Map<String, dynamic>>> searchPolicies(String query) async {
    try {
      final response = await _client
          .from('store_policies')
          .select()
          .or(
            'about_us.ilike.%$query%,terms.ilike.%$query%,privacy.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((policy) => policy as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error searching policies: $e');
      return [];
    }
  }

  // الحصول على عدد السياسات
  Future<int> getPoliciesCount() async {
    try {
      final response = await _client.from('store_policies').select('id');

      return (response as List).length;
    } catch (e) {
      print('Error getting policies count: $e');
      return 0;
    }
  }

  // الحصول على السياسات مع التصفح
  Future<List<Map<String, dynamic>>> getPoliciesPaginated({
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('store_policies')
          .select()
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      return (response as List)
          .map((policy) => policy as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting policies paginated: $e');
      return [];
    }
  }

  // تحديث سياسة مخصصة
  Future<bool> updateCustomPolicy(
    String vendorId,
    String policyId,
    Map<String, dynamic> policyData,
  ) async {
    try {
      // الحصول على السياسة الحالية
      final currentPolicy = await getPolicyByVendorId(vendorId);
      if (currentPolicy == null) return false;

      // تحديث السياسة المخصصة
      final customPolicies = List<Map<String, dynamic>>.from(
        currentPolicy['custom_policies'] ?? [],
      );
      final policyIndex = customPolicies.indexWhere(
        (policy) => policy['id'] == policyId,
      );

      if (policyIndex != -1) {
        customPolicies[policyIndex] = {
          ...customPolicies[policyIndex],
          ...policyData,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _client
            .from('store_policies')
            .update({'custom_policies': customPolicies})
            .eq('vendor_id', vendorId);

        return true;
      }
      return false;
    } catch (e) {
      print('Error updating custom policy: $e');
      return false;
    }
  }

  // حذف سياسة مخصصة
  Future<bool> deleteCustomPolicy(String vendorId, String policyId) async {
    try {
      // الحصول على السياسة الحالية
      final currentPolicy = await getPolicyByVendorId(vendorId);
      if (currentPolicy == null) return false;

      // حذف السياسة المخصصة
      final customPolicies = List<Map<String, dynamic>>.from(
        currentPolicy['custom_policies'] ?? [],
      );
      customPolicies.removeWhere((policy) => policy['id'] == policyId);

      await _client
          .from('store_policies')
          .update({'custom_policies': customPolicies})
          .eq('vendor_id', vendorId);

      return true;
    } catch (e) {
      print('Error deleting custom policy: $e');
      return false;
    }
  }

  // إضافة سياسة مخصصة
  Future<bool> addCustomPolicy(
    String vendorId,
    Map<String, dynamic> policyData,
  ) async {
    try {
      // الحصول على السياسة الحالية
      final currentPolicy = await getPolicyByVendorId(vendorId);
      if (currentPolicy == null) {
        // إنشاء سياسة جديدة إذا لم تكن موجودة
        final newPolicy = {
          'vendor_id': vendorId,
          'custom_policies': [policyData],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        return await createPolicy(newPolicy) != null;
      }

      // إضافة السياسة المخصصة إلى القائمة الموجودة
      final customPolicies = List<Map<String, dynamic>>.from(
        currentPolicy['custom_policies'] ?? [],
      );
      customPolicies.add(policyData);

      await _client
          .from('store_policies')
          .update({
            'custom_policies': customPolicies,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vendor_id', vendorId);

      return true;
    } catch (e) {
      print('Error adding custom policy: $e');
      return false;
    }
  }

  // تحديث الصور
  Future<bool> updateImages(
    String vendorId,
    String field,
    List<String> images,
  ) async {
    try {
      await _client
          .from('store_policies')
          .update({
            '${field}_images': images,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vendor_id', vendorId);

      return true;
    } catch (e) {
      print('Error updating images: $e');
      return false;
    }
  }

  // تحديث ملف PDF
  Future<bool> updatePDF(String vendorId, String field, String pdfUrl) async {
    try {
      await _client
          .from('store_policies')
          .update({
            '${field}_pdf': pdfUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('vendor_id', vendorId);

      return true;
    } catch (e) {
      print('Error updating PDF: $e');
      return false;
    }
  }

  // الحصول على إحصائيات السياسات
  Future<Map<String, int>> getPolicyStatistics() async {
    try {
      final response = await _client
          .from('store_policies')
          .select('id, vendor_id');

      final policies =
          (response as List)
              .map((policy) => policy as Map<String, dynamic>)
              .toList();

      int totalPolicies = policies.length;
      int policiesWithCustom =
          policies
              .where(
                (policy) =>
                    policy['custom_policies'] != null &&
                    (policy['custom_policies'] as List).isNotEmpty,
              )
              .length;

      return {
        'total_policies': totalPolicies,
        'policies_with_custom': policiesWithCustom,
        'policies_without_custom': totalPolicies - policiesWithCustom,
      };
    } catch (e) {
      print('Error getting policy statistics: $e');
      return {};
    }
  }

  // التحقق من وجود سياسة
  Future<bool> policyExists(String vendorId) async {
    try {
      final response = await _client
          .from('store_policies')
          .select('id')
          .eq('vendor_id', vendorId)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking if policy exists: $e');
      return false;
    }
  }
}
