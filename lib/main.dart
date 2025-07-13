// Importation des packages nécessaires
import 'package:flutter/material.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/auth.dart';

/// Point d'entrée de l'application Flutter
void main() async {
  // Initialise les bindings de Flutter avant toute opération asynchrone
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec les options spécifiques à la plateforme (Android/iOS/Web)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Lance l'application en affichant le widget App
  runApp(const App());
}

/// Widget racine de l'application.
/// Définit le thème et la logique de navigation principale selon l'état de connexion.
class App extends StatelessWidget {
  const App({super.key});

  /// Construction de l'interface de l'application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',

      // Définition du thème principal (couleur primaire dérivée d'une seed color)
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),

      /// Détermine la page d'accueil en fonction de l'état de connexion via un StreamBuilder
      home: StreamBuilder(
        // Stream écouté : authStateChanges() de FirebaseAuth
        // émet un événement à chaque connexion/déconnexion
        stream: FirebaseAuth.instance.authStateChanges(),

        // Fonction de construction appelée à chaque changement du stream
        builder: (ctx, snapshot) {
          // Si la connexion est encore en cours, on affiche un écran de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // Si l'utilisateur est connecté (hasData == true)
          if (snapshot.hasData) {
            // On redirige vers l'écran de chat
            return const ChatScreen();
          }

          // Sinon (pas connecté), on renvoie l'écran de connexion/inscription
          return const AuthScreen();
        },
      ),
    );
  }
}
