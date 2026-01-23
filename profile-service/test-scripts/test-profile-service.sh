#!/bin/bash

# Script de test pour Profile Service
# Assurez-vous que MongoDB et le service sont démarrés

BASE_URL="http://localhost:8082/api/profiles"
FIREBASE_TOKEN="YOUR_FIREBASE_TOKEN_HERE"
USER_ID="test-user-$(date +%s)"

echo "🧪 Test du Profile Service"
echo "=========================="
echo ""

# Test 1: Créer un profil
echo "📝 Test 1: Création d'un profil"
PROFILE_RESPONSE=$(curl -s -X POST "$BASE_URL/create" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FIREBASE_TOKEN" \
  -d "{
    \"displayName\": \"Test User\",
    \"bio\": \"Développeur Full Stack\",
    \"location\": \"Paris, France\",
    \"availability\": \"{\\\"monday\\\": true}\",
    \"skills\": [
      {
        \"skillId\": \"java-001\",
        \"skillName\": \"Java\",
        \"proficiencyLevel\": 8,
        \"yearsExperience\": 5
      }
    ]
  }")

echo "Réponse: $PROFILE_RESPONSE"
PROFILE_ID=$(echo $PROFILE_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "Profile ID: $PROFILE_ID"
echo ""

# Test 2: Récupérer un profil
echo "📖 Test 2: Récupération d'un profil"
curl -s -X GET "$BASE_URL/$USER_ID" \
  -H "Authorization: Bearer $FIREBASE_TOKEN" | jq .
echo ""

# Test 3: Mettre à jour un profil
if [ ! -z "$PROFILE_ID" ]; then
  echo "✏️  Test 3: Mise à jour d'un profil"
  curl -s -X PUT "$BASE_URL/$PROFILE_ID" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $FIREBASE_TOKEN" \
    -d "{
      \"displayName\": \"Test User Updated\",
      \"bio\": \"Bio mise à jour\"
    }" | jq .
  echo ""
fi

# Test 4: Ajouter une compétence
if [ ! -z "$PROFILE_ID" ]; then
  echo "➕ Test 4: Ajout d'une compétence"
  curl -s -X POST "$BASE_URL/$PROFILE_ID/skills" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $FIREBASE_TOKEN" \
    -d "{
      \"skillId\": \"mongodb-001\",
      \"skillName\": \"MongoDB\",
      \"proficiencyLevel\": 6,
      \"yearsExperience\": 2
    }" | jq .
  echo ""
fi

echo "✅ Tests terminés!"

