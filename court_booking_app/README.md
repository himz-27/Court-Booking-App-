# CourtBook – Sports Court Booking App

## 1. Project Overview

CourtBook is a Flutter mobile app made for Assignment 2 of the Application Programming course (A261 STTPK2143).

It is a login system built with Flutter, PHP and SQLite. Users can register, log in, see their account details and log out. Court booking features will be added in the Final Project.

## 2. Features

- Register with input checks (empty fields, email format, password length, matching passwords)
- Log in with email and password
- Two roles: Player and Court Admin
- One shared dashboard that shows name, email and role from the server
- Stay logged in when the app is reopened
- Log out, which ends the session on the server
- Splash screen that checks for a saved session

## 3. User Roles

| Role | Description |
| --- | --- |
| Player | A normal user who registers in the app |
| Court Admin | Created by a backend setup script, never by public registration |

## 4. Technologies Used

| Technology | Purpose |
| --- | --- |
| Flutter / Dart | Mobile app |
| PHP | Backend REST API |
| SQLite | Database |
| UUM StudentWebHost | Hosts the PHP backend and database |
| GitHub | Source code |

## 5. Database

The database file is `court.db`. It is created automatically by `db.php` the first time the API runs.

**users**: id, name, email (unique), password_hash, role, created_at

**sessions**: id, user_id, token_hash, expires_at, created_at

## 6. API Endpoints

| File | Method | Purpose |
| --- | --- | --- |
| register.php | POST | Register a new Player |
| login.php | POST | Check login details and return a session token |
| profile.php | GET | Return the logged-in user's details (needs the token) |
| logout.php | POST | End the session |

## 7. How to Run

1. Clone the repository and open the folder.
2. Install packages:
   ```
   flutter pub get
   ```
3. Open `lib/config.dart` and set `apiBaseUrl` to your backend address.
4. Run the app:
   ```
   flutter run
   ```

## 8. Backend Setup

1. Upload the files in `backend_backup/api` to a PHP host as `court_booking/api`.
2. The host must support PHP with PDO SQLite.
3. Run the admin setup script once to create the Court Admin account, then delete it from the server.
4. Make sure the database file cannot be downloaded from the web.

Note: the hosted backend only works on the UUM campus Wi-Fi.

## 9. Security

- Passwords are hashed with `password_hash()` and checked with `password_verify()`
- Prepared statements are used for all database queries
- Session tokens are made with `random_bytes()` and only their SHA-256 hash is stored
- Sessions expire after seven days
- Registration always gives the Player role
- The token is kept on the phone with `flutter_secure_storage`

## 10. Build the APK

```
flutter build apk --release
```

The file is at `build/app/outputs/flutter-apk/app-release.apk`.

## 11. Testing

Tested on an Android phone against the hosted backend: registration, duplicate email, invalid input, login, wrong password, both roles, reopening the app, profile without a token, and logout.