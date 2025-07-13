import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});
  @override
  //build qui construit l'interface graphique du widget
  Widget build(BuildContext context) {
    return StreamBuilder( //StreamBuilder est un widget reactif qui ecoute un flux (stream) et qui construit automatiquement son
    //contenu à chaque nouvel evenement (comme ici une mise à jour des message). c'est lui qui gere les changements de données , donc pas besoin d'un Statefulwidget ici

      //le flux ecouté est celui de la collection chat dans firebase. chaque fois qu'un message est ajouté/supprimé/modifier, le stream envoie un evenement, et le StreamBuilder
      //reconstrui son enfant
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),

      //tant que la connexion avec firestore est en cours et qu'aucune donnée n'a encore été reçu, on affiche un CircularProgressIndicator
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        //Si aucune données n'est presente (pas encore de messages dans firebase), on affiche un message indiquant qu'il n'ya aucun message
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }
        //s'il ya une erreur
        if (chatSnapshots.hasError) {
          return const Center(child: Text('Something went wrong...'));
        }

        //on recupere la liste des documents(messages) presents dans chat
        final loadedMessages = chatSnapshots.data!.docs;


        //on retourne une listeView.builder qui crée dynamiquement un widget Text pour chaque
        //message recupéré dans la collection
        return ListView.builder(
          padding: const EdgeInsets.only(bottom:40,left:13,right:13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) =>
              Text(loadedMessages[index].data()['text']),
        );
      },
    );
  }
}
