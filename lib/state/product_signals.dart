import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';
import '../models/product.dart';
import '../services/api_service.dart';

final products = signal<List<Product>>([]);
final isLoadingProducts = signal(false);
final productError = signal<String?>(null);
final searchQuery = signal('');
final isSubmitting = signal(false);
final crudError = signal<String?>(null);
// Computed re-runs automatically whenever products or searchQuery changes.
final filteredProducts = computed(() {
  final query = searchQuery.value.trim().toLowerCase();
  if (query.isEmpty) return products.value;
  return products.value
      .where(
        (p) =>
            p.name.toLowerCase().contains(query) ||
            (p.category ?? '').toLowerCase().contains(query),
      )
      .toList();
});
Future<void> fetchProducts() async {
  isLoadingProducts.value = true;
  productError.value = null;
  try {
    final response = await ApiService.instance.dio.get('/items/products');
    final raw = response.data is Map ? response.data['data'] : null;
    if (raw is! List)
      throw const FormatException('Format data produk tidak dikenali.');
    products.value = raw
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  } catch (error) {
    productError.value = ApiService.instance.errorMessage(error);
  } finally {
    isLoadingProducts.value = false;
  }
}

Future<bool> saveProduct(Product product, {String? id}) async {
  isSubmitting.value = true;
  crudError.value = null;
  try {
    if (id == null) {
      await ApiService.instance.dio.post(
        '/items/products',
        data: product.toJson(),
      );
    } else {
      await ApiService.instance.dio.patch(
        '/items/products/$id',
        data: product.toJson(),
      );
    }
    await fetchProducts();
    return productError.value == null;
  } catch (error) {
    crudError.value = ApiService.instance.errorMessage(error);
    return false;
  } finally {
    isSubmitting.value = false;
  }
}

Future<bool> deleteProduct(String id) async {
  isSubmitting.value = true;
  crudError.value = null;
  try {
    await ApiService.instance.dio.delete('/items/products/$id');
    products.value = products.value.where((p) => p.id != id).toList();
    return true;
  } catch (error) {
    crudError.value = ApiService.instance.errorMessage(error);
    return false;
  } finally {
    isSubmitting.value = false;
  }
}

EffectCleanup createProductsEffect() => effect(
  () =>
      debugPrint('Products berubah. Jumlah product: ${products.value.length}'),
);
