import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/owner_product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final bool isEditing;
  final String? productId;

  const ProductFormScreen({
    super.key,
    this.isEditing = false,
    this.productId,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _descArController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizesController = TextEditingController();
  String _category = '';
  List<String> _imageUrls = [];
  bool _isSaving = false;

  final _categories = ['Traditional', 'Modern', 'Sportswear', 'Abaya', 'Kids', 'Accessories'];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    final provider = context.read<OwnerProductProvider>();
    final product = await provider.getProductById(widget.productId!);
    if (product != null && mounted) {
      _nameEnController.text = product.nameEn;
      _nameArController.text = product.nameAr;
      _descEnController.text = product.descEn;
      _descArController.text = product.descAr;
      _priceController.text = product.price.toString();
      _sizesController.text = product.sizes.join(', ');
      _category = product.category;
      _imageUrls = List.from(product.images);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    _priceController.dispose();
    _sizesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (picked == null) return;

    try {
      final url = await StorageService().uploadProductImage(picked.path);
      if (mounted) {
        setState(() => _imageUrls.add(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading: $e')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<OwnerProductProvider>();
      final shopId = await provider.getMyShopId();

      if (shopId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please create a shop first')));
        }
        return;
      }

      final sizes = _sizesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final price = double.parse(_priceController.text.trim());

      if (widget.isEditing && widget.productId != null) {
        await provider.updateProduct(widget.productId!, {
          'nameEn': _nameEnController.text.trim(),
          'nameAr': _nameArController.text.trim(),
          'descEn': _descEnController.text.trim(),
          'descAr': _descArController.text.trim(),
          'price': price,
          'sizes': sizes,
          'category': _category,
          'images': _imageUrls,
        });
      } else {
        await provider.addProduct(
          shopId: shopId,
          nameEn: _nameEnController.text.trim(),
          nameAr: _nameArController.text.trim(),
          descEn: _descEnController.text.trim(),
          descAr: _descArController.text.trim(),
          price: price,
          sizes: sizes,
          category: _category,
          imageUrls: _imageUrls,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEditing ? 'Product updated' : 'Product added')),
        );
        context.go('/owner/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? t('editProduct') : t('addProduct'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameEnController,
              decoration: const InputDecoration(labelText: 'Name (English)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? t('fieldRequired') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameArController,
              decoration: const InputDecoration(labelText: 'الاسم (العربية)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? t('fieldRequired') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descEnController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description (English)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descArController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'الوصف (العربية)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${t('price')} (JOD)',
                prefixText: 'JOD ',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return t('fieldRequired');
                if (double.tryParse(v.trim()) == null) return t('enterPrice');
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sizesController,
              decoration: InputDecoration(
                labelText: t('sizes'),
                hintText: 'XS, S, M, L, XL',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category.isEmpty ? null : _category,
              decoration: InputDecoration(labelText: t('category')),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (v) => setState(() => _category = v ?? ''),
              validator: (v) => (v == null || v.isEmpty) ? t('fieldRequired') : null,
            ),
            const SizedBox(height: 16),
            Text(t('images'), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._imageUrls.asMap().entries.map((entry) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(entry.value, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[200])),
                        ),
                        Positioned(
                          top: 0, right: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageUrls.removeAt(entry.key)),
                            child: Container(
                          decoration: const BoxDecoration(color: Color(0xFFCF6679), shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    )),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFB0B0B0).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFB0B0B0)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('${_imageUrls.length} ${t('images').toLowerCase()}', style: const TextStyle(color: Color(0xFFB0B0B0))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.isEditing ? t('save') : t('addProduct')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
