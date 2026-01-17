import 'package:flutter/material.dart';

class WeatherUpdateCard extends StatelessWidget {
  const WeatherUpdateCard({
    super.key,
    this.title = 'Weather Update',
    this.condition = 'Cloudy',
    this.currentTemp = 24,
    this.minTemp = 20,
    this.maxTemp = 27,
    this.tickTemps = const [20, 21, 22, 23, 25, 26, 27],
    this.times = const ['07.40AM', '07.50AM', '08.00AM', '08.10AM', '08.20AM'],
    this.selectedTimeIndex = 2,
    this.humidity = 80,
    this.uvIndex = 4,
    this.rainChance = 12,
    this.windKmh = 18,
  });

  final String title;
  final String condition;

  final int currentTemp;
  final int minTemp;
  final int maxTemp;

  /// Les valeurs affichées au-dessus de la barre (comme sur ton design).
  final List<int> tickTemps;

  /// Les heures sous la barre.
  final List<String> times;
  final int selectedTimeIndex;

  final int humidity;
  final int uvIndex;
  final int rainChance;
  final int windKmh;

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(28);
    final bg = const Color(0xFF2E3034);

    return Container(
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopRow(title: title, condition: condition),
          const SizedBox(height: 14),

          // Temp centrale
          Text(
            '$currentTemp°',
            style: const TextStyle(
              fontSize: 44,
              height: 1.05,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 12),

          // Échelle + barre gradient + heures
          _TempTimeline(
            currentTemp: currentTemp,
            minTemp: minTemp,
            maxTemp: maxTemp,
            tickTemps: tickTemps,
            times: times,
            selectedTimeIndex: selectedTimeIndex,
          ),

          const SizedBox(height: 16),

          // Stats
          _StatsGrid(
            humidity: humidity,
            uvIndex: uvIndex,
            rainChance: rainChance,
            windKmh: windKmh,
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ TOP ROW ------------------------------ */

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.title,
    required this.condition,
  });

  final String title;
  final String condition;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icône à gauche dans un cercle
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
          ),
          child: Icon(
            Icons.cloud_outlined,
            color: Colors.white.withOpacity(0.90),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.92),
              letterSpacing: -0.2,
            ),
          ),
        ),

        // Badge condition (vert fluo)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFC8FF4D),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            condition,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1E22),
            ),
          ),
        ),
      ],
    );
  }
}

/* ------------------------- TIMELINE (BAR) --------------------------- */

class _TempTimeline extends StatelessWidget {
  const _TempTimeline({
    required this.currentTemp,
    required this.minTemp,
    required this.maxTemp,
    required this.tickTemps,
    required this.times,
    required this.selectedTimeIndex,
  });

  final int currentTemp;
  final int minTemp;
  final int maxTemp;
  final List<int> tickTemps;

  final List<String> times;
  final int selectedTimeIndex;

  @override
  Widget build(BuildContext context) {
    final muted = Colors.white.withOpacity(0.55);
    final muted2 = Colors.white.withOpacity(0.42);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;

        final t = ((currentTemp - minTemp) / (maxTemp - minTemp))
            .clamp(0.0, 1.0);

        final knobRadius = 6.0;
        final barHeight = 16.0;
        final barTop = 26.0; // espace sous les ticks
        final markerHeight = barTop + barHeight;

        final x = t * w;
        final knobLeft = (x - knobRadius).clamp(0.0, w - 2 * knobRadius);
        final lineLeft = (x - 0.9).clamp(0.0, w - 1.8);

        return Column(
          children: [
            // Ticks au-dessus (20 21 22 23 | 25 26 27)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                children: [
                  for (int i = 0; i < tickTemps.length; i++) ...[
                    Text(
                      '${tickTemps[i]}°',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: muted2,
                      ),
                    ),
                    if (i != tickTemps.length - 1) const Spacer(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Stack: barre gradient + stripes + ligne + knob
            SizedBox(
              height: markerHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: barTop,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Stack(
                        children: [
                          Container(
                            height: barHeight,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF17D96B),
                                  Color(0xFF9BEA3C),
                                  Color(0xFFF0E64A),
                                  Color(0xFFFFB43B),
                                  Color(0xFFFF5A3B),
                                ],
                                stops: [0.0, 0.35, 0.62, 0.80, 1.0],
                              ),
                            ),
                          ),
                          // Lignes verticales fines (aspect “strié” du design)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _BarStripesPainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Ligne verticale blanche (du haut vers la barre)
                  Positioned(
                    top: 0,
                    left: lineLeft,
                    child: Container(
                      width: 1.8,
                      height: markerHeight,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Knob blanc sur la barre
                  Positioned(
                    top: barTop + (barHeight / 2) - knobRadius,
                    left: knobLeft,
                    child: Container(
                      width: knobRadius * 2,
                      height: knobRadius * 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Heures sous la barre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(times.length, (i) {
                final isSelected = i == selectedTimeIndex;
                if (!isSelected) {
                  return Text(
                    times[i],
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  );
                }
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FA0A7).withOpacity(0.55),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    '08.00AM',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _BarStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..strokeWidth = 1;

    // Stries verticales espacées
    const spacing = 6.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* ------------------------------- STATS ------------------------------ */

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.humidity,
    required this.uvIndex,
    required this.rainChance,
    required this.windKmh,
  });

  final int humidity;
  final int uvIndex;
  final int rainChance;
  final int windKmh;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.white.withOpacity(0.10);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    label: 'Humidity',
                    value: '$humidity%',
                  ),
                ),
                VerticalDivider(thickness: 1, width: 22, color: dividerColor),
                Expanded(
                  child: _StatCell(
                    label: 'UV Index',
                    value: uvIndex.toString().padLeft(2, '0'),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: dividerColor),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    label: 'Rain',
                    value: '$rainChance%',
                  ),
                ),
                VerticalDivider(thickness: 1, width: 22, color: dividerColor),
                Expanded(
                  child: _StatCell(
                    label: 'Wind',
                    value: '${windKmh}km/h',
                    alignEnd: true,
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

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.48),
    );

    final valueStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -0.2,
    );

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        Text(value, style: valueStyle),
      ],
    );
  }
}