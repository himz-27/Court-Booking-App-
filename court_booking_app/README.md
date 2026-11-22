# CourtBook – Sports Court Booking System

## 1. Project Overview

CourtBook is a Flutter mobile application developed for Assignment 2 of the Application Programming course (A261 STTPK2143).

The application implements a user authentication system using Flutter, PHP and SQLite. It supports two user roles: Court Admin and Player.

Users can register, log in, view their account information and log out securely. Court booking features will be added in the Final Project.

## 2. System Features

- User registration with input validation.
- Secure user login.
- Two user roles: Court Admin and Player.
- Shared dashboard displaying user information.
- Password hashing for secure password storage.
- Authentication using secure session tokens.
- Persistent login while the session remains valid.
- Profile retrieval through a protected API.
- Logout with server-side session invalidation.
- Splash screen that checks for a saved session.

## 3. User Roles

| Role | Description |
| --- | --- |
| Court Admin | An administrator account created through a controlled backend setup script. |
| Player | A regular user who can register through the mobile application. |

Both roles use the same login interface and dashboard.

## 4. Technologies Used

| Technology | Purpose |
| --- | --- |
| Flutter | Mobile application development |
| Dart | Application programming language |
| PHP | Backend API development |
| SQLite | Database management |
| XAMPP | Local PHP development and testing |
| UUM StudentWebHost | Hosted PHP backend and SQLite database |
| GitHub | Source code management |

## 5. Database Design

The application uses an SQLite database named `court.db`. It is created automatically by `db.php` the first time the API runs.

### Users Table

| Column | Data Type | Description |
| --- | --- | --- |
| id | INTEGER | Primary key |
| name | TEXT | User's name |
| email | TEXT | Unique email address |
| password_hash | TEXT | Hashed password |
| role | TEXT | User role (`player` or `court_admin`) |
| created_at | TEXT | Account creation timestamp |

### Authentication Sessions Table

| Column | Data Type | Description |
| --- | --- | --- |
| id | INTEGER | Primary key |
| user_id | INTEGER | References users table |
| token_hash | TEXT | Hashed authentication token |
| expires_at | TEXT | Session expiration time |
| created_at | TEXT | Session creation timestamp |

## 6. Backend API Endpoints

The PHP backend provides the following endpoints:

| PHP File | HTTP Method | Purpose |
| --- | --- | --- |
| register.php | POST | Register a new Player account |
| login.php | POST | Authenticate a user and generate a session token |
| profile.php | GET | Retrieve authenticated user information |
| logout.php | POST | Invalidate the authentication session |

All authentication operations are handled through the PHP API.

## 7. Installation and Setup

### Requirements

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- PHP with PDO SQLite support

### Step 1: Clone the Repository

```
git clone https://github.com/himz-27/Court-Booking-App-.git
```

### Step 2: Open the Project

```
cd Court-Booking-App-/court_booking_app
```

### Step 3: Install Flutter Dependencies

```
flutter pub get
```

### Step 4: Configure the API URL

Open `lib/config.dart` and set `apiBaseUrl` to the address of the deployed PHP backend.

### Step 5: Run the Application

```
flutter run
```

## 8. Backend and Database Setup

1. Deploy the PHP files from `backend_backup/api` to a PHP-supported web hosting environment as `court_booking/api`.
2. Ensure the PHP environment supports PDO SQLite.
3. The database is created automatically by `db.php` on the first request.
4. Run the admin setup script once to create the Court Admin account, then delete it from the server.
5. Make sure the database file cannot be downloaded from the web.
6. Configure the Flutter API base URL to match the backend deployment address.

**Hosting note:** This project uses UUM StudentWebHost. Access to the hosted backend requires connection to UUM campus Wi-Fi.

## 9. Security Implementation

- Passwords are stored using PHP `password_hash()`.
- Password verification uses `password_verify()`.
- Prepared SQL statements are used to prevent SQL injection.
- Session tokens are generated using `random_bytes()`.
- Authentication tokens are stored as SHA-256 hashes in the database.
- Session expiration is set to seven days.
- Public registration automatically assigns the Player role.
- The Court Admin account is provisioned through a controlled backend process.
- The session token is kept on the device using `flutter_secure_storage`.

## 10. Release APK

The Android release APK is generated using:

```
flutter build apk --release
```

APK output location:

```
build/app/outputs/flutter-apk/app-release.apk
```

## 11. Testing

The application was tested on an Android device using the release APK.

Testing covered registration, duplicate email validation, invalid input, login, incorrect credentials, Court Admin and Player roles, profile retrieval, persistent sessions and logout.

The application was also tested against the hosted UUM StudentWebHost backend.