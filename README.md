# AZT - Modern Cross-Platform E-Commerce Application
![aztlogo](web/icons/Icon-192.png?raw=true)


**AZT** is a cutting-edge Flutter application designed to provide a seamless e-commerce experience across Web, Android, and iOS. Built with a robust modern tech stack, it features a feature-first architecture, role-based access control (Customer, Retailer, Wholesaler), and a fully integrated Firebase backend.

---

## Key Features

* **Cross-Platform Support**: Runs natively on Android, iOS, and the Web.
* **Role-Based Access**: Distinct dashboards and functionalities for Customers, Retailers, and Wholesalers.
* **Secure Authentication**: Email/Password and Google Sign-In via Firebase Auth.
* **Real-Time Data**: Instant updates using Firebase Cloud Firestore and Realtime Database.
* **Progressive Web App (PWA)**: Installable web experience with offline capabilities.
* **Automated CI/CD**: Fully automated deployment pipeline to GitHub Pages.

---

##  Technology Stack

### Frontend & Framework
* **Flutter**: SDK version `^3.9.2` for building natively compiled applications.
* **Dart**: The language powering the application.

### State Management
* **Flutter Bloc**: The application utilizes the BLoC (Business Logic Component) pattern using the `flutter_bloc` package.
* **Cubits**: Specifically, `AuthCubit` handles the entire authentication flow, including state emissions for `Authenticated`, `Unauthenticated`, `RoleNotSelected`, and `EmailNotVerified`.

### Backend Services (Firebase)
* **Firebase Auth**: Manages user sessions and identity (Google & Email providers).
* **Cloud Firestore**: Stores user profiles, role data, and persistent application state.
* **Realtime Database**: utilized for high-frequency data updates.

---

##  Project Architecture

The project follows a **Feature-First Architecture** combined with the **Repository Pattern** to ensure separation of concerns and scalability.

* **Features Directory**: Code is organized by feature (e.g., `auth`, `home`, `retailer`) rather than layer.
* **Repository Pattern**:
    * **Data Layer**: `FirebaseAuthRepo` handles direct communication with Firebase.
    * **Domain Layer**: Cubits interact with Repositories to fetch data, keeping UI logic clean.
    * **Dependency Injection**: `MultiRepositoryProvider` and `MultiBlocProvider` inject dependencies at the root of the app.

---

## Progressive Web App (PWA) & Accessibility

The web build is configured as a Progressive Web App, providing an app-like experience in the browser.

* **Manifest Configuration**: The `manifest.json` is configured with standalone display mode, theme colors, and maskable icons for optimal display on all devices.
* **Assets**: Includes high-resolution icons for various viewports.

---

##  Python Proxy Server for Notifications

To handle email notifications securely and efficiently without incurring cloud function costs, the application employs a custom solution.

**The application uses a Python-based email proxy server to send order status notifications. This proxy is necessary to bypass CORS restrictions and to avoid using paid cloud functions, when sending emails from the Flutter web client. This server can be run on cheap and minimal equipment such as Raspberry PI 3B/4 with a functioning internet connection, thus, making the project host for anyone.**

The client-side implementation (`MailService`) intelligently switches `localhost` addresses based on the platform (Android Emulator vs. iOS Simulator vs. Web) to communicate with this proxy.

---

##  CI/CD Pipeline

The project utilizes **GitHub Actions** for Continuous Integration and Deployment.

* **Workflow**: Defined in `.github/workflows/deploy-to-gh-pages.yml`.
* **Automation**:
    1.  Triggers on push to the `main` branch.
    2.  Sets up the Flutter environment and enables web support.
    3.  Builds the Flutter web application in release mode (`flutter build web --release`).
    4.  Handles SPA (Single Page Application) routing by copying `index.html` to `404.html`.
    5.  Deploys the build artifacts directly to the `gh-pages` branch.

---

##  Installation & Setup

1.  **Clone the repository**:
    ```bash
    git clone [https://github.com/yourusername/azt.git](https://github.com/yourusername/azt.git)
    cd azt
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the Python Proxy Server**:
    Ensure your Python environment is set up and run the server script (not included in this snippet) to handle email requests.

4.  **Run the App**:
    * **Web**: `flutter run -d chrome`
    * **Mobile**: `flutter run` (ensure an emulator or device is connected)

---

## Link to the Application
https://gmbcode.github.io/azt/
