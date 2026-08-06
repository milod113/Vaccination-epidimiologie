import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';

class TetanusChecklistScreen extends StatefulWidget {
  const TetanusChecklistScreen({super.key});

  @override
  State<TetanusChecklistScreen> createState() => _TetanusChecklistScreenState();
}

class _TetanusChecklistScreenState extends State<TetanusChecklistScreen> {
  final _sections = <_CheckSection>[
    _CheckSection('Type de plaie', Icons.healing_rounded, false, [
      _CheckItem('Plaie superficielle propre'),
      _CheckItem('Plaie modérée / contaminée'),
      _CheckItem('Plaie tétanigène (profonde, souillée, corps étranger)'),
    ]),
    _CheckSection('Délai et soins', Icons.timer_outlined, false, [
      _CheckItem('Délai < 6h'),
      _CheckItem('Délai 6-24h'),
      _CheckItem('Délai > 24h'),
      _CheckItem('Soins locaux réalisés'),
    ]),
    _CheckSection('Statut vaccinal', Icons.vaccines_outlined, false, [
      _CheckItem('Carnet de vaccination présent'),
      _CheckItem('Patient à jour (> 3 doses, dernier rappel < 5 ans)'),
      _CheckItem('Schéma incomplet (< 3 doses ou rappel > 5 ans)'),
      _CheckItem('Statut inconnu / non documenté'),
      _CheckItem('Non vacciné'),
    ]),
    _CheckSection('Contexte clinique', Icons.person_outline, false, [
      _CheckItem('Patient immunodéprimé'),
      _CheckItem('Grossesse en cours'),
      _CheckItem('Allergie connue au VAT'),
      _CheckItem('Antécédent de tétanos'),
    ]),
    _CheckSection('Décision', Icons.medical_information_outlined, false, [
      _CheckItem('Simple surveillance'),
      _CheckItem('Rappel VAT indiqué'),
      _CheckItem('Initier schéma vaccinal complet'),
      _CheckItem('VAT + Immunoglobulines'),
      _CheckItem('Avis spécialisé requis'),
    ]),
    _CheckSection('Suivi', Icons.follow_the_signs_rounded, false, [
      _CheckItem('Plan de suivi établi'),
      _CheckItem('Programmation rappel J+7'),
      _CheckItem('Programmation rappel J+30'),
      _CheckItem('Information patient délivrée'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final totalChecked =
        _sections.expand((s) => s.items).where((i) => i.checked).length;
    final totalItems = _sections.expand((s) => s.items).length;
    final ratio = totalItems > 0 ? totalChecked / totalItems : 0.0;

    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: EpidemiologyTheme.warm700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Checklist initiale'),
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(
            bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1)),
      ),
      body: Column(
        children: [
          _buildProgressHeader(ratio, totalChecked, totalItems),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                ..._sections.asMap().entries.map((e) => _buildSection(e.value)),
              ],
            ),
          ),
          _buildBottomBar(ratio, totalChecked, totalItems),
        ],
      ),
    );
  }

  // ── Progress Header ──

  Widget _buildProgressHeader(double ratio, int checked, int total) {
    final progressColor = ratio >= 0.75
        ? EpidemiologyTheme.success
        : ratio >= 0.4
            ? EpidemiologyTheme.warning
            : EpidemiologyTheme.amber;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      color: EpidemiologyTheme.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.checklist_rounded,
                size: 20, color: progressColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progression',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: EpidemiologyTheme.warm500,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: EpidemiologyTheme.warm100,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 7,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$checked/$total',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: progressColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section ──

  Widget _buildSection(_CheckSection section) {
    final checked = section.items.where((i) => i.checked).length;
    final total = section.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.amber.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => section.expanded = !section.expanded),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          EpidemiologyTheme.amber.withValues(alpha: 0.12),
                          EpidemiologyTheme.orange.withValues(alpha: 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(section.icon,
                        size: 20, color: EpidemiologyTheme.amber),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: EpidemiologyTheme.warm800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$checked/$total éléments',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: EpidemiologyTheme.warm400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: checked == total
                          ? EpidemiologyTheme.success.withValues(alpha: 0.1)
                          : EpidemiologyTheme.warm50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      checked == total
                          ? 'Complet'
                          : '${(checked / total * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: checked == total
                            ? EpidemiologyTheme.success
                            : EpidemiologyTheme.warm400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    section.expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 22,
                    color: EpidemiologyTheme.warm400,
                  ),
                ],
              ),
            ),
          ),
          if (section.expanded)
            ...section.items.map((item) => _buildCheckItem(item)),
        ],
      ),
    );
  }

  // ── Premium Check Item ──

  Widget _buildCheckItem(_CheckItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => item.checked = !item.checked),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: EpidemiologyTheme.warm100, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.checked
                      ? EpidemiologyTheme.amber
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: item.checked
                        ? EpidemiologyTheme.amber
                        : EpidemiologyTheme.warm300,
                    width: item.checked ? 0 : 1.8,
                  ),
                ),
                child: item.checked
                    ? Center(
                        child: Icon(Icons.check_rounded,
                            size: 16, color: Colors.white))
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        item.checked ? FontWeight.w600 : FontWeight.w500,
                    color: item.checked
                        ? EpidemiologyTheme.warm600
                        : EpidemiologyTheme.warm700,
                    decoration: item.checked
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: EpidemiologyTheme.warm400,
                    decorationThickness: 1.5,
                  ),
                ),
              ),
              if (item.checked)
                Icon(Icons.check_circle_rounded,
                    size: 18, color: EpidemiologyTheme.amber.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Bar ──

  Widget _buildBottomBar(double ratio, int totalChecked, int totalItems) {
    final isComplete = totalChecked == totalItems;
    final summaryText = _getSummaryText();

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        border: Border(
            top: BorderSide(color: EpidemiologyTheme.warm100)),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.warm200.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (summaryText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EpidemiologyTheme.amber.withValues(alpha: 0.06),
                      EpidemiologyTheme.orange.withValues(alpha: 0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: EpidemiologyTheme.amber.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.summarize_rounded,
                        size: 16, color: EpidemiologyTheme.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        summaryText,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          height: 1.5,
                          color: EpidemiologyTheme.warm700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isComplete ? () {} : null,
                icon: isComplete
                    ? Icon(Icons.save_rounded, size: 18)
                    : Icon(Icons.lock_outline, size: 18),
                label: Text(
                  isComplete
                      ? 'Enregistrer la fiche'
                      : 'Complétez tous les champs',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: EpidemiologyTheme.amber,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: EpidemiologyTheme.warm200,
                  disabledForegroundColor: EpidemiologyTheme.warm400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSummaryText() {
    final wound = _sections[0]
        .items
        .where((i) => i.checked)
        .map((i) => i.label)
        .join(', ');
    final vaccin = _sections[2]
        .items
        .where((i) => i.checked)
        .map((i) => i.label)
        .join(', ');
    final decision = _sections[4]
        .items
        .where((i) => i.checked)
        .map((i) => i.label)
        .join(', ');
    final parts = <String>[];
    if (wound.isNotEmpty) parts.add('Plaie: $wound');
    if (vaccin.isNotEmpty) parts.add('Vaccin: $vaccin');
    if (decision.isNotEmpty) parts.add('Décision: $decision');
    return parts.join(' | ');
  }
}

class _CheckSection {
  final String title;
  final IconData icon;
  bool expanded;
  final List<_CheckItem> items;
  _CheckSection(this.title, this.icon, this.expanded, this.items);
}

class _CheckItem {
  final String label;
  bool checked = false;
  _CheckItem(this.label);
}
