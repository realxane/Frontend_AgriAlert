# AgriAlert — Application mobile Flutter

AgriAlert est une application mobile destinée à accompagner les agriculteurs grâce aux informations météorologiques, aux alertes agricoles et aux fonctionnalités d'intelligence artificielle.

## 1. Technologies utilisées

- **Flutter / Dart** : application mobile.
- **Android SDK** : compilation et exécution sur Android.
- **Android NDK** : version `28.2.13676358`, requise par la configuration actuelle du projet.
- **Backend API** : Laravel, selon la configuration du projet.
- **Microservice IA** : Python, Flask et modèle de deep learning.

## 2. Prérequis

Avant de commencer, installez :

- Git : https://git-scm.com/install/windows
- Flutter SDK : https://docs.flutter.dev/get-started/install
- Android Studio : https://developer.android.com/studio
- Visual Studio Code : https://code.visualstudio.com/

Vérifiez votre environnement :

```bash
flutter --version
flutter doctor
flutter doctor --android-licenses
```

Acceptez les licences Android lorsque cela est demandé.

## 3. Récupérer le projet

Clonez le dépôt :

```bash
git clone https://github.com/realxane/Frontend_AgriAlert.git
```

Entrez dans le dossier du projet :

```bash
cd Frontend_AgriAlert
```

Ouvrez le projet dans VS Code :

```bash
code .
```


## 4. Configurer Android

Ouvrez Android Studio, puis accédez à :

**Tools → SDK Manager → SDK Tools**

Activez **Show Package Details**, puis vérifiez que le NDK suivant est installé :

```text
NDK (Side by side)
28.2.13676358
```

Installez également les composants Android SDK nécessaires à votre version de Flutter.

La configuration Android du projet peut évoluer. Consultez les fichiers Gradle du dépôt si une version particulière est requise.

## 5. Installer les dépendances Flutter

Depuis le dossier contenant `pubspec.yaml`, exécutez :

```bash
flutter clean
flutter pub get
```

Vérifiez que les appareils disponibles sont détectés :

```bash
flutter devices
```

## 6. Configurer les services backend et IA

L'application peut nécessiter un backend Laravel et un microservice Flask.

Avant d'utiliser les fonctionnalités qui dépendent de ces services :

1. Clonez et configurez les dépôts backend nécessaires.
2. Installez leurs dépendances respectives.
3. Configurez les URL des API selon votre environnement.
4. Vérifiez que les services sont démarrés et accessibles depuis l'appareil Android.

**Important :** sur l'émulateur Android, `localhost` désigne l'émulateur lui-même. Pour joindre un service exécuté sur le PC hôte, utilisez généralement `10.0.2.2` avec le port approprié. Sur un téléphone physique, utilisez une adresse IP accessible de votre ordinateur.

Ne publiez pas les mots de passe, les clés API ou les fichiers `.env` contenant des secrets.

## 7. Lancer l'application

Démarrez un émulateur Android ou connectez un téléphone avec le débogage USB activé.

Puis exécutez :

```bash
flutter run
```

Pour générer un APK de débogage :

```bash
flutter build apk --debug
```

Pour générer un APK de production :

```bash
flutter build apk --release
```

L'APK est normalement créé dans :

```text
build/app/outputs/flutter-apk/
```

## 8. Dépannage

### Erreur NDK

Si Flutter signale que le NDK `28.2.13676358` n'est pas installé, installez cette version via Android Studio SDK Manager.

### Erreur de dépendances Flutter

```bash
flutter clean
flutter pub get
```

### Erreur de connexion à l'API

Vérifiez l'URL configurée dans l'application, l'adresse du serveur, le port et l'état du backend.

### Avertissements Gradle ou Kotlin

Les avertissements de compatibilité ne signifient pas nécessairement que la compilation va échouer. Vérifiez les versions compatibles avant de modifier les fichiers Gradle.

## 9. Structure du projet

```text
Frontend_AgriAlert/
├── android/
├── ios/
├── lib/
│   └── main.dart
├── test/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```


