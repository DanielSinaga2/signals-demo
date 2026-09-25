import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../state/product_signals.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key, this.product});
  final Product? product;
  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  late final name = TextEditingController(text: widget.product?.name ?? '');
  late final price = TextEditingController(
    text: widget.product?.price?.toString() ?? '',
  );
  late final stock = TextEditingController(
    text: widget.product?.stock?.toString() ?? '',
  );
  late final category = TextEditingController(
    text: widget.product?.category ?? '',
  );
  late final description = TextEditingController(
    text: widget.product?.description ?? '',
  );
  Uint8List? imageBytes;
  String? imageFilename;
  bool removeImage = false;

  @override
  void dispose() {
    for (final controller in [name, price, stock, category, description]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (mounted)
      setState(() {
        imageBytes = bytes;
        imageFilename = image.name;
        removeImage = false;
      });
  }

  Future<void> _save() async {
    if (name.text.trim().isEmpty) {
      return;
    }
    try {
      String? assetId = removeImage ? null : widget.product?.imageUrl;
      if (imageBytes != null)
        assetId = await ApiService.instance.uploadImage(
          imageBytes!,
          imageFilename ?? 'product.jpg',
        );
      final product = Product(
        id: widget.product?.id ?? '',
        name: name.text.trim(),
        price: num.tryParse(price.text),
        stock: int.tryParse(stock.text),
        category: category.text.trim().isEmpty ? null : category.text.trim(),
        description: description.text.trim().isEmpty
            ? null
            : description.text.trim(),
        imageUrl: assetId,
        quantity: widget.product?.quantity,
        status: widget.product?.status,
      );
      if (await saveProduct(product, id: widget.product?.id) && mounted)
        Navigator.pop(context, true);
    } catch (error) {
      crudError.value = ApiService.instance.errorMessage(error);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.product == null ? 'Tambah Product' : 'Edit Product',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _imagePicker(context),
          const SizedBox(height: 18),
          _field(name, 'Nama product *'),
          _field(price, 'Harga', number: true),
          _field(stock, 'Stock', number: true),
          _field(category, 'Kategori'),
          _field(description, 'Deskripsi', lines: 3),
          SignalBuilder(
            builder: (context) => crudError.value == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      crudError.value!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
          ),
          SignalBuilder(
            builder: (context) => FilledButton.icon(
              onPressed: isSubmitting.value ? null : _save,
              icon: isSubmitting.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                isSubmitting.value ? 'Menyimpan...' : 'SIMPAN PRODUCT',
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _imagePicker(BuildContext context) {
    final remote = widget.product?.imageUrl;
    final hasImage = imageBytes != null || (remote != null && !removeImage);
    return Container(
      height: 156,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageBytes != null)
            Image.memory(imageBytes!, fit: BoxFit.cover)
          else if (remote != null && !removeImage)
            Image.network(
              'https://pos.cicd.web.id/assets/$remote',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined, size: 42),
              ),
            )
          else
            const Center(
              child: Icon(Icons.add_photo_alternate_outlined, size: 42),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                    ),
                    label: Text(
                      hasImage ? 'Ganti gambar' : 'Pilih gambar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (hasImage)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        imageBytes = null;
                        imageFilename = null;
                        removeImage = true;
                      }),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool number = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: TextField(
      controller: controller,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
