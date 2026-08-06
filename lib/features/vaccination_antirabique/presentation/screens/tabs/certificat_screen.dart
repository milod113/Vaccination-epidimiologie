import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tracabilite/certificat_model.dart';
import '../../../domain/services/certificat_service.dart';
import '../../../../../injection_container.dart' as di;

class CertificatScreen extends StatefulWidget {
  final String patientId;
  final String patientNom;

  const CertificatScreen({
    super.key,
    required this.patientId,
    required this.patientNom,
  });

  @override
  State<CertificatScreen> createState() => _CertificatScreenState();
}

class _CertificatScreenState extends State<CertificatScreen> {
  CertificatModel? _certificat;
  String? _html;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generer();
  }

  Future<void> _generer() async {
    final service = di.sl<CertificatService>();
    final c = await service.genererCertificat(widget.patientId);
    final html = await service.genererHtml(c);
    setState(() {
      _certificat = c;
      _html = html;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.slate50,
      appBar: AppBar(
        title: Text('Certificat vaccinal', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        foregroundColor: EpidemiologyTheme.slate900,
        elevation: 0,
        actions: [
          if (_html != null)
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Imprimer',
              onPressed: () async {
                final pdf = await Printing.convertHtml(html: _html!);
                await Printing.layoutPdf(onLayout: (_) async => pdf);
              },
            ),
          if (_html != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Télécharger PDF',
              onPressed: () async {
                final pdf = await Printing.convertHtml(html: _html!);
                await Printing.sharePdf(
                  bytes: pdf,
                  filename: 'certificat_antirabique_${widget.patientNom.replaceAll(' ', '_')}.pdf',
                );
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _certificat == null
              ? const Center(child: Text('Erreur de génération'))
              : _html == null
                  ? const Center(child: Text('Erreur HTML'))
                  : _buildPreview(),
    );
  }

  Widget _buildPreview() {
    return Padding(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
      child: Container(
        decoration: BoxDecoration(
          color: EpidemiologyTheme.white,
          borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
          boxShadow: EpidemiologyTheme.shadowLg,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: EpidemiologyTheme.primaryGradient),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.white, size: 28),
                    const SizedBox(width: EpidemiologyTheme.spaceMd),
                    Text('Aperçu du certificat', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _certificat!.estComplet ? 'Complet' : 'Partiel',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('RÉPUBLIQUE ALGÉRIENNE DÉMOCRATIQUE ET POPULAIRE', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: EpidemiologyTheme.redPrimary)),
                            const SizedBox(height: 4),
                            Text("Ministère de la Santé · Service d'Épidémiologie", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: EpidemiologyTheme.slate500)),
                            const SizedBox(height: 4),
                            Text(_certificat!.centre, textAlign: TextAlign.center, style: EpidemiologyTheme.caption()),
                            const SizedBox(height: EpidemiologyTheme.spaceLg),
                            Container(height: 2, color: EpidemiologyTheme.redPrimary),
                            const SizedBox(height: EpidemiologyTheme.spaceMd),
                            Text('CERTIFICAT DE VACCINATION ANTIRABIQUE', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: EpidemiologyTheme.redPrimary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: EpidemiologyTheme.spaceXxl),
                      _infoTable(),
                      const SizedBox(height: EpidemiologyTheme.spaceXxl),
                      Text('Doses administrées', style: EpidemiologyTheme.subtitle()),
                      const SizedBox(height: EpidemiologyTheme.spaceSm),
                      ..._certificat!.doses.map((d) => _doseRow(d)),
                      if (_certificat!.observations != null) ...[
                        const SizedBox(height: EpidemiologyTheme.spaceLg),
                        Text('Observations : ${_certificat!.observations}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: EpidemiologyTheme.slate600, fontStyle: FontStyle.italic)),
                      ],
                      const SizedBox(height: EpidemiologyTheme.spaceXxxl),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 1, width: 200, color: EpidemiologyTheme.slate900),
                                const SizedBox(height: 4),
                                Text('Cachet et signature du médecin responsable', style: EpidemiologyTheme.caption()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: EpidemiologyTheme.spaceXxl),
                      Text('Document émis le ${_certificat!.dateEmission} — ${_certificat!.medecinResponsable}', style: EpidemiologyTheme.caption()),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.slate50,
                  border: Border(top: BorderSide(color: EpidemiologyTheme.slate100)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          final pdf = await Printing.convertHtml(html: _html!);
                          await Printing.layoutPdf(onLayout: (_) async => pdf);
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Imprimer'),
                        style: FilledButton.styleFrom(
                          backgroundColor: EpidemiologyTheme.redPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final pdf = await Printing.convertHtml(html: _html!);
                          await Printing.sharePdf(
                            bytes: pdf,
                            filename: 'certificat_antirabique_${widget.patientNom.replaceAll(' ', '_')}.pdf',
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: EpidemiologyTheme.slate700,
                          side: const BorderSide(color: EpidemiologyTheme.slate200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTable() {
    return Column(
      children: [
        _infoRow('Patient', '${_certificat!.patientNom} (${_certificat!.patientAge} ans)'),
        _infoRow("Date d'exposition", _certificat!.dateExposition),
        _infoRow("Type d'exposition", _certificat!.typeExposition),
        _infoRow('Catégorie', _certificat!.categorieExposition),
        _infoRow('Protocole', _certificat!.protocole),
        if (_certificat!.rigAdministree)
          _infoRow('Immunoglobulines (RIG)', 'Administrées · Lot: ${_certificat!.rigLot ?? "N/R"}'),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: EpidemiologyTheme.slate100))),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: EpidemiologyTheme.caption())),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: EpidemiologyTheme.slate900))),
        ],
      ),
    );
  }

  Widget _doseRow(DoseCertificat dose) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.successLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
        border: Border.all(color: EpidemiologyTheme.successLight),
      ),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [EpidemiologyTheme.success, EpidemiologyTheme.successDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: EpidemiologyTheme.success.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.check, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Dose ${dose.numeroDose} — ${dose.dateAdministration}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EpidemiologyTheme.slate900)),
                Text('Lot: ${dose.numeroLot} · Par: ${dose.administrateur} · Voie: ${dose.voie}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: EpidemiologyTheme.slate500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
