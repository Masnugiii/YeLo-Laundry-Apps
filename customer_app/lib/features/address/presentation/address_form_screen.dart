import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/address/data/address_repository.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, this.addressId});

  final String? addressId;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _postalController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isDefault = false;
  bool _loading = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  CustomerAddress _buildAddress() {
    return CustomerAddress(
      id: widget.addressId ?? '',
      recipientName: _recipientController.text.trim(),
      phone: _phoneController.text.trim(),
      province: _provinceController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      addressDetail: _addressController.text.trim(),
      postalCode: _postalController.text.trim(),
      isDefault: _isDefault,
      notes: _notesController.text.trim(),
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final customerId = ref.read(sessionProvider).id;
      final address = _buildAddress();
      if (widget.addressId == null) {
        await ref.read(addressRepositoryProvider).create(customerId, address);
      } else {
        await ref.read(addressRepositoryProvider).update(
              customerId,
              widget.addressId!,
              address,
            );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.addressId == null ? 'Tambah Alamat' : 'Edit Alamat')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(controller: _recipientController, decoration: const InputDecoration(labelText: 'Nama Penerima')),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Telepon')),
          TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Alamat Detail')),
          TextField(controller: _districtController, decoration: const InputDecoration(labelText: 'Kecamatan')),
          TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'Kota')),
          TextField(controller: _provinceController, decoration: const InputDecoration(labelText: 'Provinsi')),
          TextField(controller: _postalController, decoration: const InputDecoration(labelText: 'Kode Pos')),
          TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Catatan')),
          SwitchListTile(
            value: _isDefault,
            onChanged: (value) => setState(() => _isDefault = value),
            title: const Text('Jadikan alamat default'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: _loading ? const CircularProgressIndicator() : const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
