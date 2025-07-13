import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessage();
  }
}

class _NewMessage extends State<NewMessage> {
  var _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  //fonction appelée quand le user veut envoyer un message
  //asynchrone car on va interagir avec FireStore
  void _submitMessage() async {

    //recuperation du texte actuellement dans le champ texte du message
    final enteredMessage = _messageController.text;

    //si le message est vide ou ne contient que des espace, on quitte la fonction
    //pour eviter d'envoyer des messages vides dans la bd
    if (enteredMessage.trim().isEmpty) {
      return;
    }

    //retire le focus du champs text, pour masquer le clavier après avoir envoyé le message
    FocusScope.of(context).unfocus();
    _messageController.clear();//vide le champs texte après envoie, pour le remettre propre pour le prochain message

    //reupere l'utilisateur actuellement connecté via Firebase Auth
    //le ! signifie qu'on est certain qu'il ya un utilisateur (car sinon cette fonction ne devrait pas etre accessible)
    final user = FirebaseAuth.instance.currentUser!;
    //va chercher dans Firestore , dans la collection users, le document coresspondant au user actuel grâce à son uid
    //parce qu'on a besoin de ses infos associés(username et image) pour les attacher au message
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    //on ajoute un nouveau document dans la collection chat
    //pour stocker chaque message comme un document independant dans Firestore
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _submitMessage,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
