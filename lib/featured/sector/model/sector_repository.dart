import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';
import 'package:istoreto/utils/logging/logger.dart';

class SectorRepository extends GetxController {
  static SectorRepository get instance => Get.find();

  final SupabaseClient _client = Supabase.instance.client;

  // Get all sectors for a vendor
  Future<List<SectorModel>> getAllSectors(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Unable to find user information. try again later';
      }

      final response = await _client
          .from('sectors')
          .select('*')
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: true);

      final sectors =
          (response as List).map((e) => SectorModel.fromJson(e)).toList();
      TLoggerHelper.info("sectors count ${sectors.length}");
      return sectors;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sectors: $e');
      }
      rethrow;
    }
  }

  // Create sector
  Future<SectorModel> createSector(SectorModel sector) async {
    try {
      final payload = sector.toJson();
      payload['created_at'] = DateTime.now().toIso8601String();
      final response =
          await _client.from('sectors').insert(payload).select().single();
      return SectorModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) print('Error creating sector: $e');
      rethrow;
    }
  }

  // Update sector by id
  Future<SectorModel> updateSector(SectorModel sector) async {
    try {
      if (sector.id == null || sector.id!.isEmpty) {
        throw 'Sector id is required';
      }
      final payload = sector.toJson();
      payload['updated_at'] = DateTime.now().toIso8601String();
      final response =
          await _client
              .from('sectors')
              .update(payload)
              .eq('id', sector.id ?? '')
              .select()
              .single();
      return SectorModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) print('Error updating sector: $e');
      rethrow;
    }
  }

  // Delete sector
  Future<void> deleteSector(String sectorId) async {
    try {
      await _client.from('sectors').delete().eq('id', sectorId);
    } catch (e) {
      if (kDebugMode) print('Error deleting sector: $e');
      rethrow;
    }
  }

  // Update sector by name for a vendor
  Future<void> updateSectorByName({
    required String vendorId,
    required String name,
    required SectorModel data,
  }) async {
    try {
      final found =
          await _client
              .from('sectors')
              .select('id')
              .eq('vendor_id', vendorId)
              .eq('name', name)
              .maybeSingle();

      if (found != null && found['id'] != null) {
        await updateSector(data.copyWith(id: found['id'] as String));
      } else {
        // create if not found
        await createSector(data);
      }
    } catch (e) {
      if (kDebugMode) print('updateSectorByName error: $e');
      rethrow;
    }
  }

  // Initialize default sectors if none exist
  Future<void> initializeSectorCollection(String vendorId) async {
    try {
      final existing = await _client
          .from('sectors')
          .select('id')
          .eq('vendor_id', vendorId);
      if ((existing as List).isNotEmpty) return;

      final defaults = <SectorModel>[
        SectorModel(vendorId: vendorId, name: 'all', englishName: 'All'),
        SectorModel(vendorId: vendorId, name: 'sales', englishName: 'Sales'),
      ];

      final rows = defaults.map((e) => e.toJson()).toList();
      final now = DateTime.now().toIso8601String();
      for (final r in rows) {
        r['created_at'] = now;
      }
      await _client.from('sectors').insert(rows);
    } catch (e) {
      if (kDebugMode) print('initializeSectorCollection error: $e');
      rethrow;
    }
  }
}
