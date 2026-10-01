# Jobs & Market — Mobile App (Jobs Module)

A cross-platform mobile application built with Flutter, developed as a senior project. This repository contains the Jobs module, which aggregates real-time job listings from multiple external APIs with a LinkedIn-style search and filtering experience.

## Features

- Integrated 3 external job APIs (Remotive, Jobicy, JSearch) for real-time listings across Lebanon, Saudi Arabia, Qatar, and worldwide
- LinkedIn-style instant search with live filtering across 5 fields simultaneously
- Multi-layer filter system (country + category, combinable)
- Payment-based access control system
- Admin panel for approving job posts and managing user access
- Real-time backend powered by Firebase Firestore

## Tech Stack

- **Framework:** Flutter, Dart
- **Backend:** Firebase Firestore
- **APIs:** Remotive, Jobicy, JSearch (RapidAPI)

## Note

API keys have been removed from this public repository for security. To run locally, add your own API key(s) in the designated location in the code.

## Installation

```bash
flutter pub get
flutter run
```
