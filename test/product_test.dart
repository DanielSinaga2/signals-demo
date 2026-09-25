import 'package:flutter_test/flutter_test.dart';
import 'package:signals_demo/models/product.dart';
import 'package:signals_demo/state/product_signals.dart';

void main() {
  final coffee = Product.fromJson({
    'id': '1',
    'name': 'Kopi',
    'price': '12000',
    'stock': 4,
    'category': 'Minuman',
  });

  setUp(() {
    products.value = [
      coffee,
      const Product(id: '2', name: 'Roti', price: 5000),
    ];
    searchQuery.value = '';
  });

  test('Product parses API fields and serializes editable values', () {
    expect(coffee.price, 12000);
    expect(coffee.toJson(), containsPair('name', 'Kopi'));
    expect(coffee.toJson(), isNot(contains('id')));
  });

  test('computed filteredProducts follows searchQuery and resets', () {
    expect(filteredProducts.value, hasLength(2));
    searchQuery.value = 'kopi';
    expect(filteredProducts.value.single.name, 'Kopi');
    searchQuery.value = '';
    expect(filteredProducts.value, hasLength(2));
  });
}
