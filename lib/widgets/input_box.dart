import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piesp_patrol/widgets/common_params.dart';

enum InputPreset { pesel, dateYmd, text, number }


/// Normalizuje białe znaki (zbijanie wielokrotnych spacji).
class _SpacesNormalizer extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Nie formatuj podczas składu IME (np. polska klawiatura/IME)
    if (newValue.composing.isValid) return newValue;

    final compact = newValue.text.replaceAll(RegExp(r'\s+'), ' ');
    if (compact == newValue.text) return newValue; // nic do zrobienia

    // Zachowaj względne położenie kursora
    final delta = compact.length - newValue.text.length;
    final base = (newValue.selection.baseOffset + delta).clamp(0, compact.length);
    final extent = (newValue.selection.extentOffset + delta).clamp(0, compact.length);

    return TextEditingValue(
      text: compact,
      selection: TextSelection(baseOffset: base, extentOffset: extent),
      composing: TextRange.empty,
    );
  }
}


/// YYYY-MM-DD — wstawia '-' po 4 i 7 znaku, tylko cyfry między separatorami.
class _DateYmdDashFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.composing.isValid) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final b = StringBuffer();
    for (var i = 0; i < digits.length && i < 8; i++) {
      b.write(digits[i]);
      if (i == 3 || i == 5) b.write('-');
    }
    final text = b.toString();
    if (text == newValue.text) return newValue;

    final delta = text.length - newValue.text.length;
    final off = (newValue.selection.end + delta).clamp(0, text.length);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: off),
      composing: TextRange.empty,
    );
  }
}


/// Formatter liczb: opcjonalny znak minus na początku i jeden separator dziesiętny.
/// Akceptuje '.' oraz ',' — separator normalizuje do '.' aby ułatwić parsowanie.
class _NumericFormatter extends TextInputFormatter {
  _NumericFormatter({required this.allowNegative, required this.allowDecimal});
  final bool allowNegative;
  final bool allowDecimal;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.composing.isValid) return newValue;

    final text = newValue.text;
    final buf = StringBuffer();
    var hasDecimal = false;

    for (var i = 0; i < text.length; i++) {
      final ch = text[i];

      if (ch == '-' && allowNegative && i == 0) {
        buf.write('-');
        continue;
      }
      final code = ch.codeUnitAt(0);
      final isDigit = code >= 48 && code <= 57;

      if (isDigit) {
        buf.write(ch);
        continue;
      }
      if (allowDecimal && (ch == '.' || ch == ',') && !hasDecimal) {
        buf.write('.');
        hasDecimal = true;
      }
      // inne znaki pomijamy
    }

    final out = buf.toString();
    if (out == newValue.text) return newValue;

    final delta = out.length - newValue.text.length;
    final off = (newValue.selection.end + delta).clamp(0, out.length);

    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: off),
      composing: TextRange.empty,
    );
  }
}

class _UppercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Nie ruszaj w trakcie składu IME
    if (newValue.composing.isValid) return newValue;

    final up = newValue.text.toUpperCase(); // działa też dla ąćęłńóśźż
    if (up == newValue.text) return newValue;

    final delta = up.length - newValue.text.length;
    final off = (newValue.selection.end + delta).clamp(0, up.length);

    return TextEditingValue(
      text: up,
      selection: TextSelection.collapsed(offset: off),
      composing: TextRange.empty,
    );
  }
}


class InputBox extends StatelessWidget {
  const InputBox({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.preset = InputPreset.text,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.textInputAction,
    this.borderStyle = InputBorderStyle.underline, // domyślnie: tylko dolna krawędź
    // Opcje dla number:
    this.allowNegative = false,
    this.allowDecimal = false,
    this.uppercase = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final InputPreset preset;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final InputBorderStyle borderStyle;

  /// Działa tylko dla `InputPreset.number`.
  final bool allowNegative;
  final bool allowDecimal;
  final bool uppercase;

  List<TextInputFormatter> _formatters() {
    switch (preset) {
      case InputPreset.pesel:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ];
      case InputPreset.dateYmd:
        return [
          _DateYmdDashFormatter(),
          LengthLimitingTextInputFormatter(10),
        ];
      case InputPreset.number:
        return [
          _NumericFormatter(
            allowNegative: allowNegative,
            allowDecimal: allowDecimal,
          ),
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ];
      case InputPreset.text:
        return [
          if (uppercase) _UppercaseFormatter(),
          _SpacesNormalizer(),
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ];
    }
  }

  TextInputType _keyboard() {
    switch (preset) {
      case InputPreset.pesel:
        return TextInputType.number;
      case InputPreset.number:
        return TextInputType.numberWithOptions(
          signed: allowNegative,
          decimal: allowDecimal,
        );
      case InputPreset.dateYmd:
        return TextInputType.datetime;
      case InputPreset.text:
        return TextInputType.text;
    }
  }

  String? _defaultValidator(String? v) {
    final text = (v ?? '').trim();
    switch (preset) {
      case InputPreset.pesel:
        if (text.isEmpty) return null;
        if (text.length != 11) return 'PESEL musi mieć 11 cyfr';
        const w = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3];
        var s = 0;
        for (var i = 0; i < 10; i++) {
          s += (int.tryParse(text[i]) ?? 0) * w[i];
        }
        final k = (10 - (s % 10)) % 10;
        if (k != int.tryParse(text[10])) return 'Niepoprawny PESEL';
        return null;

      case InputPreset.dateYmd:
        if (text.isEmpty) return null;
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
          return 'Format: RRRR-MM-DD';
        }
        return null;

      case InputPreset.number:
      case InputPreset.text:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveValidator = validator ?? _defaultValidator;

    final scheme = Theme.of(context).colorScheme;
    final underline = UnderlineInputBorder(
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    final underlineFocused = UnderlineInputBorder(
      borderSide: BorderSide(width: 2, color: scheme.primary),
    );
    final outline = const OutlineInputBorder();
    final outlineFocused = OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: scheme.primary),
    );
    final isUnderline = borderStyle == InputBorderStyle.underline;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: _keyboard(),
      textInputAction: textInputAction,
      inputFormatters: _formatters(),
      maxLength: maxLength,
      onChanged: onChanged,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        counterText: '',
        isDense: true,
        border: isUnderline ? underline : outline,
        enabledBorder: isUnderline ? underline : outline,
        focusedBorder: isUnderline ? underlineFocused : outlineFocused,
      ),
      validator: effectiveValidator,
      textCapitalization: uppercase
      ? TextCapitalization.characters
      : TextCapitalization.none,
    );
  }
}
