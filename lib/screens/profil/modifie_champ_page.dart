import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/widgets/auth_text_field.dart';
import 'package:agri_alert/widgets/orange_button.dart';
import 'package:agri_alert/models/enums.dart';
import 'package:agri_alert/models/region.dart';
import 'package:agri_alert/screens/auth/location_picker_screen.dart';
import 'package:agri_alert/services/api_client.dart';
import 'package:agri_alert/services/profile_service.dart';
import 'package:agri_alert/config/app_config.dart';

class ModifieChampPage extends StatefulWidget {
  const ModifieChampPage({super.key});

  @override
  State<ModifieChampPage> createState() => _ModifieChampScreenState();
}

class _ModifieChampScreenState extends State<ModifieChampPage> {
  // Services & Storage
  final _storage = const FlutterSecureStorage();
  final ProfileService _profileService = ProfileService();
  late ApiClient _apiClient;

  // Contrôleurs
  final _nomChampController = TextEditingController();
  final _regionController = TextEditingController();
  final _locationController = TextEditingController();
  final _culturesController = TextEditingController();
  final _superficieController = TextEditingController();

  // État local
  bool _isLoading = true;
  Region? _selectedRegion;
  LatLng? _selectedLatLng;
  final Set<NomCulture> _selectedCultures = {};
  final Map<NomCulture, ActiviteType> _activiteParCulture = {};

  // Liste des régions (ID correspondant aux IDs de la DB Laravel)
  static const List<Region> _regionsMali = [
    Region(
      id: 'a0c14479-767f-43f3-9057-20dbcc72bc98',
      nom: 'District de Bamako',
    ),
    Region(id: '5f188cf7-64f1-47c8-9051-4354970b0948', nom: 'Kayes'),
    Region(id: '9e9ae2c4-eff9-4305-8736-a3e3ff65ab44', nom: 'Koulikoro'),
    Region(id: '0a119567-f479-4107-9b37-65d978c94d31', nom: 'Sikasso'),
    Region(id: '5bb12189-c0d3-4b5e-be9c-0517b9479361', nom: 'Ségou'),
    Region(id: '6a7a2306-12ae-4d91-920d-3bd4881e9d2e', nom: 'Mopti'),
    Region(id: 'c0d3a0fb-5e2d-4b94-a465-c5ac41f2fc6c', nom: 'Tombouctou'),
    Region(id: '0adadaa8-f5bf-4aa9-9468-0c4d2a88ded2', nom: 'Gao'),
    Region(id: '63940669-0ff9-45a5-88b8-fc32887f7bd3', nom: 'Kidal'),
    Region(id: '1bcf49af-8a93-46ac-8aa3-dfa591ac8568', nom: 'Taoudénit'),
    Region(id: 'faf27410-74ce-4a42-840e-b8b6ae86c28b', nom: 'Ménaka'),
  ];

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(baseUrl: AppConfig.baseUrl);
    _loadCurrentChampData();
  }

  // --- LOGIQUE API ---

  Future<void> _loadCurrentChampData() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final response = await _apiClient.get(
        '/api/profile/me',
        headers: {'Authorization': 'Bearer $token'},
      );

      final champ = response['champ'];
      if (champ != null) {
        setState(() {
          _nomChampController.text = champ['nom'] ?? "";
          _superficieController.text = champ['aire']?.toString() ?? "";

          if (champ['latitude'] != null && champ['longitude'] != null) {
            _selectedLatLng = LatLng(
              double.parse(champ['latitude'].toString()),
              double.parse(champ['longitude'].toString()),
            );
            _locationController.text =
                "Lat: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, Long: ${_selectedLatLng!.longitude.toStringAsFixed(4)}";
          }

          if (champ['region_id'] != null) {
            _selectedRegion = _regionsMali.firstWhere(
              (r) => r.id == champ['region_id'].toString(),
              orElse: () => _regionsMali.first,
            );
            _regionController.text = _selectedRegion!.nom;
          }
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (_nomChampController.text.isEmpty || _selectedRegion == null) {
      _showSnackBar("Veuillez remplir les informations de base", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _storage.read(key: 'access_token');

      // On envoie les données au service
      await _profileService.updateChamp(
        token: token!,
        nom: _nomChampController.text,
        regionId: _selectedRegion!.id,
        latitude: _selectedLatLng?.latitude ?? 0.0,
        longitude: _selectedLatLng?.longitude ?? 0.0,
        aire: double.tryParse(_superficieController.text) ?? 0.0,
      );

      _showSnackBar("Champ mis à jour avec succès !", AppColors.vert);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar("Erreur lors de la sauvegarde : $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // --- HELPER UI ---

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
      case NomCulture.mangue:
        return 'Mangue';
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

  // --- SELECTION METHODS ---

  Future<void> _pickRegion() async {
    final Region? picked = await showModalBottomSheet<Region>(
      context: context,
      backgroundColor: AppColors.gris2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Région', style: AppTextStyles.titre1),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _regionsMali.length,
                  separatorBuilder: (_, __) =>
                      Container(height: 1, color: AppColors.gris1),
                  itemBuilder: (context, index) {
                    final r = _regionsMali[index];
                    final isSelected = _selectedRegion?.id == r.id;
                    return ListTile(
                      title: Text(r.nom, style: AppTextStyles.textnoir),
                      trailing: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? AppColors.vert : AppColors.gris1,
                      ),
                      onTap: () => Navigator.pop(ctx, r),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
            'Long: ${picked.longitude.toStringAsFixed(4)}, Lat: ${picked.latitude.toStringAsFixed(4)}';
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                children: NomCulture.values.map((c) {
                  final selected = current.contains(c);
                  return FilterChip(
                    label: Text(
                      _cultureLabel(c),
                      style: AppTextStyles.textnoir,
                    ),
                    selected: selected,
                    onSelected: (v) => setModalState(
                      () => v ? current.add(c) : current.remove(c),
                    ),
                    selectedColor: AppColors.vert,
                    checkmarkColor: AppColors.gris2,
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
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedCultures
          ..clear()
          ..addAll(picked);
        _culturesController.text = _selectedCultures
            .map(_cultureLabel)
            .join(', ');
        for (var c in _selectedCultures) {
          _activiteParCulture.putIfAbsent(c, () => ActiviteType.semis);
        }
        _activiteParCulture.removeWhere(
          (c, _) => !_selectedCultures.contains(c),
        );
      });
    }
  }

  // --- WIDGETS ---

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
          onTap: onTap,
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ],
    );
  }

  Widget _portionAg() {
    if (_selectedCultures.isEmpty) return const SizedBox.shrink();
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
              ..._selectedCultures.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_cultureLabel(c), style: AppTextStyles.textnoir),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: ActiviteType.values.map((a) {
                          final isSelected = a == _activiteParCulture[c];
                          return InkWell(
                            onTap: () =>
                                setState(() => _activiteParCulture[c] = a),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.vert
                                    : AppColors.jaune,
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
                ),
              ),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.vert),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                          ),
                          style: IconButton.styleFrom(
                            side: BorderSide(color: AppColors.gris1),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Modifiez votre champ',
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
                      hintText: 'Nom du champ',
                      controller: _nomChampController,
                    ),
                    const SizedBox(height: 14),
                    _tapField(
                      label: 'Région',
                      hint: 'Choisir',
                      controller: _regionController,
                      onTap: _pickRegion,
                    ),
                    const SizedBox(height: 14),
                    _tapField(
                      label: 'Location',
                      hint: 'Choisir sur la carte',
                      controller: _locationController,
                      onTap: _pickLocation,
                    ),
                    const SizedBox(height: 14),
                    _tapField(
                      label: 'Type de culture',
                      hint: 'Choisir cultures',
                      controller: _culturesController,
                      onTap: _pickCultures,
                    ),
                    _portionAg(),
                    const SizedBox(height: 14),
                    Text('Superficie', style: AppTextStyles.textnoir),
                    const SizedBox(height: 8),
                    AuthTextField(
                      hintText: 'Superficie (m²)',
                      controller: _superficieController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),
                    OrangeButton(label: 'Sauvegarder', onPressed: _handleSave),
                  ],
                ),
              ),
            ),
    );
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
}
