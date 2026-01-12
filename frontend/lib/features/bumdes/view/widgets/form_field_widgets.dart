import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/utils/currency_formatter.dart';

/// Form field widgets commonly used in bumdes screens

/// Text field for price input with automatic Rupiah formatting
class BumdesPriceField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final IconData? prefixIcon;
  final bool enabled;
  final bool readOnly;
  final String? initialValue;

  const BumdesPriceField({
    super.key,
    this.controller,
    this.labelText,
    this.prefixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.initialValue,
  });

  @override
  State<BumdesPriceField> createState() => _BumdesPriceFieldState();
}

class _BumdesPriceFieldState extends State<BumdesPriceField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _controller.addListener(() {
      final text = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isNotEmpty) {
        final formatted = CurrencyFormatter.rupiah.format(int.parse(text));
        if (formatted != _controller.text) {
          _controller.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.labelText ?? 'Harga',
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : const Icon(Icons.price_change),
        filled: !widget.enabled || widget.readOnly,
        fillColor: !widget.enabled || widget.readOnly
            ? AppColors.grey100
            : null,
      ),
      style: !widget.enabled || widget.readOnly
          ? const TextStyle(color: AppColors.textMuted)
          : null,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}

/// Text field for numeric input
class BumdesNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final IconData? prefixIcon;
  final bool enabled;
  final bool readOnly;
  final String? hintText;

  const BumdesNumberField({
    super.key,
    required this.controller,
    this.labelText,
    this.prefixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        hintText: hintText,
        filled: !enabled || readOnly,
        fillColor: !enabled || readOnly ? AppColors.grey100 : null,
      ),
      style: !enabled || readOnly
          ? const TextStyle(color: AppColors.textMuted)
          : null,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}

/// Text field for multi-line text input
class BumdesMultilineField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final int maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;

  const BumdesMultilineField({
    super.key,
    required this.controller,
    this.labelText,
    this.maxLines = 3,
    this.minLines,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
      ),
    );
  }
}

/// Dropdown button form field for selecting categories
class BumdesDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool enabled;

  const BumdesDropdownField({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: !enabled,
        fillColor: !enabled ? AppColors.grey100 : null,
      ),
    );
  }
}
