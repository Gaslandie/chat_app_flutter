// Importation des dépendances nécessaires
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Widget permettant d’écrire et d’envoyer un nouveau message dans le chat.
/// Ce composant :
/// - Affiche un champ texte pour saisir un message
/// - Gère l’envoi du message dans Firestore
/// - Attache les infos de l’utilisateur (pseudo, image)
/// - Vide le champ et masque le clavier après envoi
class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessage();
  }
}

/// Classe associée au widget NewMessage.
/// Utilise un `StatefulWidget` car le champ texte et son contenu changent.
class _NewMessage extends State<NewMessage> {
  /// Contrôleur pour gérer le contenu du champ texte.
  final _messageController = TextEditingController();

  /// Méthode appelée automatiquement lorsque le widget est retiré de l’arbre
  /// On en profite pour libérer proprement le contrôleur.
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Fonction déclenchée lorsqu’on appuie sur le bouton d’envoi
  /// Asynchrone car elle interagit avec Firestore.
  void _submitMessage() async {
    // Récupération du texte actuellement saisi
    final enteredMessage = _messageController.text;

    // Si le champ est vide ou contient uniquement des espaces, on annule l’envoi
    if (enteredMessage.trim().isEmpty) {
      return;
    }

    // Retire le focus du champ texte pour masquer le clavier
    FocusScope.of(context).unfocus();

    // Vide le champ texte après envoi
    _messageController.clear();

    // Récupère l’utilisateur actuellement connecté
    final user = FirebaseAuth.instance.currentUser!;

    // Récupère les infos associées à l’utilisateur (pseudo, image)
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Ajout d’un nouveau message dans la collection 'chat'
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage, // Contenu du message
      'createdAt': Timestamp.now(), // Horodatage pour l’ordre d’affichage
      'userId': user.uid, // UID de l’expéditeur
      'username': userData.data()!['username'], // Pseudo de l’utilisateur
      'userImage': userData.data()!['image_url'], // URL de l’image de profil
    });
  }

  /// Construction de l’interface graphique
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          // Champ texte étirable (prend tout l’espace restant)
          Expanded(
            child: TextField(
              controller: _messageController, // Contrôleur du champ
              textCapitalization: TextCapitalization.sentences, // Majuscule automatique en début de phrase
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          // Bouton d’envoi
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _submitMessage, // Action : envoyer le message
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
