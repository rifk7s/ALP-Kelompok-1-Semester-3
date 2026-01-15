import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/date_formatter.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/features/bumdes/view/widgets/common_widgets.dart';

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
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => onDelete(index),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.delete,
                              size: 18,
                              color: AppColors.danger,
                            ),
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

  // Shake keys for validation
  final _petaniShakeKey = GlobalKey<ShakeWidgetState>();
  final _kgShakeKey = GlobalKey<ShakeWidgetState>();
  final _dateShakeKey = GlobalKey<ShakeWidgetState>();

  // Error messages for inline validation
  String? _petaniError;
  String? _kgError;
  String? _dateError;

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
            ShakeWidget(
              key: _petaniShakeKey,
              child: DropdownButtonFormField<int>(
                initialValue: _selectedPetaniId,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  errorText: _petaniError,
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
                    if (_petaniError != null) _petaniError = null;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            const BumdesInputLabel('Jumlah (kg) *', required: true),
            ShakeWidget(
              key: _kgShakeKey,
              child: TextField(
                controller: _kgController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Jumlah (kg)',
                  prefixIcon: const Icon(Icons.scale),
                  errorText: _kgError,
                ),
                onChanged: (_) {
                  if (_kgError != null) {
                    setState(() => _kgError = null);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            const BumdesInputLabel('Tanggal Panen *', required: true),
            ShakeWidget(
              key: _dateShakeKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        errorText: _dateError,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
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
        if (_dateError != null) _dateError = null;
      });
    }
  }

  void _handleSubmit() {
    // Clear previous errors
    setState(() {
      _kgError = null;
      _petaniError = null;
      _dateError = null;
    });

    bool hasError = false;

    final kg = double.tryParse(_kgController.text);
    if (kg == null || kg <= 0) {
      setState(() => _kgError = 'Masukkan jumlah kg yang valid');
      _kgShakeKey.currentState?.shake();
      hasError = true;
    }

    if (_selectedPetaniId == null) {
      setState(() => _petaniError = 'Pilih petani');
      _petaniShakeKey.currentState?.shake();
      hasError = true;
    }

    if (_selectedHarvestDate == null) {
      setState(() => _dateError = 'Pilih tanggal panen');
      _dateShakeKey.currentState?.shake();
      hasError = true;
    }

    if (hasError) return;

    context.pop({
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
