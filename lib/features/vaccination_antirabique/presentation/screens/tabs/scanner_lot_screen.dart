import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tracabilite/lot_vaccin_model.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../../../injection_container.dart' as di;

class ScannerLotScreen extends StatefulWidget {
  final void Function(LotVaccinModel lot)? onLotScanned;

  const ScannerLotScreen({super.key, this.onLotScanned});

  @override
  State<ScannerLotScreen> createState() => _ScannerLotScreenState();
}

class _ScannerLotScreenState extends State<ScannerLotScreen> {
  MobileScannerController? _controller;
  final bool _scanning = true;
  bool _found = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_scanning || _found) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    _found = true;
    _lookupLot(barcode!.rawValue!);
  }

  Future<void> _lookupLot(String code) async {
    final repo = di.sl<StockRepository>();
    LotVaccinModel? lot;
    try {
      lot = await repo.getLotByNumero(code.trim());
    } catch (_) {}
    if (!mounted) return;
    if (lot != null) {
      _showResult(lot, true);
    } else {
      _showError(code);
    }
  }

  void _showResult(LotVaccinModel lot, bool found) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl)),
        title: Row(
          children: [
            Icon(found ? Icons.check_circle : Icons.error, color: found ? EpidemiologyTheme.success : EpidemiologyTheme.danger),
            const SizedBox(width: 8),
            Text(found ? 'Lot trouvé' : 'Lot introuvable', style: EpidemiologyTheme.h3()),
          ],
        ),
        content: found ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _resultRow('Lot', lot.numeroLot),
            _resultRow('Vaccin', lot.vaccinNom),
            _resultRow('Fabricant', lot.fabricant),
            _resultRow('Expiration', lot.dateExpiration),
            _resultRow('Stock', '${lot.quantiteRestante}/${lot.quantiteInitiale}'),
            _resultRow('Statut', lot.statut.label),
            if (lot.estExpire)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: EpidemiologyTheme.dangerLight,
                    borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusSm),
                    border: Border.all(color: EpidemiologyTheme.dangerLight),
                  ),
                  child: Row(children: [
                    Icon(Icons.warning, size: 16, color: EpidemiologyTheme.danger),
                    const SizedBox(width: 6),
                    Text('Lot expiré — Ne pas utiliser', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: EpidemiologyTheme.danger)),
                  ]),
                ),
              ),
          ],
        ) :                         Text('Aucun lot trouvé pour ce code', style: EpidemiologyTheme.body()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() { _found = false; });
            },
            child: const Text('Nouveau scan'),
          ),
          if (found)
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onLotScanned?.call(lot);
                Navigator.of(context).pop(lot);
              },
              style: FilledButton.styleFrom(
                backgroundColor: EpidemiologyTheme.redPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
              ),
              child: const Text('Utiliser ce lot'),
            )
          else
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: EpidemiologyTheme.slate400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
              ),
              child: const Text('Fermer'),
            ),
        ],
      ),
    );
  }

  void _showError(String code) {
    _showResult(LotVaccinModel(
      id: '',
      numeroLot: code,
      vaccinNom: '',
      fabricant: '',
      dateFabrication: '',
      dateExpiration: '',
      quantiteInitiale: 0,
      quantiteRestante: 0,
    ), false);
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text('$label : ', style: EpidemiologyTheme.label()),
          Expanded(child: Text(value, style: EpidemiologyTheme.label(color: EpidemiologyTheme.slate900))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.slate900,
      appBar: AppBar(
        title: Text('Scanner un lot', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller?.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(EpidemiologyTheme.radiusXxl)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: EpidemiologyTheme.slate200, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: EpidemiologyTheme.spaceLg),
                Icon(Icons.qr_code_scanner, size: 44, color: EpidemiologyTheme.redPrimary),
                const SizedBox(height: EpidemiologyTheme.spaceSm),
                Text('Scannez le QR code du lot', style: EpidemiologyTheme.h3()),
                const SizedBox(height: EpidemiologyTheme.spaceXs),
                Text('Placez le code-barres dans le cadre', style: EpidemiologyTheme.bodySm()),
                const SizedBox(height: EpidemiologyTheme.spaceLg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Annuler'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EpidemiologyTheme.slate500,
                      side: const BorderSide(color: EpidemiologyTheme.slate200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg)),
                    ),
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
