# 🚀 SkillMatch - Professional Skills Marketplace Platform

SkillMatch is an innovative AI-powered marketplace that intelligently connects professionals with complementary skills for micro-jobs and projects.

## 🏗️ System Architecture

SkillMatch is built on a high-performance **Microservices Architecture** designed for scalability and real-time interaction.

### 🛰️ Core Services
| Service | Technology | Port | Purpose | Database |
| :--- | :--- | :--- | :--- | :--- |
| **API Gateway** | Spring Cloud Gateway | `8080` | Entry point, Auth, Global CORS, Routing | - |
| **User Service** | Spring Boot | `8081` | Auth Sync, Role Management (RBAC) | **PostgreSQL (Neon)** |
| **Profile Service** | Spring Boot | `8082` | Skills, Portfolios, Average Ratings | **MongoDB Atlas + Redis** |
| **Job Service** | Spring Boot | `8083` | Job Posting, Applications, Categories | **PostgreSQL (Neon)** |
| **Matching Service**| Spring Boot | `8084` | AI Scoring Algorithm (Weights) | **PostgreSQL (Neon)** |
| **Notification** | Spring Boot | `8085` | FCM Push Alerts, History | **Firestore** |
| **Messaging** | Spring Boot | `8086` | Real-time Chat & WebSocket Relay | **Firestore** |

---

## 🔐 Role-Based Access Control (RBAC)

The system enforces strict access control via Firebase Custom Claims.

| Role | Authorizations |
| :--- | :--- |
| **ROLE_CLIENT** | Post jobs, Review applications, Rate providers, Manage matches. |
| **ROLE_PROVIDER** | Create professional profile, Apply for jobs, Receive AI matches. |
| **ROLE_ADMIN** | Platform analytics, Content moderation, User management. |

*Note: Roles are injected by the API Gateway into the `X-User-Role` header for all downstream services.*

---

## 🧠 AI Matching Algorithm (Weighted Scoring)

The `matching-service` computes a compatibility score (0-100%) for every new job using the following weights:

*   **Skill Match (40%)**: Overlap between job requirements and provider expertise.
*   **Experience (25%)**: Professional proficiency levels and years in field.
*   **Reputation (20%)**: Historical rating average from completed projects.
*   **Proximity (15%)**: Geographic match based on user location.

---

## 📡 Frontend Integration Guide

### 1. Connection Headers
Every request to the Gateway (`:8080`) must include:
```http
Authorization: Bearer <FIREBASE_ID_TOKEN>
Content-Type: application/json
```

### 2. Real-time Communication Paths
| Feature | Path / Collection | Mode |
| :--- | :--- | :--- |
| **Chat Messages** | `/messages/{messageId}` | Firestore (Listen) |
| **Chat Relay** | `ws://localhost:8086/ws-chat` | WebSocket (Send/Receive) |
| **Notifications** | `/notifications` | Firestore (Listen) |
| **Matching History**| `GET /api/matches/suggestions/{jobId}` | REST API |

---

## 🛠️ API Reference (Key Endpoints)

### 💼 Job Lifecycle
*   `POST /api/jobs/create`: Create job. **(Client only)**
*   `POST /api/jobs/apply`: Apply for job. **(Provider only)**
*   `PUT /api/jobs/{jobId}/status`: Update job status (OPEN, IN_PROGRESS, COMPLETED).

### 🏆 Reputation & Discovery
*   `POST /api/profiles/rate/{userId}?rating=5.0`: Submit rating.
*   `GET /api/profiles/skills?skills=java,flutter`: Find providers by skills.

### 🧠 Match Resolution
*   `GET /api/matches/suggestions/{jobId}`: Get top 10 AI matches.
*   `POST /api/matches/{matchId}/accept`: Formally accept a match.

---

## ⚙️ Deployment & Infrastructure

### 🌑 Cloud Persistence (Production-Ready)
*   **PostgreSQL**: Hosted on **Neon.tech** (Serverless).
*   **NoSQL**: Hosted on **MongoDB Atlas** (Profiles).
*   **Real-time**: Hosted on **Firebase Firestore**.

### 🐳 Docker Setup
1.  **Configure `.env`**:
    ```properties
    MONGODB_URI=...
    DB_HOST=ep-bold-base...neon.tech
    DB_PASSWORD=...
    KAFKA_BOOTSTRAP_SERVERS=kafka:9092
    FIREBASE_PROJECT_ID=...
    ```
2.  **Start Stack**:
    ```bash
    docker-compose up --build -d
    ```

### 🔄 Event Flow (Kafka)
| Topic | Producer | Consumer | Action |
| :--- | :--- | :--- | :--- |
| `job.created` | Job Service | Matching Service | Triggers AI scoring engine. |
| `match.created` | Matching Service| Notification Service| Sends FCM & Firestore alert. |
| `message.sent` | Messaging Service| Notification Service| Sends "New Message" push alert. |

---

## 🧪 Troubleshooting
*   **401 Unauthorized**: Ensure the Firebase ID Token hasn't expired (tokens last 1 hour).
*   **503 Service Unavailable**: Check Kafka status via `docker-compose ps`. Matching relies on Kafka being up.
*   **CORS Issues**: The Gateway is configured for `*`. Ensure your frontend is sending the `Authorization` header in the `Access-Control-Allow-Headers`.