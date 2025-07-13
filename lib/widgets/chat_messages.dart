// Importation des dépendances nécessaires
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Widget qui affiche la liste des messages du chat en temps réel.
/// Ce composant :
/// - Écoute la collection `chat` dans Firestore via un Stream
/// - Construit dynamiquement les messages avec `MessageBubble`
/// - Affiche un indicateur de chargement, un message vide ou une erreur si nécessaire
class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  /// Méthode qui construit l'interface graphique du widget
  @override
  Widget build(BuildContext context) {
    // Récupération de l'utilisateur actuellement connecté via Firebase Auth
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      /// StreamBuilder : widget réactif qui écoute un flux (ici la collection 'chat')
      /// et reconstruit son contenu à chaque événement (ajout/modif/suppression)
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true) // Messages du plus récent au plus ancien
          .snapshots(),

      /// Construction de l'interface en fonction de l'état de connexion et des données reçues
      builder: (ctx, chatSnapshots) {
        // Si la connexion au flux est encore en cours, on affiche un loader
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si aucune donnée reçue ou aucune discussion dans la collection
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }

        // Si une erreur s'est produite lors de la récupération des données
        if (chatSnapshots.hasError) {
          return const Center(child: Text('Something went wrong...'));
        }

        // On récupère la liste des documents (messages) dans la collection 'chat'
        final loadedMessages = chatSnapshots.data!.docs;

        // Affichage de la liste des messages via ListView.builder (optimisé car dynamique)
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true, // Pour afficher les messages les plus récents en bas
          itemCount: loadedMessages.length,

          // Construction de chaque élément (message) de la liste
          itemBuilder: (ctx, index) {
            // Message actuel
            final chatMessage = loadedMessages[index].data();

            // Message suivant dans la liste (s'il existe)
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            // ID de l'utilisateur émetteur du message actuel et suivant
            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId = nextChatMessage != null
                ? nextChatMessage['userId']
                : null;

            // Vérifie si l'utilisateur du message suivant est le même que celui du message actuel
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            // Si même utilisateur → MessageBubble.next (sans avatar ni nom)
            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser!.uid == currentMessageUserId,
              );
            }
            // Sinon → MessageBubble.first (avec avatar et nom)
            else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser!.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
