# 🔑 Guide Complet : Obtenir un Token Firebase

## 📋 Résumé

**Oui**, vous devez :
1. ✅ Démarrer le **User Service**
2. ✅ Utiliser `/auth/register` pour créer un utilisateur
3. ⚠️ **MAIS** : Le register ne retourne **PAS** directement un token ID
4. ✅ Vous devez ensuite vous **connecter** pour obtenir le token

## 🚀 Étapes Détaillées

### Étape 1: Démarrer le User Service

```bash
cd user-service
mvn spring-boot:run
```

Le service sera sur : `http://localhost:8081/api/users`

### Étape 2: Créer un utilisateur

```powershell
Invoke-RestMethod -Uri http://localhost:8081/api/users/auth/register `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{
    "email": "test@example.com",
    "password": "password123",
    "displayName": "Test User",
    "role": "CLIENT"
  }'
```

**Réponse:** Vous obtiendrez un `uid` (Firebase UID), mais **PAS** de token ID.

### Étape 3: Obtenir un Token ID (2 options)

#### Option A: Via Firebase REST API (Recommandé pour les tests)

```powershell
# Vous avez besoin de votre Firebase API Key
# Trouvez-la dans Firebase Console > Project Settings > General > Web API Key

$apiKey = "VOTRE_FIREBASE_API_KEY"
$email = "test@example.com"
$password = "password123"

$body = @{
    email = $email
    password = $password
    returnSecureToken = $true
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body

$idToken = $response.idToken
Write-Host "✅ Token obtenu: $idToken" -ForegroundColor Green
```

#### Option B: Via Custom Token (Endpoint de test que j'ai créé)

```powershell
# 1. Obtenir un custom token
$uid = "VOTRE_UID_FIREBASE"  # De l'étape 2
$customTokenResponse = Invoke-RestMethod -Uri "http://localhost:8082/api/profiles/test/custom-token/$uid" `
  -Method POST

$customToken = $customTokenResponse.customToken

# 2. Échanger contre ID token (nécessite Firebase API Key)
$apiKey = "VOTRE_FIREBASE_API_KEY"
$exchangeBody = @{
    token = $customToken
    returnSecureToken = $true
} | ConvertTo-Json

$idTokenResponse = Invoke-RestMethod -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=$apiKey" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $exchangeBody

$idToken = $idTokenResponse.idToken
```

### Étape 4: Utiliser le Token pour Profile Service

```powershell
$idToken = "VOTRE_ID_TOKEN"

Invoke-RestMethod -Uri http://localhost:8082/api/profiles/create `
  -Method POST `
  -Headers @{
    "Content-Type"="application/json"
    "Authorization"="Bearer $idToken"
  } `
  -Body '{
    "displayName": "Test Profile",
    "bio": "Test Bio",
    "skills": []
  }'
```

## 🔑 Trouver votre Firebase API Key

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet : `skillmatching-86b8d`
3. Paramètres du projet (⚙️) > Général
4. Dans "Vos applications", trouvez la **Web API Key**

## 📝 Script Automatique Complet

J'ai créé un script qui fait tout automatiquement (voir `obtenir-token-automatique.ps1`)

## ⚠️ Important

- Le endpoint `/auth/register` crée l'utilisateur mais **ne retourne pas de token ID**
- Vous devez vous connecter séparément pour obtenir le token
- Les tokens expirent après ~1 heure
- En production, utilisez Firebase Auth SDK dans votre frontend

