import 'package:flutter/material.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      home: StreamBuilder(
        // stream : ici on écoute un flux (Stream) qui vient de FirebaseAuth.
        // FirebaseAuth.instance.authStateChanges() est un flux qui émet un événement
        // chaque fois qu'il y a un changement d'état d'authentification (connexion / déconnexion)
        stream: FirebaseAuth.instance.authStateChanges(),

        // builder : c'est une fonction qui sera appelée automatiquement chaque fois que
        // le Stream émet une nouvelle valeur (comme un listener)
        builder: (ctx, snapshot) {
          // snapshot : représente la dernière valeur (ou l’état) reçue du Stream
          // Il a plusieurs propriétés utiles :
          // - hasData : vrai si des données sont arrivées
          // - data : la donnée elle-même (ici un User? ou null)
          // - connectionState : état du stream (waiting, active, done...)

          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // Si snapshot.hasData est vrai, ça veut dire que l'utilisateur est connecté
          if (snapshot.hasData) {
            // On renvoie donc l'écran de chat
            return ChatScreen();
          }

          // Sinon, pas connecté, on renvoie l'écran d'authentification
          return const AuthScreen();
        },
      ),
    );
  }
}
