import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../models/product.dart';
import '../state/product_signals.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late final EffectCleanup disposeEffect;
  @override
  void initState() {
    super.initState();
    disposeEffect = createProductsEffect();
    fetchProducts();
  }

  @override
  void dispose() {
    disposeEffect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        elevation: 2,
        onPressed: _form,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Product'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 188,
            pinned: true,
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              title: const Text(
                'Signals Product Management',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.primary, colors.tertiary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 54),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produk',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: colors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola data produk dari REST API',
                          style: TextStyle(
                            color: colors.onPrimary.withValues(alpha: .82),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _search(colors),
                    const SizedBox(height: 6),
                    _reactiveBadge(colors),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SignalBuilder(
              builder: (context) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Text(
                      'Daftar Product',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredProducts.value.length} item',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SignalBuilder(
            builder: (context) {
              if (isLoadingProducts.value)
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              if (productError.value != null)
                return SliverFillRemaining(child: _errorView());
              final list = filteredProducts.value;
              if (list.isEmpty)
                return const SliverFillRemaining(
                  child: Center(child: Text('Produk tidak ditemukan.')),
                );
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, index) => ProductCard(
                    product: list[index],
                    onEdit: () => _form(list[index]),
                    onDelete: () => _delete(list[index].id, list[index].name),
                  ),
                  childCount: list.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _search(ColorScheme colors) => Material(
    elevation: 3,
    borderRadius: BorderRadius.circular(16),
    child: TextField(
      onChanged: (value) => searchQuery.value = value,
      decoration: InputDecoration(
        hintText: 'Cari nama atau kategori...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: SignalBuilder(
          builder: (_) => searchQuery.value.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () => searchQuery.value = '',
                  icon: const Icon(Icons.clear),
                ),
        ),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
  Widget _reactiveBadge(ColorScheme colors) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            color: colors.onSecondaryContainer,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            'Signals: searchQuery → filteredProducts',
            style: TextStyle(
              color: colors.onSecondaryContainer,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 52),
          const SizedBox(height: 12),
          Text(productError.value!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: fetchProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
  Future<void> _form([Product? product]) async => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (_) => ProductForm(product: product),
  );
  Future<void> _delete(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Hapus product?'),
        content: Text('Product “$name” akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && await deleteProduct(id) && mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product berhasil dihapus.')),
      );
  }
}
