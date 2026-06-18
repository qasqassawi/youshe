import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/shop_model.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _descArController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  String _category = '';
  String? _shopId;
  String _logoUrl = '';
  String _coverUrl = '';
  bool _isLoading = true;
  bool _isSaving = false;

  final _categories = ['Traditional', 'Modern', 'Sportswear', 'Abaya', 'Kids', 'Accessories'];

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;

    final firestore = FirestoreService();
    final snapshot = await firestore
        .collection(FirestoreCollections.shops)
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      _shopId = doc.id;
      final data = doc.data() as Map<String, dynamic>;
      final shop = ShopModel.fromMap(doc.id, data);
      _nameEnController.text = shop.nameEn;
      _nameArController.text = shop.nameAr;
      _descEnController.text = shop.descEn;
      _descArController.text = shop.descAr;
      _phoneController.text = shop.phone;
      _cityController.text = shop.city;
      _category = shop.category;
      _logoUrl = shop.logoUrl;
      _coverUrl = shop.coverUrl;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (picked == null) return;

    try {
      final url = await StorageService().uploadShopImage(picked.path);
      if (mounted) {
        setState(() {
          if (isLogo) _logoUrl = url; else _coverUrl = url;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final firestore = FirestoreService();
      final uid = AuthService().currentUser!.uid;
      final data = {
        'ownerId': uid,
        'nameEn': _nameEnController.text.trim(),
        'nameAr': _nameArController.text.trim(),
        'descEn': _descEnController.text.trim(),
        'descAr': _descArController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'category': _category,
        'logoUrl': _logoUrl,
        'coverUrl': _coverUrl,
        'isActive': true,
      };

      if (_shopId != null) {
        await firestore.set(FirestoreCollections.shops, _shopId!, data);
      } else {
        final ref = await firestore.add(FirestoreCollections.shops, data);
        _shopId = ref.id;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop saved')));
        context.go('/owner/dashboard');
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

    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: Text(t('myShop'))), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('myShop'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: () => _pickImage(true),
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white12,
                  backgroundImage: _logoUrl.isNotEmpty ? NetworkImage(_logoUrl) : null,
                  child: _logoUrl.isEmpty ? const Icon(Icons.store, size: 40, color: Colors.white54) : null,
                ),
              ),
            ),
            TextButton(onPressed: () => _pickImage(true), child: Text(t('chooseFromGallery'))),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameEnController,
              decoration: const InputDecoration(labelText: 'Shop Name (English)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? t('fieldRequired') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameArController,
              decoration: const InputDecoration(labelText: 'اسم المتجر (العربية)'),
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
            DropdownButtonFormField<String>(
              value: _category.isEmpty ? null : _category,
              decoration: InputDecoration(labelText: t('category')),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v ?? ''),
              validator: (v) => (v == null || v.isEmpty) ? t('fieldRequired') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: t('shopCity'), hintText: 'Amman'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: t('phone'), hintText: '+9627XXXXXXXX'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_shopId != null ? t('updateShop') : t('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
