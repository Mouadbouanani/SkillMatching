# SkillMatch Flutter App

Application mobile Flutter pour la plateforme SkillMatch - Marketplace de talents professionnels.

## 🚀 Fonctionnalités

### Pour les Clients (ROLE_CLIENT)
- ✅ Inscription avec choix du rôle Client
- ✅ Création de profil professionnel
- ✅ Création de jobs avec budget, localisation, deadline
- ✅ Ajout de compétences requises aux jobs
- ✅ Visualisation des candidatures reçues
- ✅ Acceptation/Refus des candidatures

### Pour les Prestataires (ROLE_PROVIDER)
- ✅ Inscription avec choix du rôle Prestataire
- ✅ Création de profil avec bio et localisation
- ✅ Ajout de compétences avec niveau de maîtrise
- ✅ Recherche et parcours des jobs disponibles
- ✅ Candidature aux jobs avec tarif proposé
- ✅ Suivi des candidatures envoyées

## 🏗️ Architecture

```
lib/
├── core/
│   ├── config/
│   │   ├── api_config.dart      # Configuration des endpoints API
│   │   └── firebase_options.dart # Configuration Firebase
│   ├── di/
│   │   └── service_locator.dart # Injection de dépendances (GetIt)
│   ├── models/                   # Modèles de données
│   │   ├── user_model.dart
│   │   ├── profile_model.dart
│   │   ├── skill_model.dart
│   │   ├── job_model.dart
│   │   └── job_application_model.dart
│   ├── network/
│   │   ├── api_client.dart      # Client HTTP Dio
│   │   └── auth_interceptor.dart # Intercepteur JWT
│   ├── router/
│   │   └── app_router.dart      # Configuration GoRouter
│   └── theme/
│       └── app_theme.dart       # Thème Material 3 dark
│
├── features/
│   ├── auth/
│   │   ├── bloc/                # AuthBloc (login, register, logout)
│   │   ├── repository/
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── profile/
│   │   ├── bloc/                # ProfileBloc (CRUD profil, skills)
│   │   ├── repository/
│   │   └── screens/
│   │       ├── create_profile_screen.dart
│   │       ├── profile_screen.dart
│   │       └── add_skill_screen.dart
│   ├── jobs/
│   │   ├── bloc/                # JobBloc (jobs, candidatures)
│   │   ├── repository/
│   │   └── screens/
│   │       ├── jobs_list_screen.dart
│   │       ├── job_detail_screen.dart
│   │       ├── create_job_screen.dart
│   │       ├── my_jobs_screen.dart
│   │       ├── job_applications_screen.dart
│   │       └── my_applications_screen.dart
│   └── home/
│       └── screens/
│           └── home_screen.dart # Dashboard différencié Client/Provider
│
├── shared/
│   └── widgets/
│       ├── glass_card.dart      # Widget glassmorphism
│       ├── gradient_button.dart # Boutons avec gradient
│       ├── custom_text_field.dart
│       └── loading_widgets.dart
│
└── main.dart
```

## 🔧 Configuration

### 1. Firebase

Mettez à jour le fichier `lib/core/config/firebase_options.dart` avec vos clés Firebase:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  // ...
);
```

### 2. API Backend

Configurez l'URL de l'API Gateway dans `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = 'http://localhost:8080'; // ou votre URL de production
```

## 📱 Lancement

```bash
# Installation des dépendances
flutter pub get

# Lancement sur Windows
flutter run -d windows

# Lancement sur Android
flutter run -d android

# Lancement sur Chrome (Web)
flutter run -d chrome
```

## 🔐 Flux d'authentification

1. **Inscription**: L'utilisateur choisit son rôle (Client/Prestataire) et crée son compte
2. **Création de profil**: Après inscription, redirection vers la page de création de profil
3. **Dashboard**: Selon le rôle, affichage d'un dashboard personnalisé
4. **JWT Token**: Stocké localement via SharedPreferences, injecté automatiquement dans les requêtes

## 🎨 Design

- **Thème**: Material 3 Dark avec couleurs vibrantes
- **Glassmorphism**: Effets de verre sur les cartes
- **Gradients**: Boutons et badges avec dégradés
- **Couleurs différenciées**:
  - Client: Violet (`#8B5CF6`)
  - Prestataire: Teal (`#14B8A6`)
  - Primary: Indigo (`#6366F1`)

## 📡 Endpoints API utilisés

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/users/register` | POST | Inscription |
| `/api/users/login` | POST | Connexion |
| `/api/users/me` | GET | Utilisateur courant |
| `/api/profiles/create` | POST | Créer profil |
| `/api/profiles/{userId}` | GET/PUT | Lire/Modifier profil |
| `/api/profiles/{userId}/skills` | POST | Ajouter compétence |
| `/api/jobs/create` | POST | Créer job |
| `/api/jobs/open` | GET | Jobs ouverts |
| `/api/jobs/my` | GET | Mes jobs (client) |
| `/api/jobs/apply` | POST | Postuler |
| `/api/jobs/{jobId}/applications` | GET | Candidatures d'un job |
| `/api/jobs/applications/my` | GET | Mes candidatures |

## 🛠️ Dépendances principales

- `flutter_bloc` - Gestion d'état
- `go_router` - Navigation déclarative
- `dio` - Client HTTP
- `firebase_core` / `firebase_auth` - Authentification Firebase
- `shared_preferences` - Stockage local
- `get_it` - Injection de dépendances
- `google_fonts` - Typographie
- `equatable` - Comparaison d'objets

## ⚠️ Notes importantes

1. **Backend requis**: L'application nécessite le backend Spring Boot en cours d'exécution
2. **Firebase**: Configurez Firebase dans la console et téléchargez les fichiers de config
3. **CORS**: Le backend doit autoriser les requêtes depuis l'application Flutter
