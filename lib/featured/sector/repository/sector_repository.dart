import 'package:get/get.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository لإدارة الأقسام (Sections) للتجار
class SectorRepository extends GetxController {
  static SectorRepository get instance => Get.find();

  final SupabaseClient _client = SupabaseService.client;

  /// الحصول على جميع أقسام تاجر معين
  Future<List<SectorModel>> getVendorSections(String vendorId) async {
    try {
      final response = await _client
          .from('vendor_sections')
          .select()
          .eq('vendor_id', vendorId)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((e) => SectorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error getting vendor sections: $e');
      return [];
    }
  }

  /// الحصول على الأقسام النشطة والمرئية فقط
  Future<List<SectorModel>> getActiveSections(String vendorId) async {
    try {
      final response = await _client
          .from('vendor_sections')
          .select()
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .eq('is_visible_to_customers', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((e) => SectorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error getting active sections: $e');
      return [];
    }
  }

  /// الحصول على قسم محدد بالمعرف
  Future<SectorModel?> getSectionById(String sectionId) async {
    try {
      final response = await _client
          .from('vendor_sections')
          .select()
          .eq('id', sectionId)
          .single();

      return SectorModel.fromJson(response);
    } catch (e) {
      print('❌ Error getting section by ID: $e');
      return null;
    }
  }

  /// الحصول على قسم محدد بالمفتاح
  Future<SectorModel?> getSectionByKey(String vendorId, String sectionKey) async {
    try {
      final response = await _client
          .from('vendor_sections')
          .select()
          .eq('vendor_id', vendorId)
          .eq('section_key', sectionKey)
          .maybeSingle();

      if (response == null) return null;
      return SectorModel.fromJson(response);
    } catch (e) {
      print('❌ Error getting section by key: $e');
      return null;
    }
  }

  /// إنشاء قسم جديد
  Future<SectorModel?> createSection(SectorModel section) async {
    try {
      final response = await _client
          .from('vendor_sections')
          .insert(section.toJson())
          .select()
          .single();

      return SectorModel.fromJson(response);
    } catch (e) {
      print('❌ Error creating section: $e');
      return null;
    }
  }

  /// تحديث قسم
  Future<SectorModel?> updateSection(SectorModel section) async {
    try {
      final response = await _client
          .from('vendor_sections')
          .update(section.toJson())
          .eq('id', section.id!)
          .select()
          .single();

      return SectorModel.fromJson(response);
    } catch (e) {
      print('❌ Error updating section: $e');
      return null;
    }
  }

  /// حذف قسم
  Future<bool> deleteSection(String sectionId) async {
    try {
      await _client.from('vendor_sections').delete().eq('id', sectionId);
      return true;
    } catch (e) {
      print('❌ Error deleting section: $e');
      return false;
    }
  }

  /// تحديث ترتيب الأقسام
  Future<bool> updateSectionsOrder(List<SectorModel> sections) async {
    try {
      for (int i = 0; i < sections.length; i++) {
        await _client
            .from('vendor_sections')
            .update({'sort_order': i})
            .eq('id', sections[i].id!);
      }
      return true;
    } catch (e) {
      print('❌ Error updating sections order: $e');
      return false;
    }
  }

  /// تحديث اسم القسم المعروض
  Future<bool> updateSectionDisplayName({
    required String sectionId,
    required String displayName,
    String? arabicName,
  }) async {
    try {
      final updates = <String, dynamic>{
        'display_name': displayName,
        if (arabicName != null) 'arabic_name': arabicName,
      };

      await _client
          .from('vendor_sections')
          .update(updates)
          .eq('id', sectionId);

      return true;
    } catch (e) {
      print('❌ Error updating section display name: $e');
      return false;
    }
  }

  /// تحديث نوع العرض
  Future<bool> updateSectionDisplayType({
    required String sectionId,
    required String displayType,
    double? cardWidth,
    double? cardHeight,
    int? itemsPerRow,
  }) async {
    try {
      final updates = <String, dynamic>{
        'display_type': displayType,
        if (cardWidth != null) 'card_width': cardWidth,
        if (cardHeight != null) 'card_height': cardHeight,
        if (itemsPerRow != null) 'items_per_row': itemsPerRow,
      };

      await _client
          .from('vendor_sections')
          .update(updates)
          .eq('id', sectionId);

      return true;
    } catch (e) {
      print('❌ Error updating section display type: $e');
      return false;
    }
  }

  /// تبديل حالة القسم (مفعل/معطل)
  Future<bool> toggleSectionActive(String sectionId, bool isActive) async {
    try {
      await _client
          .from('vendor_sections')
          .update({'is_active': isActive})
          .eq('id', sectionId);

      return true;
    } catch (e) {
      print('❌ Error toggling section active: $e');
      return false;
    }
  }

  /// تبديل رؤية القسم للزبائن
  Future<bool> toggleSectionVisibility(String sectionId, bool isVisible) async {
    try {
      await _client
          .from('vendor_sections')
          .update({'is_visible_to_customers': isVisible})
          .eq('id', sectionId);

      return true;
    } catch (e) {
      print('❌ Error toggling section visibility: $e');
      return false;
    }
  }

  /// إنشاء الأقسام الافتراضية لتاجر جديد
  Future<bool> createDefaultSections(String vendorId) async {
    try {
      await _client.rpc('create_default_vendor_sections', params: {
        'p_vendor_id': vendorId,
      });

      print('✅ Default sections created for vendor: $vendorId');
      return true;
    } catch (e) {
      print('❌ Error creating default sections: $e');
      return false;
    }
  }

  /// عدد الأقسام النشطة لتاجر
  Future<int> getActiveSectionsCount(String vendorId) async {
    try {
      final response = await _client
          .from('vendor_sections')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_active', true);

      return (response as List).length;
    } catch (e) {
      print('❌ Error getting active sections count: $e');
      return 0;
    }
  }

  /// البحث في الأقسام
  Future<List<SectorModel>> searchSections(
    String vendorId,
    String query,
  ) async {
    try {
      final response = await _client
          .from('vendor_sections')
          .select()
          .eq('vendor_id', vendorId)
          .or(
            'display_name.ilike.%$query%,arabic_name.ilike.%$query%,section_key.ilike.%$query%',
          )
          .order('sort_order', ascending: true);

      return (response as List)
          .map((e) => SectorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error searching sections: $e');
      return [];
    }
  }
}

