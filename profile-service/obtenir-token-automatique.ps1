# Script PowerShell pour obtenir un token Firebase automatiquement

param(
    [Parameter(Mandatory=$false)]
    [string]$FirebaseApiKey = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Email = "test@example.com",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = "password123"
)

$userServiceUrl = "http://localhost:8081/api/users"
$firebaseAuthUrl = "https://identitytoolkit.googleapis.com/v1"

Write-Host "🔑 Obtenir un Token Firebase Automatiquement" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que l'API Key est fournie
if ([string]::IsNullOrEmpty($FirebaseApiKey)) {
    Write-Host "⚠️  Firebase API Key non fournie" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pour obtenir votre API Key:" -ForegroundColor Yellow
    Write-Host "1. Allez sur https://console.firebase.google.com/" -ForegroundColor Gray
    Write-Host "2. Sélectionnez le projet: skillmatching-86b8d" -ForegroundColor Gray
    Write-Host "3. Paramètres (⚙️) > Général" -ForegroundColor Gray
    Write-Host "4. Copiez la 'Web API Key'" -ForegroundColor Gray
    Write-Host ""
    $FirebaseApiKey = Read-Host "Entrez votre Firebase API Key"
    
    if ([string]::IsNullOrEmpty($FirebaseApiKey)) {
        Write-Host "❌ API Key requise. Arrêt du script." -ForegroundColor Red
        exit
    }
}

# Étape 1: Vérifier/Créer l'utilisateur
Write-Host "1️⃣  Création/Vérification de l'utilisateur..." -ForegroundColor Yellow

$registerBody = @{
    email = $Email
    password = $Password
    displayName = "Test User"
    role = "CLIENT"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$userServiceUrl/auth/register" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $registerBody
    
    Write-Host "✅ Utilisateur créé!" -ForegroundColor Green
    Write-Host "   UID: $($registerResponse.uid)" -ForegroundColor Gray
    Write-Host "   Email: $($registerResponse.user.email)" -ForegroundColor Gray
    Write-Host ""
} catch {
    $errorMessage = $_.Exception.Message
    if ($errorMessage -like "*Email deja utilise*" -or $errorMessage -like "*already*") {
        Write-Host "ℹ️  Utilisateur existe déjà, on continue..." -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "❌ Erreur: $errorMessage" -ForegroundColor Red
        exit
    }
}

# Étape 2: Se connecter pour obtenir le token ID
Write-Host "2️⃣  Connexion pour obtenir le token ID..." -ForegroundColor Yellow

$loginBody = @{
    email = $Email
    password = $Password
    returnSecureToken = $true
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$firebaseAuthUrl/accounts:signInWithPassword?key=$FirebaseApiKey" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $loginBody
    
    $idToken = $loginResponse.idToken
    $uid = $loginResponse.localId
    
    Write-Host "✅ Token obtenu avec succès!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Informations:" -ForegroundColor Cyan
    Write-Host "   UID: $uid" -ForegroundColor Gray
    Write-Host "   Email: $Email" -ForegroundColor Gray
    Write-Host "   Token (premiers 50 caractères): $($idToken.Substring(0, [Math]::Min(50, $idToken.Length)))..." -ForegroundColor Gray
    Write-Host ""
    
    # Sauvegarder le token dans une variable d'environnement de session
    $global:FirebaseToken = $idToken
    
    Write-Host "💾 Token sauvegardé dans `$global:FirebaseToken" -ForegroundColor Green
    Write-Host ""
    Write-Host "🧪 Testez maintenant avec:" -ForegroundColor Yellow
    Write-Host '   Invoke-RestMethod -Uri http://localhost:8082/api/profiles/create -Method POST -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $global:FirebaseToken"} -Body ''{"displayName":"Test","skills":[]}''' -ForegroundColor Gray
    Write-Host ""
    
    # Option: Tester directement
    Write-Host "Voulez-vous tester le Profile Service maintenant? (O/N)" -ForegroundColor Yellow
    $test = Read-Host
    
    if ($test -eq "O" -or $test -eq "o") {
        Write-Host ""
        Write-Host "3️⃣  Test du Profile Service..." -ForegroundColor Yellow
        
        $profileBody = @{
            displayName = "Test Profile"
            bio = "Profile créé automatiquement"
            location = "Test City"
            skills = @()
        } | ConvertTo-Json
        
        try {
            $profileResponse = Invoke-RestMethod -Uri "http://localhost:8082/api/profiles/create" `
                -Method POST `
                -Headers @{
                    "Content-Type"="application/json"
                    "Authorization"="Bearer $idToken"
                } `
                -Body $profileBody
            
            Write-Host "✅ Profil créé avec succès!" -ForegroundColor Green
            Write-Host "   Profile ID: $($profileResponse.id)" -ForegroundColor Gray
            Write-Host "   Display Name: $($profileResponse.displayName)" -ForegroundColor Gray
        } catch {
            Write-Host "❌ Erreur lors de la création du profil:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            if ($_.ErrorDetails.Message) {
                Write-Host "   Détails: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
            }
        }
    }
    
} catch {
    Write-Host "❌ Erreur lors de la connexion:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "   Détails: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "💡 Vérifiez que:" -ForegroundColor Yellow
    Write-Host "   - L'API Key Firebase est correcte" -ForegroundColor Gray
    Write-Host "   - L'utilisateur existe dans Firebase" -ForegroundColor Gray
    Write-Host "   - Le mot de passe est correct" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Script terminé!" -ForegroundColor Cyan

