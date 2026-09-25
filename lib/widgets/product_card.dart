import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image(color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Rp ${product.price?.toString() ?? '-'}',
                      style: TextStyle(
                        color: color.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        if (product.category != null)
                          _tag(product.category!, color),
                        _tag(
                          'Stok ${product.stock ?? product.quantity ?? '-'}',
                          color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Edit product',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Hapus product',
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: color.error),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _image(ColorScheme color) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      width: 76,
      height: 76,
      child: product.imageUrl == null
          ? ColoredBox(
              color: color.primaryContainer,
              child: Icon(
                Icons.inventory_2_outlined,
                color: color.onPrimaryContainer,
              ),
            )
          : Image.network(
              'https://pos.cicd.web.id/assets/${product.imageUrl}',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: color.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
    ),
  );
  Widget _tag(String text, ColorScheme color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.secondaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 11, color: color.onSecondaryContainer),
    ),
  );
}
