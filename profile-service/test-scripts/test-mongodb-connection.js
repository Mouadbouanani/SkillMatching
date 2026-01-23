// Script MongoDB pour tester la connexion et voir les données
// Utilisation: mongosh mongodb://localhost:27017 < test-mongodb-connection.js

// Se connecter à la base de données
use skillmatch_profiles;

print("📊 Statistiques de la base de données");
print("======================================");

// Compter les profils
const profileCount = db.profiles.countDocuments();
print(`Nombre de profils: ${profileCount}`);

// Afficher tous les profils
print("\n📋 Tous les profils:");
print("===================");
db.profiles.find().forEach(profile => {
    print(`\nID: ${profile._id}`);
    print(`User ID: ${profile.user_id}`);
    print(`Display Name: ${profile.display_name}`);
    print(`Bio: ${profile.bio || 'N/A'}`);
    print(`Location: ${profile.location || 'N/A'}`);
    print(`Rating: ${profile.rating || 0}`);
    print(`Skills: ${profile.skills ? profile.skills.length : 0}`);
    if (profile.skills && profile.skills.length > 0) {
        profile.skills.forEach(skill => {
            print(`  - ${skill.skill_name} (Level: ${skill.proficiency_level})`);
        });
    }
});

// Rechercher par compétence
print("\n🔍 Recherche par compétence 'Java':");
print("===================================");
db.profiles.find({"skills.skillId": "java-001"}).forEach(profile => {
    print(`- ${profile.display_name} (${profile.user_id})`);
});

// Rechercher par localisation
print("\n📍 Recherche par localisation 'Paris':");
print("=====================================");
db.profiles.find({location: /Paris/i}).forEach(profile => {
    print(`- ${profile.display_name} (${profile.location})`);
});

// Statistiques sur les compétences
print("\n📈 Statistiques des compétences:");
print("===============================");
const skillsStats = db.profiles.aggregate([
    { $unwind: "$skills" },
    { $group: {
        _id: "$skills.skillName",
        count: { $sum: 1 },
        avgLevel: { $avg: "$skills.proficiencyLevel" }
    }},
    { $sort: { count: -1 } }
]);

skillsStats.forEach(stat => {
    print(`${stat._id}: ${stat.count} profils, niveau moyen: ${stat.avgLevel.toFixed(1)}`);
});

print("\n✅ Script terminé!");

