import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/date_formatter.dart';
import 'package:frontend/features/bumdes/widgets/common_widgets.dart';

/// Widget for managing petani contributors list
/// Displays contributors in FIFO order with edit/delete actions
class PetaniContributorList extends StatelessWidget {
  final List<Map<String, dynamic>> contributors;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final bool isEnabled;

  const PetaniContributorList({
    super.key,
    required this.contributors,
    required this.onEdit,
    required this.onDelete,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (contributors.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Urutan FIFO (teratas dijual pertama):',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          ...contributors.asMap().entries.map((entry) {
            final index = entry.key;
            final contrib = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Text section with Flexible instead of Expanded
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          contrib['petani_name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${contrib['contributed_kg']} kg • ${_formatDate(contrib['harvest_date'])}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Fixed spacing before buttons
                  const SizedBox(width: 8),
                  // Action buttons with fixed size
                  if (isEnabled)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => onEdit(index),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.edit, size: 18, color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => onDelete(index),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.delete, size: 18, color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    return DateFormatter.formatDateFromIso(dateStr);
  }
}

/// Dialog for adding/editing petani contributors
class PetaniContributorDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final List<Map<String, dynamic>> petaniList;

  const PetaniContributorDialog({
    super.key,
    this.initialData,
    required this.petaniList,
  });

  @override
  State<PetaniContributorDialog> createState() =>
      _PetaniContributorDialogState();
}

class _PetaniContributorDialogState extends State<PetaniContributorDialog> {
  late TextEditingController _kgController;
  int? _selectedPetaniId;
  String? _selectedPetaniName;
  DateTime? _selectedHarvestDate;

  @override
  void initState() {
    super.initState();
    _kgController = TextEditingController(
      text: widget.initialData?['contributed_kg']?.toString() ?? '',
    );
    _selectedPetaniId = widget.initialData?['petani_id'];
    _selectedPetaniName = widget.initialData?['petani_name'];

    if (widget.initialData?['harvest_date'] != null) {
      try {
        _selectedHarvestDate = DateTime.parse(
          widget.initialData!['harvest_date'],
        );
      } catch (e) {
        _selectedHarvestDate = null;
      }
    }
  }

  @override
  void dispose() {
    _kgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialData == null ? 'Tambah Kontributor' : 'Edit Kontributor',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BumdesInputLabel('Petani *', required: true),
            DropdownButtonFormField<int>(
              initialValue: _selectedPetaniId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: widget.petaniList.map<DropdownMenuItem<int>>((petani) {
                return DropdownMenuItem<int>(
                  value: petani['id'] as int,
                  child: Text(
                    petani['name'] as String,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPetaniId = value;
                  _selectedPetaniName =
                      widget.petaniList.firstWhere(
                            (p) => p['id'] == value,
                          )['name']
                          as String;
                });
              },
            ),
            const SizedBox(height: 16),
            const BumdesInputLabel('Jumlah (kg) *', required: true),
            TextField(
              controller: _kgController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Jumlah (kg)',
                prefixIcon: Icon(Icons.scale),
              ),
            ),
            const SizedBox(height: 16),
            const BumdesInputLabel('Tanggal Panen *', required: true),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedHarvestDate == null
                      ? 'Pilih tanggal'
                      : _formatDate(_selectedHarvestDate!),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _handleSubmit, child: const Text('Simpan')),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedHarvestDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedHarvestDate = picked;
      });
    }
  }

  void _handleSubmit() {
    final kg = double.tryParse(_kgController.text);
    if (kg == null || kg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah kg yang valid')),
      );
      return;
    }
    if (_selectedPetaniId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih petani')));
      return;
    }
    if (_selectedHarvestDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih tanggal panen')));
      return;
    }

    Navigator.pop(context, {
      'petani_id': _selectedPetaniId,
      'petani_name': _selectedPetaniName,
      'contributed_kg': kg,
      'harvest_date': _selectedHarvestDate!.toIso8601String(),
    });
  }

  String _formatDate(DateTime date) {
    return DateFormatter.formatDateShort(date);
  }
}
