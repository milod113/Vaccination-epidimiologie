import 'package:flutter/material.dart';

/// Grille responsive de cartes de modules.
///
/// Sur les écrans larges (>= ~720px) les cartes s'alignent sur deux
/// colonnes ; sur les écrans étroits elles s'empilent verticalement.
class DashboardModuleGrid extends StatelessWidget {
  final List<Widget> modules;
  final EdgeInsetsGeometry padding;

  const DashboardModuleGrid({
    super.key,
    required this.modules,
    this.padding = const EdgeInsets.symmetric(vertical: 18),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 720;
        if (!twoColumns) {
          return Column(
            children: modules
                .map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: m,
                    ))
                .toList(),
          );
        }
        final rows = <Widget>[];
        for (var i = 0; i < modules.length; i += 2) {
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: modules[i]),
              if (i + 1 < modules.length) ...[
                const SizedBox(width: 16),
                Expanded(child: modules[i + 1]),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ));
          if (i + 2 < modules.length) rows.add(const SizedBox(height: 16));
        }
        return Column(children: rows);
      },
    );
  }
}