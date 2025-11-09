import 'package:flutter/material.dart';
import 'package:piesp_patrol/widgets/common_params.dart';


class DropdownBox<T> extends StatelessWidget {
  const DropdownBox({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    this.value,
    this.onChanged,
    this.hint,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.allowClear = false,
    this.borderStyle = InputBorderStyle.underline,
    this.isDense = false,                 // multiline: lepiej NIE dense
    this.autofocus = false,
    this.isExpanded = true,               // rozciągaj w poziomie
    this.maxLines = 3,                    // ile linii widoczne w polu (null = bez limitu)
    this.menuItemMaxLines = 6,            // ile linii w rozwijanym menu
  });

  final String label;
  final List<T> items;
  final String Function(T) itemLabel;

  final T? value;
  final ValueChanged<T?>? onChanged;

  final String? hint;
  final String? Function(T?)? validator;
  final bool enabled;

  final IconData? prefixIcon;
  final bool allowClear;

  final InputBorderStyle borderStyle;
  final bool isDense;
  final bool autofocus;

  /// DropdownButtonFormField.isExpanded — aby tekst mógł się zawijać w polu.
  final bool isExpanded;

  /// Ile linii może mieć WYBRANA pozycja pokazywana w samym polu.
  final int? maxLines;

  /// Ile linii może mieć pozycja w MENU (lista rozwijana).
  final int? menuItemMaxLines;

  @override
  Widget build(BuildContext context) {
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

    // Sufiks „gumka”
    final Widget? suffixClear = allowClear && value != null && enabled
        ? IconButton(
            tooltip: 'Wyczyść',
            icon: const Icon(Icons.clear),
            onPressed: () => onChanged?.call(null),
          )
        : null;

    // Budowanie WIDOCZNEJ etykiety wybranej pozycji — multiliniowo, bez overflow.
    List<Widget> selectedBuilder(BuildContext ctx) {
      return items.map((e) {
        final label = itemLabel(e);
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: double.infinity, // żeby Text znał szerokość i mógł się zawijać
            child: Text(
              label,
              softWrap: true,
              overflow: TextOverflow.visible, // pozwól rosnąć w pionie
              maxLines: maxLines,
            ),
          ),
        );
      }).toList(growable: false);
    }

    return DropdownButtonFormField<T>(
      initialValue: value,
      autofocus: autofocus,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isDense: isDense,
      isExpanded: isExpanded,     // klucz do braku overflow w prawo
      // Pozwala na zmienną wysokość każdego elementu menu (multiline).
      itemHeight: null,
      // Multiline również dla wyświetlanej, wybranej pozycji.
      selectedItemBuilder: selectedBuilder,
      items: items.map((e) {
        final label = itemLabel(e);
        return DropdownMenuItem<T>(
          value: e,
          // Zawijanie wewnątrz menu
          child: SizedBox(
            width: double.infinity, // żeby znał szerokość
            child: Text(
              label,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: menuItemMaxLines,
            ),
          ),
        );
      }).toList(growable: false),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: isDense,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixClear,
        // odrobinę ciaśniej, ale z miejscem na multi-line
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, maxWidth: 40),
        // Jeśli suffix by „pchał” pole — ogranicz jego szerokość:
        // suffixIconConstraints: const BoxConstraints(maxWidth: 36),
        border: isUnderline ? underline : outline,
        enabledBorder: isUnderline ? underline : outline,
        focusedBorder: isUnderline ? underlineFocused : outlineFocused,
        counterText: '',
      ),
    );
  }
}
