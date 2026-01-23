import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/routes/app_routes.dart';
import 'package:agri_alert/widgets/auth_text_field.dart';
import 'package:agri_alert/widgets/orange_button.dart';
import 'location_picker_screen.dart';

import 'package:agri_alert/models/enums.dart';
import 'package:agri_alert/models/region.dart';

import 'package:agri_alert/config/app_config.dart';
import 'package:agri_alert/services/api_client.dart';

class CreateChampScreen extends StatefulWidget {
  const CreateChampScreen({super.key});

  @override
  State<CreateChampScreen> createState() => _CreateChampScreenState();
}

class _CreateChampScreenState extends State<CreateChampScreen> {
  final _nomChampController = TextEditingController();
  final _regionController = TextEditingController();
  final _locationController = TextEditingController();
  final _culturesController = TextEditingController();
  final _superficieController = TextEditingController();

  Region? _selectedRegion;
  LatLng? _selectedLatLng;

  final Set<NomCulture> _selectedCultures = {};
  final Map<NomCulture, ActiviteType> _activiteParCulture = {};

  bool _loading = false;

  // ✅ régions venant du backend
  List<Region> _regions = [];

  // ✅ mapping culture enum -> uuid culture DB
  final Map<NomCulture, String> _cultureUuid = {};

  final _api = ApiClient(baseUrl: AppConfig.baseUrl);
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadRegions();
    _loadCultures();
  }

  @override
  void dispose() {
    _nomChampController.dispose();
    _regionController.dispose();
    _locationController.dispose();
    _culturesController.dispose();
    _superficieController.dispose();
    super.dispose();
  }

  // ---------------------------
  // API LOADERS
  // ---------------------------

  Future<void> _loadRegions() async {
    try {
      final res = await _api.get('/api/regions');
      final list = (res['regions'] as List<dynamic>? ?? []);

      setState(() {
        _regions = list
            .map((e) => Region(
                  id: e['id'].toString(),
                  nom: e['name'].toString(),
                ))
            .toList();
      });
    } catch (_) {
      // Optionnel: SnackBar
    }
  }

  Future<void> _loadCultures() async {
    try {
      final res = await _api.get('/api/cultures');
      final list = (res['cultures'] as List<dynamic>? ?? []);

      _cultureUuid.clear();

      for (final e in list) {
        final id = e['id']?.toString();
        final nom = e['nom']?.toString();
        if (id == null || nom == null) continue;

        final enumVal = _toNomCulture(nom);
        if (enumVal != null) {
          _cultureUuid[enumVal] = id;
        }
      }

      // Nettoyage : si l'utilisateur avait déjà sélectionné des cultures avant chargement
      _selectedCultures.removeWhere((c) => !_cultureUuid.containsKey(c));
      _activiteParCulture.removeWhere((c, _) => !_cultureUuid.containsKey(c));

      setState(() {});
    } catch (_) {
      // Optionnel: SnackBar
    }
  }

  // ---------------------------
  // HELPERS
  // ---------------------------

  NomCulture? _toNomCulture(String nom) {
    // Normalisation simple (minuscules + enlever espaces)
    final n = nom.trim().toLowerCase();

    if (n == 'tomate') return NomCulture.tomate;

    if (n == 'pomme de terre' || n == 'pommedeterre' || n == 'pomme_de_terre') {
      return NomCulture.pommeDeTerre;
    }

    if (n == 'citron') return NomCulture.citron;

    if (n == 'orange') return NomCulture.orange;

    // Si ton enum Flutter contient mangue:
    try {
      if (n == 'mangue') return NomCulture.mangue;
    } catch (_) {}

    if (n == 'poivre') return NomCulture.poivre;

    if (n == 'fraise') return NomCulture.fraise;

    if (n == 'raisin') return NomCulture.raisin;

    if (n == 'papaye') return NomCulture.papaye;

    if (n == 'pomme') return NomCulture.pomme;


    return null;
  }

  String _cultureLabel(NomCulture c) {
    switch (c) {
      case NomCulture.pommeDeTerre:
        return 'Pomme de terre';
      case NomCulture.citron:
        return 'Citron';
      case NomCulture.orange:
        return 'Orange';
      case NomCulture.poivre:
        return 'Poivre';
      case NomCulture.fraise:
        return 'Fraise';
      case NomCulture.raisin:
        return 'Raisin';
      case NomCulture.papaye:
        return 'Papaye';
      case NomCulture.pomme:
        return 'Pomme';
      case NomCulture.tomate:
        return 'Tomate';
      default:
        // si ton enum contient mangue
        return 'Culture';
    }
  }

  String _activiteLabel(ActiviteType a) {
    switch (a) {
      case ActiviteType.semis:
        return 'Sémis';
      case ActiviteType.recolte:
        return 'Récolte';
      case ActiviteType.traitement:
        return 'Traitement';
    }
  }

  String _activiteToBackend(ActiviteType a) {
    switch (a) {
      case ActiviteType.semis:
        return 'Semis';
      case ActiviteType.recolte:
        return 'Recolte';
      case ActiviteType.traitement:
        return 'Traitement';
    }
  }

  // ---------------------------
  // PICKERS UI
  // ---------------------------

  Future<void> _pickRegion() async {
    if (_regions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Régions non chargées. Vérifie /api/regions.")),
      );
      return;
    }

    final Region? picked = await showModalBottomSheet<Region>(
      context: context,
      backgroundColor: AppColors.gris2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Région', style: AppTextStyles.titre1),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _regions.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      color: AppColors.gris1,
                    ),
                    itemBuilder: (context, index) {
                      final r = _regions[index];
                      final selected = _selectedRegion?.id == r.id;

                      return ListTile(
                        title: Text(r.nom, style: AppTextStyles.textnoir),
                        trailing: Icon(
                          selected ? Icons.check_circle : Icons.circle_outlined,
                          color: selected ? AppColors.vert : AppColors.gris1,
                        ),
                        onTap: () => Navigator.pop(ctx, r),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedRegion = picked;
        _regionController.text = picked.nom;
      });
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? picked = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );

    if (picked != null) {
      setState(() {
        _selectedLatLng = picked;
        _locationController.text =
            'Longitude: ${picked.longitude.toStringAsFixed(6)}, Latitude: ${picked.latitude.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _pickCultures() async {
    // On affiche seulement les cultures que le backend connaît (uuid présent)
    final available = NomCulture.values.where((c) => _cultureUuid.containsKey(c)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cultures non chargées. Vérifie /api/cultures.")),
      );
      return;
    }

    final current = Set<NomCulture>.from(_selectedCultures);

    final Set<NomCulture>? picked = await showModalBottomSheet<Set<NomCulture>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.gris2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  14 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Type de culture', style: AppTextStyles.titre1),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Sélectionnez une ou plusieurs cultures'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: available.map((c) {
                        final selected = current.contains(c);
                        return FilterChip(
                          label: Text(_cultureLabel(c), style: AppTextStyles.textnoir),
                          selected: selected,
                          onSelected: (v) {
                            setModalState(() {
                              v ? current.add(c) : current.remove(c);
                            });
                          },
                          selectedColor: AppColors.vert,
                          checkmarkColor: AppColors.gris2,
                          backgroundColor: AppColors.gris1,
                          side: BorderSide(color: AppColors.gris1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    OrangeButton(
                      label: 'Valider',
                      onPressed: () => Navigator.pop(ctx, current),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedCultures
          ..clear()
          ..addAll(picked);

        _culturesController.text = _selectedCultures.map(_cultureLabel).join(', ');

        for (final c in _selectedCultures) {
          _activiteParCulture.putIfAbsent(c, () => ActiviteType.semis);
        }

        _activiteParCulture.removeWhere((c, _) => !_selectedCultures.contains(c));
      });
    }
  }

  Widget _tapField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.textnoir),
        const SizedBox(height: 8),
        AuthTextField(
          hintText: hint,
          controller: controller,
          readOnly: true,
          showCursor: false,
          onTap: onTap,
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ],
    );
  }

  Widget _portionAg() {
    if (_selectedCultures.isEmpty) return const SizedBox.shrink();

    final culturesList = _selectedCultures.toList()
      ..sort((a, b) => _cultureLabel(a).compareTo(_cultureLabel(b)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.gris2,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Activité Agricole', style: AppTextStyles.textnoir),
              const SizedBox(height: 12),
              ...culturesList.map((c) {
                final selected = _activiteParCulture[c] ?? ActiviteType.semis;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_cultureLabel(c), style: AppTextStyles.textnoir),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: ActiviteType.values.map((a) {
                          final isSelected = a == selected;
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _activiteParCulture[c] = a),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.vert : AppColors.jaune,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(_activiteLabel(a), style: AppTextStyles.textnoir),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------
  // SUBMIT (Step2 then activities)
  // ---------------------------

  Future<void> _submit(String sessionId) async {
    final nomChamp = _nomChampController.text.trim();
    final aireTxt = _superficieController.text.trim();

    if (nomChamp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez saisir le nom du champ.")),
      );
      return;
    }
    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une région.")),
      );
      return;
    }
    if (_selectedCultures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir au moins une culture.")),
      );
      return;
    }

    // Aire (m²)
    final aire = double.tryParse(aireTxt.replaceAll(',', '.'));

    // ✅ payload plantations SANS activities
    final plantationsPayload = _selectedCultures.map((c) {
      return {
        "culture_id": _cultureUuid[c],
        "date_debut": DateTime.now().toIso8601String().substring(0, 10),
      };
    }).toList();

    setState(() => _loading = true);

    try {
      // 1) STEP2 : champ + plantations
      final res = await _api.post(
        '/api/auth/register/agriculteur/step2',
        body: {
          "registration_session_id": sessionId,
          "nom": nomChamp,
          "latitude": _selectedLatLng?.latitude,
          "longitude": _selectedLatLng?.longitude,
          "aire": aire,
          "region_id": _selectedRegion!.id,
          "plantations": plantationsPayload,
        },
      );

      final token = res['access_token'] as String?;
      if (token == null || token.isEmpty) throw Exception("access_token manquant.");

      await _storage.write(key: 'access_token', value: token);

      // 2) créer les activités via endpoint existant
      final plantations = (res['plantations'] as List<dynamic>? ?? []);

      for (final p in plantations) {
        final plantationId = p['id']?.toString();
        if (plantationId == null) continue;

        final cultureId = p['culture_id']?.toString() ?? p['culture']?['id']?.toString();
        if (cultureId == null) continue;

        final cultureEntry =
            _cultureUuid.entries.where((e) => e.value == cultureId).toList();
        if (cultureEntry.isEmpty) continue;

        final cultureEnum = cultureEntry.first.key;
        final act = _activiteParCulture[cultureEnum] ?? ActiviteType.semis;

        await _api.post(
          '/api/plantations/$plantationId/activites',
          headers: {'Authorization': 'Bearer $token'},
          body: {
            "type": _activiteToBackend(act),
            "done_at": DateTime.now().toIso8601String(),
          },
        );
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.accueil, (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur création champ: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------
  // BUILD
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    final sessionId = ModalRoute.of(context)?.settings.arguments as String?;
    if (sessionId == null || sessionId.isEmpty) {
      return const Scaffold(body: Center(child: Text("Session d'inscription manquante.")));
    }

    return Scaffold(
      backgroundColor: AppColors.blanc,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gris1),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Créez votre champ',
                      style: AppTextStyles.titre1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 18),

              Text('Nom du champ', style: AppTextStyles.textnoir),
              const SizedBox(height: 8),
              AuthTextField(
                hintText: 'Entrez le nom de votre champ',
                controller: _nomChampController,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 14),

              _tapField(
                label: 'Région',
                hint: 'Choisissez votre région',
                controller: _regionController,
                onTap: _pickRegion,
              ),

              const SizedBox(height: 14),

              _tapField(
                label: 'Location',
                hint: 'Choisissez votre location',
                controller: _locationController,
                onTap: _pickLocation,
              ),

              const SizedBox(height: 14),

              _tapField(
                label: 'Type de culture',
                hint: 'Choisissez vos types de culture',
                controller: _culturesController,
                onTap: _pickCultures,
              ),

              _portionAg(),

              const SizedBox(height: 14),

              Text('Superficie', style: AppTextStyles.textnoir),
              const SizedBox(height: 8),
              AuthTextField(
                hintText: 'Entrez votre superficie (m²)',
                controller: _superficieController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 18),

              OrangeButton(
                label: _loading ? "..." : 'Continuer',
                onPressed: _loading ? null : () => _submit(sessionId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
