@echo off
:: Déplacez-vous dans le dossier lib
cd /d lib

:: Créez les dossiers principaux
mkdir constants models providers services screens widgets utils

:: Sous-dossiers de screens
mkdir screens\auth
mkdir screens\main
mkdir screens\ibox
mkdir screens\colis
mkdir screens\livraison
mkdir screens\signature
mkdir screens\settings

:: Sous-dossiers de widgets
mkdir widgets\auth
mkdir widgets\common
mkdir widgets\ibox
mkdir widgets\colis

:: Fichiers constants
echo // App constants > constants\app_constants.dart
echo // Route names > constants\route_names.dart

:: Modèles
echo // User model > models\user.dart
echo // IBox model > models\ibox.dart
echo // Colis model > models\colis.dart
echo // Livraison model > models\livraison.dart
echo // Notification model > models\notification.dart
echo // Signature model > models\signature.dart

:: Providers
echo // Auth provider > providers\auth_provider.dart
echo // IBox provider > providers\ibox_provider.dart
echo // Colis provider > providers\colis_provider.dart
echo // Livraison provider > providers\livraison_provider.dart
echo // Signature provider > providers\signature_provider.dart

:: Services
echo // Database helper > services\database_helper.dart
echo // Auth service > services\auth_service.dart
echo // IBox service > services\ibox_service.dart
echo // Colis service > services\colis_service.dart
echo // Livraison service > services\livraison_service.dart
echo // Notification service > services\notification_service.dart
echo // Signature service > services\signature_service.dart
echo // API service > services\api_service.dart

:: Fichiers d'authentification
echo // Login screen > screens\auth\login_screen.dart
echo // Signup screen > screens\auth\signup_screen.dart
echo // Forgot password screen > screens\auth\forgot_password_screen.dart
echo // OTP verification screen > screens\auth\otp_verification_screen.dart

:: Fichiers principaux
echo // Home screen > screens\main\home_screen.dart
echo // Dashboard screen > screens\main\dashboard_screen.dart

:: EBox
echo // IBox list screen > screens\ibox\ibox_list_screen.dart
echo // IBox detail screen > screens\ibox\ibox_detail_screen.dart

:: Colis
echo // Colis list screen > screens\colis\colis_list_screen.dart
echo // Colis detail screen > screens\colis\colis_detail_screen.dart
echo // Colis tracking screen > screens\colis\colis_tracking_screen.dart

:: Livraison
echo // Livraison list screen > screens\livraison\livraison_list_screen.dart
echo // Livraison detail screen > screens\livraison\livraison_detail_screen.dart

:: Signature
echo // Signature list screen > screens\signature\signature_list_screen.dart
echo // Signature create screen > screens\signature\signature_create_screen.dart
echo // Signature verify screen > screens\signature\signature_verify_screen.dart

:: Paramètres
echo // Profile screen > screens\settings\profile_screen.dart
echo // Notifications screen > screens\settings\notifications_screen.dart
echo // Security screen > screens\settings\security_screen.dart

:: Widgets d'authentification
echo // Auth form field > widgets\auth\auth_form_field.dart
echo // Auth button > widgets\auth\auth_button.dart

:: Widgets communs
echo // App bar > widgets\common\app_bar.dart
echo // Drawer > widgets\common\drawer.dart
echo // Bottom nav bar > widgets\common\bottom_nav_bar.dart

:: Widgets spécifiques à IBox
echo // IBox card > widgets\ibox\ibox_card.dart

:: Widgets spécifiques aux Colis
echo // Colis card > widgets\colis\colis_card.dart
echo // Tracking step > widgets\colis\tracking_step.dart

:: Utils
echo // Helpers > utils\helpers.dart
echo // Validators > utils\validators.dart
echo // Theme > utils\theme.dart

:: Main.dart
echo // Main entry point > main.dart

:: Terminé
echo Structure créée avec succès.
pause
