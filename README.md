# Test_Flutter - Registration Page

## Description

This project is an implementation of a responsive registration page for a fictional business analytics platform. It includes a frontend developed with **Flutter** (compilable for the web) and a backend developed with **Node.js** using a **MariaDB** database. The goal was to replicate a specific design and ensure communication between the frontend and backend for user registration.

The Flutter code has been refactored into separate widgets for better readability and maintainability.

## Design Inspiration

The frontend design is inspired by the following Dribbble shot:
[Business Analytics Platform - Register Page by Ronas IT | UI Design](https://dribbble.com/shots/22814824-Business-Analytics-Platform-Register-Page)

*(Note: The original design may have variations; this application is a functional and responsive interpretation.)*

## Technologies Used

* **Frontend:**
    * Flutter (SDK Version 3.29.3)
    * Dart (Version 3.7.0) 
    * `http` package (for API calls) - 
* **Backend:**
    * Node.js (Version 22.14.0) -
    * Express.js 
    * `mysql2` (or `mysql`) 
    * `bcrypt` 
    * `dotenv` 
    * `cors` 
* **Database:**
    * MariaDB 

## Features

* **Responsive** user interface adapting to different screen sizes (mobile, tablet, desktop).
* Frontend based on the Dribbble design.
* Animated sliding form panel.
* Form field validation on both client-side (Flutter) and server-side (Node.js).
* User type selection (Merchant/Agent).
* Dropdown menus for company location and industry.
* Checkbox for privacy policy acceptance (with validation).
* Secure password hashing on the backend (`bcrypt`).
* Form data submission to the backend via an HTTP POST request.
* Handling of backend responses (success, business errors like email already in use).
* Loading indicator display during API calls.
* Basic network error handling.
* Flutter code structure refactored into separate widgets (`BackgroundLayer`, `SlidingFormPanel`, `OpenFormButton`).
* Node.js code structure with separate router and controller.

## Prerequisites

Before you begin, ensure you have installed:

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (Version specified above or higher)
* [Node.js](https://nodejs.org/) (Version specified above or higher)
* [npm](https://www.npmjs.com/get-npm) (Node Package Manager) or [Yarn](https://yarnpkg.com/)
* [MariaDB](https://mariadb.org/download/) (or a compatible MySQL server)
* A code editor (VS Code with Flutter/Dart extensions, Android Studio, etc.)
* Git

## Installation and Setup

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/Test_Flutter.git](https://github.com/YOUR_USERNAME/Test_Flutter.git)
    cd Test_Flutter
    ```
    *(Ensure the Flutter frontend code and Node.js backend code are in the correct folders, e.g., `frontend/` and `backend/` or similar at the root of the cloned project).*

2.  **Backend Setup:**
    * Navigate to the backend directory:
        ```bash
        cd backend # Adjust if the folder name is different
        ```
    * Install Node.js dependencies:
        ```bash
        npm install
        # or yarn install
        ```
    * **Configure the database:**
        * Verify that your MariaDB server is running.
        * Create a database for the project (e.g., `test_flutter_db`).
        * Create the `users` table. Here is an example SQL structure (adjust if necessary):
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
        * Configure the database connection. If you are using a `.env` file (recommended), create it from a potential `.env.example`:
            ```env
            # .env (in the backend directory)
            DB_HOST=localhost
            DB_USER=your_db_user
            DB_PASSWORD=your_db_password
            DB_NAME=test_flutter_db
            PORT=3000 # Node.js server listening port
            BCRYPT_SALT_ROUNDS=10 # Optional, if not set in code
            ```
            *(Ensure your `config/db.js` file uses these environment variables).*
    * Start the backend server:
        ```bash
        npm start
        # or node server.js / nodemon server.js etc.
        ```
        The backend should now be listening on `http://localhost:3000`.

3.  **Frontend Setup (Flutter):**
    * Navigate to the frontend directory:
        ```bash
        cd ../frontend # Adjust if necessary, assuming it's named 'frontend'
        ```
    * Get Flutter dependencies:
        ```bash
        flutter pub get
        ```
    * **Verify the API URL:** Open `lib/screens/register/register_screen.dart` and confirm that the `apiUrl` constant points to your local backend:
        ```dart
        const String apiUrl = 'http://localhost:3000/api/auth/register';
        ```

## Running the Frontend Application

1.  Make sure your Node.js backend server is **running**.
2.  From the `frontend` directory, run the Flutter application on the web:
    ```bash
    flutter run -d chrome
    ```
    *(You can replace `chrome` with `edge` or `firefox` if configured).*

The application should open in your browser, displaying the registration page. You can test the form and check your backend console logs to see if the data is being received.

## API Endpoint

The frontend communicates with the backend via the following endpoint:

* **`POST /api/auth/register`**
    * **Body:** JSON object containing user information (`userType`, `firstName`, `companyLocation`, `email`, `industry`, `phoneNumber`, `password`, `acceptedPrivacyPolicy`).
    * **Responses:**
        * `201 Created`: Success, with `{ "message": "...", "userId": ... }`.
        * `400 Bad Request`: Missing or invalid data, with `{ "message": "..." }`.
        * `409 Conflict`: Email already in use, with `{ "message": "Email already used" }`.
        * `500 Internal Server Error`: Generic server error.


