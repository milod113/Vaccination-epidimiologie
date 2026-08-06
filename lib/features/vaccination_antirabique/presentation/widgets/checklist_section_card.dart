import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';

class ChecklistItem {
  final String id;
  final String label;
  final bool value;
  final Color? accentColor;

  const ChecklistItem({
    required this.id,
    required this.label,
    this.value = false,
    this.accentColor,
  });
}

class ChecklistSectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<ChecklistItem> items;
  final ValueChanged<List<ChecklistItem>> onChanged;
  final List<Widget>? extraFields;
  final Color iconColor;

  const ChecklistSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.extraFields,
    this.iconColor = EpidemiologyTheme.redPrimary,
  });

  @override
  State<ChecklistSectionCard> createState() => _ChecklistSectionCardState();
}

class _ChecklistSectionCardState extends State<ChecklistSectionCard>
    with SingleTickerProviderStateMixin {
  late List<ChecklistItem> _items;
  bool _expanded = true;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _items = widget.items.map((e) => e).toList();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(ChecklistSectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = widget.items.map((e) => e).toList();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int get _checkedCount => _items.where((e) => e.value).length;

  void _toggle(int index) {
    final item = _items[index];
    _items[index] = ChecklistItem(
      id: item.id,
      label: item.label,
      value: !item.value,
      accentColor: item.accentColor,
    );
    setState(() {});
    widget.onChanged(List.unmodifiable(_items));
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = _ratio >= 0.75
        ? EpidemiologyTheme.success
        : _ratio >= 0.4
            ? EpidemiologyTheme.warning
            : EpidemiologyTheme.slate300;

    return Container(
      margin: const EdgeInsets.only(bottom: EpidemiologyTheme.spaceMd),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        boxShadow: [
          ...EpidemiologyTheme.shadowSm,
          BoxShadow(
            color: widget.iconColor.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(progressColor),
          SizeTransition(
            sizeFactor: _expandAnimation,
            alignment: Alignment.topCenter,
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color progressColor) {
    return InkWell(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
          if (_expanded) {
            _animController.forward();
          } else {
            _animController.reverse();
          }
        });
      },
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(EpidemiologyTheme.radiusXl),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          EpidemiologyTheme.spaceLg,
          EpidemiologyTheme.spaceMd,
          EpidemiologyTheme.spaceMd,
          EpidemiologyTheme.spaceMd,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _expanded
                  ? EpidemiologyTheme.slate100
                  : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            _iconBadge(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: EpidemiologyTheme.slate900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_checkedCount/${_items.length} élément${_items.length > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: EpidemiologyTheme.slate400,
                    ),
                  ),
                ],
              ),
            ),
            _progressIndicator(progressColor),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.slate50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.expand_more,
                  size: 18,
                  color: EpidemiologyTheme.slate400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBadge() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.iconColor.withValues(alpha: 0.12),
            widget.iconColor.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
        border: Border.all(
          color: widget.iconColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Icon(
        widget.icon,
        size: 20,
        color: widget.iconColor,
      ),
    );
  }

  double get _ratio =>
      _items.isEmpty ? 0.0 : _checkedCount / _items.length;

  Widget _progressIndicator(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _ratio),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: 48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: EpidemiologyTheme.slate100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(value * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        EpidemiologyTheme.spaceLg,
        EpidemiologyTheme.spaceMd,
        EpidemiologyTheme.spaceLg,
        EpidemiologyTheme.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(_items.length, _buildItem),
          if (widget.extraFields != null && widget.extraFields!.isNotEmpty) ...[
            const SizedBox(height: EpidemiologyTheme.spaceMd),
            Divider(
              color: EpidemiologyTheme.slate100,
              height: 1,
              thickness: 1,
            ),
            const SizedBox(height: EpidemiologyTheme.spaceMd),
            ...widget.extraFields!,
          ],
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    final accent = item.accentColor;
    final isChecked = item.value;
    final hasAccent = accent != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggle(index),
          borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
          splashColor:
              (accent ?? widget.iconColor).withValues(alpha: 0.06),
          highlightColor:
              (accent ?? widget.iconColor).withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isChecked
                  ? (accent ?? widget.iconColor).withValues(alpha: 0.04)
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(EpidemiologyTheme.radiusMd),
              border: hasAccent && !isChecked
                  ? Border(
                      left: BorderSide(
                        color: accent.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _animatedCheckbox(isChecked, accent),
                const SizedBox(width: 14),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          isChecked ? FontWeight.w600 : FontWeight.w500,
                      color: isChecked
                          ? EpidemiologyTheme.slate800
                          : EpidemiologyTheme.slate600,
                      decoration: isChecked
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor:
                          EpidemiologyTheme.slate400,
                      decorationThickness: 1.5,
                      height: 1.3,
                    ),
                    child: Text(item.label),
                  ),
                ),
                if (hasAccent && !isChecked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Text(
                      'À vérifier',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedCheckbox(bool checked, Color? accent) {
    final color = accent ?? widget.iconColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: checked ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: checked ? color : EpidemiologyTheme.slate300,
          width: checked ? 0 : 1.8,
        ),
      ),
      child: checked
          ? Center(
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
