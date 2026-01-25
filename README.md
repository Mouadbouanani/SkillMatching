# 🚀 SkillMatch - Plateforme de Marché de Compétences

SkillMatch est une plateforme innovante alimentée par l'IA qui connecte intelligemment les professionnels avec des compétences complémentaires pour des micro-jobs et des projets.

---

## 1. 🛠️ Installation, Configuration et Exécution

Suivez ces étapes pour installer et lancer le projet complet en local.

### Prérequis
*   **Docker Desktop** (installé et lancé)
*   **Git**

### Étape 1 : Cloner le projet
Récupérez le code source depuis le dépôt GitHub :

```bash
git clone https://github.com/Mouadbouanani/SkillMatching.git
cd SkillMatching
```

### Étape 2 : Configuration
Le projet est pré-configuré pour fonctionner avec Docker. Un fichier de configuration standard est utilisé par `docker-compose.yml`.

Assurez-vous que les ports suivants sont libres sur votre machine : `8080` (Gateway), `8081-8086` (Services), `5432` (Postgres local si instancié), `9092` (Kafka).

*Note : Les connexions aux bases de données cloud (PostgreSQL Neon & MongoDB Atlas) sont déjà configurées dans les fichiers de propriétés des services.*

### Étape 3 : Exécution
Lancez l'ensemble de l'architecture (bases de données, broker de messages, et microservices) avec une seule commande :

```bash
docker-compose up --build -d
```

Cette commande va :
1.  Construire les images Docker pour chaque microservice (Maven build inclus).
2.  Démarrer les conteneurs d'infrastructure (Zookeeper, Kafka, Redis).
3.  Démarrer tous les microservices Spring Boot.

### Étape 4 : Vérification
Vérifiez que tous les services sont opérationnels :
```bash
docker-compose ps
```
Tout doit être en état `Up` ou `Running`.

---

## 2. 🏗️ Architecture et Choix Techniques

Le projet repose sur une **Architecture Microservices** moderne, conçue pour la scalabilité, la résilience et la maintenance.

### Schéma Global
Le système est composé de services autonomes qui communiquent via **REST** (synchrone via Feign Client) et **Kafka** (asynchrone pour les événements).

### Stack Technologique
| Composant | Technologie | Justification |
| :--- | :--- | :--- |
| **Backend Core** | **Java 17 + Spring Boot 3** | Robustesse, écosystème riche et performance. |
| **Gateway** | **Spring Cloud Gateway** | Point d'entrée unique, routage dynamique, sécurité centralisée (CORS). |
| **Communication** | **Apache Kafka** | Gestion asynchrone des événements (ex: `JobCreated` déclenche le `MatchingService`) pour découpler les services. |
| **Bases de Données** | **PostgreSQL (Neon)** | Données relationnelles structurées (Utilisateurs, Jobs). |
| **NoSQL** | **MongoDB Atlas** | Données flexibles et volumineuses (Profils utilisateurs, Skills). |
| **Cache** | **Redis** | Mise en cache rapide pour réduire la latence (Sessions, Données fréquentes). |
| **Sécurité** | **Firebase Admin SDK** | Gestion des identités (Auth) et Notifications Push (FCM). |
| **Temps Réel** | **WebSocket (STOMP)** | Chat en direct entre utilisateurs. |

### Flux Principal (Exemple)
1.  Un client poste un job via le **Job Service**.
2.  Le Job Service publie un événement `job.created` dans **Kafka**.
3.  Le **Matching Service** consomme cet événement, exécute son algorithme de pondération (Skills 40%, Expérience 25%, etc.), et trouve les meilleurs candidats.
4.  Une notification est envoyée aux candidats via le **Notification Service** (Firebase).

---

## 3. 📖 Documentation API (Swagger UI)

Chaque microservice expose sa propre documentation interactive via **OpenAPI/Swagger**. Une fois le projet lancé (`http://localhost:8080` est la Gateway), vous pouvez accéder aux docs individuelles :

| Service | Swagger URL (Documentation) |
| :--- | :--- |
| **API Gateway** | [http://localhost:8080/webjars/swagger-ui/index.html](http://localhost:8080/webjars/swagger-ui/index.html) |
| **User Service** | [http://localhost:8081/api/users/swagger-ui/index.html](http://localhost:8081/api/users/swagger-ui/index.html) |
| **Profile Service** | [http://localhost:8082/swagger-ui/index.html](http://localhost:8082/swagger-ui/index.html) |
| **Job Service** | [http://localhost:8083/swagger-ui/index.html](http://localhost:8083/swagger-ui/index.html) |
| **Matching Service** | [http://localhost:8084/api/matches/swagger-ui/index.html](http://localhost:8084/api/matches/swagger-ui/index.html) |
| **Notification Service** | [http://localhost:8085/api/notifications/swagger-ui/index.html](http://localhost:8085/api/notifications/swagger-ui/index.html) |
| **Messaging Service** | [http://localhost:8086/api/messages/swagger-ui/index.html](http://localhost:8086/api/messages/swagger-ui/index.html) |

### Endpoints Clés (Accessibles via Gateway)
*   **Auth**: `POST /api/users/register`, `POST /api/users/login`
*   **Jobs**: `POST /api/jobs/create`, `GET /api/jobs/open`
*   **Profils**: `GET /api/profiles/{userId}`
*   **Matchs**: `GET /api/matches/suggestions/{jobId}`