// Importation des composants de l'interface de chat
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';

// Importation des packages Firebase : Authentification et Notifications Push (FCM)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Écran principal du chat.
/// Ce widget affiche :
/// - Les messages en temps réel
/// - Un champ pour écrire un nouveau message
/// - Une AppBar avec bouton de déconnexion
/// - La gestion des notifications Push
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

/// Classe associée à l'écran de chat
/// Utilise un `StatefulWidget` car on souhaite initialiser des notifications (FCM)
class _ChatScreenState extends State<ChatScreen> {
  /// Méthode pour configurer les notifications Push via Firebase Cloud Messaging (FCM)
  void setupPushNofifications() async {
    // Instance de Firebase Messaging
    final fcm = FirebaseMessaging.instance;

    // Demande de permission à l'utilisateur pour recevoir les notifications
    await fcm.requestPermission();

    // Abonnement au topic "chat" → permet d'envoyer des messages groupés aux utilisateurs abonnés
    fcm.subscribeToTopic('chat');

    // Possibilité ici de récupérer le token FCM et l'envoyer à Firestore si nécessaire
  }

  /// Méthode exécutée une seule fois au démarrage de l'écran
  @override
  void initState() {
    super.initState();
    // setupPushNofifications(); // ← à activer si la fonction doit être déclenchée
  }

  /// Construction de l'interface graphique
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre d'application en haut de l'écran
      appBar: AppBar(
        title: const Text('G-Chat'),

        // Action à droite : bouton déconnexion
        actions: [
          IconButton(
            onPressed: () {
              // Déconnexion de l'utilisateur via Firebase Auth
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),

      // Corps de l'écran principal
      body: Column(
        children: [
          // Zone de messages (prend tout l'espace restant)
          Expanded(child: ChatMessages()),

          // Champ pour écrire et envoyer un nouveau message
          NewMessage(),
        ],
      ),
    );
  }
}
