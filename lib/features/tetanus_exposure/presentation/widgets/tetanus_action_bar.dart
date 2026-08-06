import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';

/// Barre d'actions premium (Annuler / Enregistrer brouillon / Valider).
class TetanusActionBar extends StatelessWidget {
  const TetanusActionBar({
    super.key,
    required this.canValidate,
    this.onCancel,
    this.onSaveDraft,
    this.onValidate,
    this.saving = false,
  });

  final bool canValidate;
  final VoidCallback? onCancel;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onValidate;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        border: Border(top: BorderSide(color: EpidemiologyTheme.warm150)),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.blackWith(0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 640;
          if (isWide) {
            return Row(
              children: [
                if (onCancel != null) ...[
                  OutlinedButton(
                    onPressed: onCancel,
                    child: Text('Annuler',
                        style: GoogleFonts.cairo(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                ],
                const Spacer(),
                if (onSaveDraft != null) ...[
                  OutlinedButton.icon(
                    onPressed: onSaveDraft,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text('Enregistrer brouillon',
                        style: GoogleFonts.cairo(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                ],
                FilledButton.icon(
                  onPressed: canValidate ? onValidate : null,
                  icon: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.verified_outlined, size: 18),
                  label: Text(
                    saving ? 'Enregistrement…' : 'Valider l\'évaluation',
                    style: GoogleFonts.cairo(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: EpidemiologyTheme.redPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: EpidemiologyTheme.warm200,
                    disabledForegroundColor: EpidemiologyTheme.warm400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                  ),
                ),
              ],
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onSaveDraft != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSaveDraft,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text('Enregistrer brouillon',
                        style: GoogleFonts.cairo(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Annuler',
                            style: GoogleFonts.cairo(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (onCancel != null) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: canValidate ? onValidate : null,
                      icon: saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.verified_outlined, size: 18),
                      label: Text(
                        saving ? 'Enregistrement…' : 'Valider l\'évaluation',
                        style: GoogleFonts.cairo(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: EpidemiologyTheme.redPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: EpidemiologyTheme.warm200,
                        disabledForegroundColor: EpidemiologyTheme.warm400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}