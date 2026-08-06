import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../j0_wizard/j0_ui.dart';

/// Champ texte premium (Cairo, arrondi, focus bleu médical) pour la création J0.
class J0TextField extends StatelessWidget {
  const J0TextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
    this.onChangedText,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChangedText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChangedText,
        style: J0Ui.text(
            size: 14, weight: FontWeight.w500, color: EpidemiologyTheme.warm800),
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: J0Ui.text(
              size: 13, weight: FontWeight.w400, color: EpidemiologyTheme.warm300),
          labelStyle: J0Ui.text(
              size: 12, weight: FontWeight.w600, color: EpidemiologyTheme.warm500),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, size: 18, color: EpidemiologyTheme.warm400),
          filled: true,
          fillColor: EpidemiologyTheme.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
            borderSide: const BorderSide(color: EpidemiologyTheme.warm150),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
            borderSide: const BorderSide(color: EpidemiologyTheme.warm150),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
            borderSide: const BorderSide(
                color: EpidemiologyTheme.redPrimary, width: 1.8),
          ),
        ),
      ),
    );
  }
}

/// Ligne oui/non premium avec toggle, pour les éléments de checklist médicale.
class J0ToggleTile extends StatelessWidget {
  const J0ToggleTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.help,
    this.icon,
    this.color = EpidemiologyTheme.redPrimary,
  });

  final String label;
  final String? help;
  final IconData? icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: 0.04) : EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? color.withValues(alpha: 0.35) : EpidemiologyTheme.warm100,
          width: value ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: color),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: J0Ui.text(
                        size: 14,
                        weight: value ? FontWeight.w700 : FontWeight.w600,
                        color: EpidemiologyTheme.warm800,
                      ),
                    ),
                    if (help != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        help!,
                        style: J0Ui.text(
                          size: 11.5,
                          weight: FontWeight.w500,
                          color: EpidemiologyTheme.warm400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: color,
                activeThumbColor: Colors.white,
                inactiveThumbColor: EpidemiologyTheme.warm300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Option d'un choix à pastilles (enum / string).
class J0ChoiceOption<T> {
  final T value;
  final String label;
  final String? help;

  const J0ChoiceOption(this.value, this.label, {this.help});
}

/// Sélecteur premium par pastilles (single-select), très fluide au tactile.
class J0ChoicePills<T> extends StatelessWidget {
  const J0ChoicePills({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.color = EpidemiologyTheme.redPrimary,
  });

  final List<J0ChoiceOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _pill(option, option.value == selected),
      ],
    );
  }

  Widget _pill(J0ChoiceOption<T> option, bool isSelected) {
    return GestureDetector(
      onTap: () => onChanged(option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color : EpidemiologyTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : EpidemiologyTheme.warm150,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Text(
          option.label,
          style: J0Ui.text(
            size: 12.5,
            weight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : EpidemiologyTheme.warm600,
          ),
        ),
      ),
    );
  }
}

/// Ligne d'information en lecture seule (identité, métadonnées).
class J0InfoRow extends StatelessWidget {
  const J0InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final vColor = valueColor ?? EpidemiologyTheme.warm800;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: EpidemiologyTheme.warm50,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: EpidemiologyTheme.warm500),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: J0Ui.text(
                    size: 11,
                    weight: FontWeight.w600,
                    color: EpidemiologyTheme.warm400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: J0Ui.text(
                    size: 13,
                    weight: FontWeight.w700,
                    color: vColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Encadré de note / message clinique coloré.
class J0Note extends StatelessWidget {
  const J0Note({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: J0Ui.text(
                    size: 12.5,
                    weight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: J0Ui.text(
                    size: 12,
                    weight: FontWeight.w500,
                    color: EpidemiologyTheme.warm600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Champ date natif premium (ouvre un sélecteur de date).
class J0DateField extends StatelessWidget {
  const J0DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onPicked,
    this.hint = 'Sélectionner une date',
  });

  final String label;
  final String? value; // ISO 'yyyy-MM-dd'
  final ValueChanged<DateTime> onPicked;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final empty = value == null || value!.isEmpty;
    return _J0PickerField(
      label: label,
      icon: Icons.calendar_today_outlined,
      display: empty ? hint : _safeFormat(value!),
      color: empty
          ? EpidemiologyTheme.warm300
          : EpidemiologyTheme.warm800,
      onTap: () async {
        final now = DateTime.now();
        final parsed = empty ? null : DateTime.tryParse(value!);
        final date = await showDatePicker(
          context: context,
          initialDate: parsed ?? now,
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 60)),
          helpText: label,
          cancelText: 'Annuler',
          confirmText: 'OK',
        );
        if (date != null) onPicked(date);
      },
    );
  }

  String _safeFormat(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }
}

/// Champ heure natif premium (ouvre un sélecteur d'heure).
class J0TimeField extends StatelessWidget {
  const J0TimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onPicked,
    this.hint = 'Sélectionner une heure',
  });

  final String label;
  final String? value; // 'HH:mm'
  final ValueChanged<TimeOfDay> onPicked;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final empty = value == null || value!.isEmpty;
    return _J0PickerField(
      label: label,
      icon: Icons.schedule_outlined,
      display: empty ? hint : value!,
      color: empty
          ? EpidemiologyTheme.warm300
          : EpidemiologyTheme.warm800,
      onTap: () async {
        final parts = (value ?? '').split(':');
        final now = TimeOfDay.now();
        final time = await showTimePicker(
          context: context,
          initialTime: parts.length == 2
              ? TimeOfDay(
                  hour: int.tryParse(parts[0]) ?? now.hour,
                  minute: int.tryParse(parts[1]) ?? now.minute,
                )
              : now,
          helpText: label,
          cancelText: 'Annuler',
          confirmText: 'OK',
        );
        if (time != null) onPicked(time);
      },
    );
  }
}

class _J0PickerField extends StatelessWidget {
  const _J0PickerField({
    required this.label,
    required this.icon,
    required this.display,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String display;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        isEmpty: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: J0Ui.text(
            size: 12, weight: FontWeight.w600,
            color: EpidemiologyTheme.warm500,
          ),
          prefixIcon:
              Icon(icon, size: 18, color: EpidemiologyTheme.warm400),
          suffixIcon: const Icon(Icons.expand_more,
              size: 18, color: EpidemiologyTheme.warm400),
          filled: true,
          fillColor: EpidemiologyTheme.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
            borderSide: const BorderSide(color: EpidemiologyTheme.warm150),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
            borderSide: const BorderSide(color: EpidemiologyTheme.warm150),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
          child: Text(
            display,
            style: J0Ui.text(
              size: 14,
              weight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
