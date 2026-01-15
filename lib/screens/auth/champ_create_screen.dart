import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/widgets/auth_text_field.dart';
import 'package:agri_alert/widgets/orange_button.dart';
import 'location_picker_screen.dart';
import 'package:agri_alert/models/enums.dart';
import 'package:agri_alert/models/region.dart';

class CreateChampScreen extends StatefulWidget {
  const CreateChampScreen({super.key});

  @override
  State<CreateChampScreen> createState() => _CreateChampScreenState();
}

class _CreateChampScreenState extends State<CreateChampScreen> {
  // Champs
  final _nomChampController = TextEditingController();
  final _regionController = TextEditingController();
  final _locationController = TextEditingController();
  final _culturesController = TextEditingController();
  final _superficieController = TextEditingController();

  // Données
  Region? _selectedRegion;
  LatLng? _selectedLatLng;

  final Set<NomCulture> _selectedCultures = {};

  final Map<NomCulture, ActiviteType> _activiteParCulture = {};

  // Toutes les régions du Mali (liste standard + Bamako + Taoudénit + Ménaka)
  static const List<Region> _regionsMali = [
    Region(id: 'bamako', nom: 'District de Bamako'),
    Region(id: 'kayes', nom: 'Kayes'),
    Region(id: 'koulikoro', nom: 'Koulikoro'),
    Region(id: 'sikasso', nom: 'Sikasso'),
    Region(id: 'segou', nom: 'Ségou'),
    Region(id: 'mopti', nom: 'Mopti'),
    Region(id: 'tombouctou', nom: 'Tombouctou'),
    Region(id: 'gao', nom: 'Gao'),
    Region(id: 'kidal', nom: 'Kidal'),
    Region(id: 'taoudenit', nom: 'Taoudénit'),
    Region(id: 'menaka', nom: 'Ménaka'),
  ];

  @override
  void dispose() {
    _nomChampController.dispose();
    _regionController.dispose();
    _locationController.dispose();
    _culturesController.dispose();
    _superficieController.dispose();
    super.dispose();
  }

  String _cultureLabel(NomCulture c) {
    switch (c) {
      case NomCulture.riz:
        return 'Riz';
      case NomCulture.mais:
        return 'Maïs';
      case NomCulture.mil:
        return 'Mil';
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
      case NomCulture.sorgho:
        return 'Sorgho';
      case NomCulture.pomme:
        return 'Pomme';
      case NomCulture.tomate:
        return 'Tomate';
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

  Future<void> _pickRegion() async {
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
                    itemCount: _regionsMali.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      color: AppColors.gris1,
                    ),
                    itemBuilder: (context, index) {
                      final r = _regionsMali[index];
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
      MaterialPageRoute(
        builder: (_) => const LocationPickerScreen(),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedLatLng = picked;
        // demandé: remplir par longitude et latitude
        _locationController.text =
            'Longitude: ${picked.longitude.toStringAsFixed(6)}, Latitude: ${picked.latitude.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _pickCultures() async {
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sélectionnez une ou plusieurs cultures',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: NomCulture.values.map((c) {
                        final selected = current.contains(c);
                        return FilterChip(
                          label: Text(_cultureLabel(c), style: AppTextStyles.textnoir),
                          selected: selected,
                          onSelected: (v) {
                            setModalState(() {
                              if (v) {
                                current.add(c);
                              } else {
                                current.remove(c);
                              }
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

        // Met à jour le champ texte (affichage)
        _culturesController.text =
            _selectedCultures.map(_cultureLabel).join(', ');

        // Assure une activité par culture sélectionnée (default: semis)
        for (final c in _selectedCultures) {
          _activiteParCulture.putIfAbsent(c, () => ActiviteType.semis);
        }

        // Nettoie les activités des cultures supprimées
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
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          readOnly: true,
          showCursor: false,
          onTap: onTap,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
          ),
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
                            onTap: () {
                              setState(() {
                                _activiteParCulture[c] = a;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.vert : AppColors.jaune,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _activiteLabel(a),
                                style: AppTextStyles.textnoir,  
                              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanc,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar (back + title centré comme sur la maquette)
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
                      child: Icon(
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
                  const SizedBox(width: 48), // équilibre visuel
                ],
              ),

              const SizedBox(height: 18),

              // Nom du champ
              Text('Nom du champ', style: AppTextStyles.textnoir),
              const SizedBox(height: 8),
              AuthTextField(
                hintText: 'Entrez le nom de votre champ',
                controller: _nomChampController,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 14),

              // Région
              _tapField(
                label: 'Région',
                hint: 'Choisissez votre région',
                controller: _regionController,
                onTap: _pickRegion,
              ),

              const SizedBox(height: 14),

              // Location (map)
              _tapField(
                label: 'Location',
                hint: 'Choisissez votre location',
                controller: _locationController,
                onTap: _pickLocation,
              ),

              const SizedBox(height: 14),

              // Type de culture (multi)
              _tapField(
                label: 'Type de culture',
                hint: 'Choisissez vos types de culture',
                controller: _culturesController,
                onTap: _pickCultures,
              ),

              // Portion AG (dynamique)
              _portionAg(),

              const SizedBox(height: 14),

              // Superficie
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
                label: 'Continuer',
                onPressed: () {
                  // TODO: action "Continuer"
                  // Exemple: tu peux valider ici puis naviguer vers la suite
                  // (je te laisse brancher à ton flow)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
