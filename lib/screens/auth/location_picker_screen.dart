import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:agri_alert/constants/app_colors.dart';
import 'package:agri_alert/constants/app_text_styles.dart';
import 'package:agri_alert/widgets/orange_button.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _controller;
  LatLng? _picked;

  // Bamako (valeur de départ raisonnable)
  static const LatLng _initial = LatLng(12.639232, -8.002889);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gris2,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.gris1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.vert,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Choisissez un emplacement',
                      style: AppTextStyles.titre1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Map
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gris1,
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                clipBehavior: Clip.antiAlias,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _initial,
                    zoom: 11,
                  ),
                  onMapCreated: (c) => _controller = c,
                  onTap: (pos) {
                    setState(() => _picked = pos);
                  },
                  markers: {
                    if (_picked != null)
                      Marker(
                        markerId: const MarkerId('picked'),
                        position: _picked!,
                      ),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ),

            // Confirm
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: OrangeButton(
                label: 'Valider l’emplacement',
                onPressed: () {
                  Navigator.pop(context, _picked);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}