import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/orange_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  final String? finishRoute;

  const OnboardingScreen({
    super.key,
    this.onFinished,
    this.finishRoute,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      image: AppImages.onBoarding1,
      title: 'Détection intelligente des maladies',
      subtitle:
          'Identifiez rapidement les maladies des cultures\ngrâce à l’analyse intelligente des feuilles et des\nsymptômes',
    ),
    _OnboardingData(
      image: AppImages.onBoarding2,
      title: 'Recommandations météorologiques',
      subtitle:
          'Recevez des prévisions locales et des conseils\nadaptés pour semer, irriguer et traiter au bon\nmoment',
    ),
    _OnboardingData(
      image: AppImages.onBoarding3,
      title: 'Décisions agricoles optimisées',
      subtitle:
          'Combinez données météo et santé des\ncultures pour prendre de meilleures\ndécisions et améliorer vos rendements',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < _pages.length - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      return;
    }

    if (widget.onFinished != null) {
      widget.onFinished!.call();
      return;
    }

    if (widget.finishRoute != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(widget.finishRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonLabel = (_index == _pages.length - 1) ? 'Commencer' : 'Suivant';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return _OnboardingPage(
                    image: p.image,
                    title: p.title,
                    subtitle: p.subtitle,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              child: Column(
                children: [
                  OrangeButton(
                    label: buttonLabel,
                    onPressed: _next,
                  ),
                  const SizedBox(height: 14),
                  _DotsIndicator(
                    count: _pages.length,
                    index: _index,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final imageHeight = c.maxHeight * 0.58;

        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
          child: Column(
            children: [
              SizedBox(
                height: imageHeight,
                child: Center(
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titre1,
              ),
              const SizedBox(height: 15),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.textnoir.copyWith(
                  height: 1.35,
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;

  const _DotsIndicator({
    required this.count,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final selected = i == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: 6,
            width: selected ? 18 : 6,
            decoration: BoxDecoration(
              color: selected ? AppColors.vert : AppColors.gris1,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}