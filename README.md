#  GreenPulse AI — Frontend

> Application mobile de détection des maladies des palmiers par intelligence artificielle

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)
![TensorFlow](https://img.shields.io/badge/AI-MobileNetV2-FF6F00?logo=tensorflow)
![License](https://img.shields.io/badge/License-MIT-green)

---

##  Description

GreenPulse AI est une application mobile Flutter développée lors du **Hackathon Gabès 2024**.
Elle permet aux agriculteurs de détecter automatiquement les maladies des palmiers de l'oasis de Gabès en prenant simplement une photo de la feuille.

Le modèle CNN basé sur **MobileNetV2** classifie l'état du palmier en 3 catégories.

---

##  Classes de classification

| Classe | Description |
|--------|-------------|
|  **Healthy** | Palmier sain |
|  **Bio_Disease** | Maladie biologique (champignons, parasites) |
|  **Chemical_Damage** | Dommage chimique (pollution SO₂, métaux lourds) |

---

##  Fonctionnalités

-  **Capture photo** — Prise de photo ou sélection depuis la galerie
-  **Classification IA** — Analyse via MobileNetV2 en temps réel
-  **Score de confiance** — Affichage des probabilités par classe
-  **Cartographie** — Localisation des zones touchées
-  **UI moderne** — Interface intuitive et responsive

---

##  Structure du projet

```
lib/
├── models/       ← Modèles de données
├── screens/      ← Écrans de l'application
├── services/     ← Appels API et logique métier
├── app_theme.dart ← Thème et couleurs
└── main.dart     ← Point d'entrée
```

---

##  Technologies

| Outil | Usage |
|-------|-------|
| Flutter / Dart | Framework mobile |
| Provider | Gestion d'état |
| HTTP | Appels API REST |
| Camera / Image Picker | Capture d'images |
| Google Maps | Cartographie |

---

##  Installation

```bash
# Cloner le dépôt
git clone https://github.com/HayfaBouali/GreenPulse-AI.git
cd GreenPulse-AI

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

>  Le backend doit être lancé en parallèle : [GreenPulse-AI-backend](https://github.com/HayfaBouali/GreenPulse-AI-backend)

---

##  Contexte

Projet développé lors du **Hackathon Gabès 2024** pour contribuer à la protection de l'oasis de Gabès, classée patrimoine mondial, face à la pollution industrielle.

**Équipe :** Haifa Bouali & Hafidha Hacine

---

##  Auteure

**Haifa Bouali** — Étudiante en Génie Logiciel, orientée Data Science  
ESSAT Gabès, Tunisie

---

## 📄 Licence

Ce projet est sous licence [MIT](LICENSE).
