import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'address_model.dart';

class AddressRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Create a new address
  Future<AddressModel?> createAddress(AddressModel address) async {
    try {
      final addressData = address.toMap();
      addressData['created_at'] = DateTime.now().toIso8601String();
      addressData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client.from('addresses').insert(addressData).select().single();

      return AddressModel.fromMap(response);
    } catch (e) {
      print('Error creating address: $e');
      return null;
    }
  }

  // Get address by ID
  Future<AddressModel?> getAddressById(String addressId) async {
    try {
      final response =
          await _client
              .from('addresses')
              .select()
              .eq('id', addressId)
              .maybeSingle();

      if (response == null) return null;
      return AddressModel.fromMap(response);
    } catch (e) {
      print('Error getting address by ID: $e');
      return null;
    }
  }

  // Get addresses by user ID
  Future<List<AddressModel>> getAddressesByUser(String userId) async {
    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((address) => AddressModel.fromMap(address))
          .toList();
    } catch (e) {
      print('Error getting addresses by user: $e');
      return [];
    }
  }

  // Get default address for user
  Future<AddressModel?> getDefaultAddress(String userId) async {
    try {
      final response =
          await _client
              .from('addresses')
              .select()
              .eq('user_id', userId)
              .eq('is_default', true)
              .maybeSingle();

      if (response == null) return null;
      return AddressModel.fromMap(response);
    } catch (e) {
      print('Error getting default address: $e');
      return null;
    }
  }

  // Update address
  Future<AddressModel?> updateAddress(AddressModel address) async {
    try {
      final addressData = address.toMap();
      addressData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('addresses')
              .update(addressData)
              .eq('id', address.id!)
              .select()
              .single();

      return AddressModel.fromMap(response);
    } catch (e) {
      print('Error updating address: $e');
      return null;
    }
  }

  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      await _client.from('addresses').delete().eq('id', addressId);

      return true;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  // Set address as default
  Future<bool> setAsDefault(String addressId, String userId) async {
    try {
      // First, unset all other default addresses for this user
      await _client
          .from('addresses')
          .update({
            'is_default': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      // Then set this address as default
      await _client
          .from('addresses')
          .update({
            'is_default': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', addressId);

      return true;
    } catch (e) {
      print('Error setting address as default: $e');
      return false;
    }
  }

  // Search addresses by title or city
  Future<List<AddressModel>> searchAddresses(
    String userId,
    String query,
  ) async {
    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .or(
            'title.ilike.%$query%,city.ilike.%$query%,full_address.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((address) => AddressModel.fromMap(address))
          .toList();
    } catch (e) {
      print('Error searching addresses: $e');
      return [];
    }
  }

  // Get addresses count for user
  Future<int> getAddressesCount(String userId) async {
    try {
      final response = await _client
          .from('addresses')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      print('Error getting addresses count: $e');
      return 0;
    }
  }

  // Get addresses with pagination
  Future<List<AddressModel>> getAddressesPaginated({
    required String userId,
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      return (response as List)
          .map((address) => AddressModel.fromMap(address))
          .toList();
    } catch (e) {
      print('Error getting addresses paginated: $e');
      return [];
    }
  }

  // Get addresses stream for real-time updates
  Stream<List<AddressModel>> getAddressesStream(String userId) {
    try {
      return _client
          .from('addresses')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .map(
            (data) =>
                (data as List)
                    .map((address) => AddressModel.fromMap(address))
                    .toList(),
          );
    } catch (e) {
      print('Error getting addresses stream: $e');
      return Stream.value([]);
    }
  }

  // Check if user has any addresses
  Future<bool> hasAddresses(String userId) async {
    try {
      final response = await _client
          .from('addresses')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking if user has addresses: $e');
      return false;
    }
  }

  // Get addresses by city
  Future<List<AddressModel>> getAddressesByCity(
    String userId,
    String city,
  ) async {
    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .eq('city', city)
          .order('created_at', ascending: false);

      return (response as List)
          .map((address) => AddressModel.fromMap(address))
          .toList();
    } catch (e) {
      print('Error getting addresses by city: $e');
      return [];
    }
  }

  // Get addresses near location (within radius)
  Future<List<AddressModel>> getAddressesNearLocation(
    String userId,
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // This is a simplified version - in a real app you'd use PostGIS for proper geospatial queries
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .not('latitude', 'is', null)
          .not('longitude', 'is', null);

      final addresses =
          (response as List)
              .map((address) => AddressModel.fromMap(address))
              .toList();

      // Filter by distance (simplified calculation)
      return addresses.where((address) {
        if (address.latitude == null || address.longitude == null) return false;

        final distance = _calculateDistance(
          latitude,
          longitude,
          address.latitude!,
          address.longitude!,
        );

        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error getting addresses near location: $e');
      return [];
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Update address coordinates
  Future<bool> updateAddressCoordinates(
    String addressId,
    double latitude,
    double longitude,
  ) async {
    try {
      await _client
          .from('addresses')
          .update({
            'latitude': latitude,
            'longitude': longitude,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', addressId);

      return true;
    } catch (e) {
      print('Error updating address coordinates: $e');
      return false;
    }
  }

  // Duplicate address
  Future<AddressModel?> duplicateAddress(
    String addressId,
    String newTitle,
  ) async {
    try {
      final originalAddress = await getAddressById(addressId);
      if (originalAddress == null) return null;

      final duplicatedAddress = originalAddress.copyWith(
        id: null,
        title: newTitle,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createAddress(duplicatedAddress);
    } catch (e) {
      print('Error duplicating address: $e');
      return null;
    }
  }

  // Get address statistics
  Future<Map<String, int>> getAddressStatistics(String userId) async {
    try {
      final response = await _client
          .from('addresses')
          .select('city, is_default')
          .eq('user_id', userId);

      final addresses =
          (response as List)
              .map((address) => AddressModel.fromMap(address))
              .toList();

      int totalCount = addresses.length;
      int defaultCount = addresses.where((a) => a.isDefault).length;
      int withCoordinates =
          addresses
              .where((a) => a.latitude != null && a.longitude != null)
              .length;

      Map<String, int> cityCount = {};
      for (var address in addresses) {
        if (address.city != null && address.city!.isNotEmpty) {
          cityCount[address.city!] = (cityCount[address.city!] ?? 0) + 1;
        }
      }

      return {
        'total': totalCount,
        'default': defaultCount,
        'with_coordinates': withCoordinates,
        'cities': cityCount.length,
      };
    } catch (e) {
      print('Error getting address statistics: $e');
      return {};
    }
  }
}
