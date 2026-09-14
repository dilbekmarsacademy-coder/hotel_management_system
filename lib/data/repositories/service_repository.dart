import '../models/service_model.dart';
import '../dummy_data/dummy_data.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getAllServices();
  Future<ServiceModel?> getServiceById(String id);
  Future<List<ServiceModel>> getServicesByCategory(String category);
  Future<List<String>> getCategories();
}

class DummyServiceRepository implements ServiceRepository {
  @override
  Future<List<ServiceModel>> getAllServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(DummyData.services);
  }

  @override
  Future<ServiceModel?> getServiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return DummyData.services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return DummyData.services
        .where((s) => s.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DummyData.services.map((s) => s.category).toSet().toList();
  }
}
