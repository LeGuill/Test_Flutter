# Test_Flutter - Register/Login Page

## Description

This project implements a responsive registration and login page for a fictional business analytics platform. It features a **Flutter** frontend (web-compatible) and a **Node.js** backend using a **MariaDB** database. The main objective was to replicate a specific UI design and ensure smooth communication between the frontend and backend for user registration and authentication.

The Flutter code was refactored into separate widgets to improve readability and maintainability.

## Design Inspiration

The frontend design is based on the following Dribbble mockup:
[Business Analytics Platform - Register Page by Ronas IT | UI Design](https://dribbble.com/shots/22814824-Business-Analytics-Platform-Register-Page)

*(Note: The original design may differ slightly. This application is a functional and responsive interpretation.)*

## Technologies Used

* **Frontend:**
    * Flutter (SDK Version 3.29.3)
    * Dart (Version 3.7.0)
    * `http` package 
* **Backend:**
    * Node.js 
    * Express.js 
    * `mysql2` 
    * `bcrypt` 
    * `dotenv`
    * `cors` 
* **Database:**
    * MariaDB 

## Features

* **Responsive UI** that adapts to mobile, tablet, and desktop screens.
* Frontend based on the Dribbble design.
* **Registration:**
    * Animated sliding form panel.
    * Field validation (client- and server-side).
    * User type selection (Merchant/Agent).
    * Dropdowns for location and industry.
    * Required privacy policy checkbox (in English).
    * Secure password hashing with `bcrypt`.
    * Sends data via POST requests.
    * Loading indicator and user feedback with SnackBars.
* **Login:**
    * "Log In" button on the initial screen and link in the registration form.
    * Styled popup dialog for email and password (white background, black button text).
    * Real API call to backend for credential verification.
    * Displays login errors in the dialog.
* **Logged-in State:**
    * Simple view with background, logo, personalized welcome message ("Welcome, [First Name]!") and "Log Off" button.
    * Logout functionality.
* **Flutter Code Structure:**
    * **`main.dart`**: Entry point, theme setup.
    * **`screens/register/register_screen.dart`**: Main stateful widget, manages global state (login, form visibility), handles logic (API calls, validation), and assembles UI layers.
    * **`screens/register/widgets/background_layer.dart`**: Stateless widget displaying background image, logo, text, and info boxes (uses `Wrap` for responsiveness).
    * **`screens/register/widgets/sliding_form_panel.dart`**: Stateless widget for the sliding panel containing the registration form (uses internal `_build...` methods).
    * *(Note: Code could be further split by extracting API logic into services, constants into config files, and form elements into dedicated widgets.)*
* **Node.js Code Structure:**
    * Organized with router (`routes/auth.js`) and controller (`controllers/authController.js`) files.

## Prerequisites

Make sure you have the following installed:

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.29.3 or higher recommended)
* [Node.js](https://nodejs.org/) (see version above)
* [npm](https://www.npmjs.com/get-npm) or [Yarn](https://yarnpkg.com/)
* [MariaDB](https://mariadb.org/download/) (or compatible MySQL server)
* A code editor (VS Code with Flutter/Dart extensions, Android Studio, etc.)
* Git

## Installation & Setup

1. **Clone the repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/Test_Flutter.git
    cd Test_Flutter
    ```
    *(Ensure the Flutter frontend and Node.js backend are placed in appropriate folders, e.g., `frontend/` and `backend/`.)*

2. **Backend Setup:**
    * Navigate to the backend directory:
        ```bash
        cd backend # Adjust if your folder is named differently
        ```
    * Install Node.js dependencies:
        ```bash
        npm install
        ```
    * **Set up the database:**
        * Ensure MariaDB server is running.
        * Create a database (e.g., `test_flutter_db`).
        * Create the `users` table (adapt if needed):
            ```sql
            CREATE TABLE users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_type ENUM('merchant', 'agent') NOT NULL,
                first_name VARCHAR(255) NOT NULL,
                company_location VARCHAR(255),
                email VARCHAR(255) NOT NULL UNIQUE,
                industry VARCHAR(255),
                phone_number VARCHAR(50),
                password_hash VARCHAR(255) NOT NULL,
                accepted_privacy_policy BOOLEAN NOT NULL DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            ```
        * Create a `.env` file to store database credentials:
            ```env
            # .env (in backend folder)
            DB_HOST=localhost
            DB_USER=your_db_user
            DB_PASSWORD=your_db_password
            DB_NAME=test_flutter_db
            PORT=3000
            BCRYPT_SALT_ROUNDS=10
            ```
            *(Ensure your `config/db.js` file uses these environment variables.)*
    * Start the backend server:
        ```bash
        npm start
        # or node server.js / nodemon server.js
        ```
        The backend should now be listening on `http://localhost:3000`.

3. **Frontend Setup (Flutter):**
    * Navigate to the frontend directory:
        ```bash
        cd ../frontend # Adjust if needed
        ```
    * Fetch Flutter dependencies:
        ```bash
        flutter pub get
        ```
    * **Check API URLs:** Open `lib/screens/register/register_screen.dart` and ensure `apiUrl` (register) and `loginApiUrl` (login) point to your backend (adjust `localhost` if testing on a real device).

## Running the Frontend

1. Make sure your Node.js backend is **running**.
2. From the `frontend/` folder, run the Flutter app in your browser:
    ```bash
    flutter run -d chrome
    ```
    *(Replace `chrome` with `edge` or `firefox` if configured.)*

The app should launch. You can create a new account or use "Log In" to sign in with an existing user.

## API Endpoints

* **Register:** `POST /api/auth/register`
    * **Body:** JSON object (`userType`, `firstName`, ... `acceptedPrivacyPolicy`)
    * **Responses:** 201, 400, 409, 500
* **Login:** `POST /api/auth/login`
    * **Body:** JSON object (`email`, `password`)
    * **Responses:** 200 (Success + `userData`), 400, 401 (Unauthorized), 500

## Project Frontend Structure

```bash
lib/
├── main.dart               
├── config/                   
│   ├── app_colors.dart       
│   └── api_config.dart       
├── screens/
│   └── register/
│       ├── register_screen.dart    
│       └── widgets/                
│           ├── background_layer.dart     
│           ├── sliding_form_panel.dart   
│           └── form_elements/            
│               ├── custom_dropdown.dart          
│               ├── custom_text_field.dart        
│               ├── login_link.dart               
│               ├── privacy_policy_checkbox.dart  
│               └── user_type_toggle.dart         
├── services/                 
│   └── auth_service.dart     
└── utils/                   
    └── validators.dart       
