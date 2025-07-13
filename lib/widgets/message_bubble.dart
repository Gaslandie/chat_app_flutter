import 'package:flutter/material.dart';

/// Un composant qui affiche une bulle de message dans une interface de chat.
/// Ce widget gère :
/// - L'affichage différencié du premier message d'une séquence
/// - L'alignement gauche/droite selon l'émetteur
/// - L'intégration d'avatar et de nom d'utilisateur
class MessageBubble extends StatelessWidget {
  /// Constructeur pour le premier message d'une séquence.
  /// [userImage] : URL de l'image de profil de l'utilisateur
  /// [username] : Le nom à afficher pour ce message
  /// [message] : Le contenu textuel du message
  /// [isMe] : Si true, aligne le message à droite (utilisateur courant)
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  /// Constructeur pour les messages suivants dans une séquence.
  /// Plus léger car ne nécessite pas les infos utilisateur répétitives.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  // -----------------------------------------
  // Propriétés
  // -----------------------------------------

  /// Indique si ce message est le premier d'une séquence du même utilisateur.
  /// Cela influence :
  /// - L'affichage de l'avatar
  /// - L'affichage du nom
  /// - La forme de la bulle (coin pointu vers l'avatar)
  final bool isFirstInSequence;

  /// URL de l'image de profil. Null si pas le premier de la séquence.
  final String? userImage;

  /// Nom d'utilisateur. Null si pas le premier de la séquence.
  final String? username;

  /// Le contenu textuel du message à afficher.
  final String message;

  /// Si true, le message est aligné à droite (utilisateur courant).
  /// Si false, aligné à gauche (interlocuteur).
  final bool isMe;

  // -----------------------------------------
  // Construction de l'interface
  // -----------------------------------------

  @override
  Widget build(BuildContext context) {
    // Récupération du thème pour adapter les couleurs
    final theme = Theme.of(context);

    // Utilisation d'une Stack pour superposer l'avatar et la bulle
    return Stack(
      children: [
        // Affichage conditionnel de l'avatar (uniquement pour premier message)
        if (userImage != null)
          Positioned(
            top: 15,
            // Positionnement à droite ou gauche selon l'émetteur
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: NetworkImage(userImage!),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23, // Taille fixe pour l'avatar
            ),
          ),

        // Conteneur principal de la bulle
        Container(
          // Marge horizontale pour laisser l'espace à l'avatar
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            // Alignement horizontal selon l'émetteur
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                // Alignement du texte à gauche ou droite
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Espacement supplémentaire pour le premier message
                  if (isFirstInSequence) const SizedBox(height: 18),

                  // Affichage conditionnel du nom d'utilisateur
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 13, right: 13),
                      child: Text(
                        username!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  // La bulle de message proprement dite
                  Container(
                    decoration: BoxDecoration(
                      // Couleur différente selon l'émetteur
                      color: isMe
                          ? Colors.grey[300] // Couleur neutre pour l'utilisateur
                          : theme.colorScheme.secondary.withAlpha(200), // Couleur du thème pour l'interlocuteur
                      
                      // Forme spéciale de la bulle :
                      // - Coin droit ou gauche coupé pour le premier message
                      // - Coins arrondis pour les suivants
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? Radius.zero // Coin carré pour lier visuellement à l'avatar
                            : const Radius.circular(12),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero // Coin carré pour lier visuellement à l'avatar
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12), // Toujours arrondi en bas
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    // Contraintes pour éviter que la bulle ne s'étende trop
                    constraints: const BoxConstraints(maxWidth: 200),
                    // Espace interne du texte
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    // Marge externe de la bulle
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    // Le texte du message
                    child: Text(
                      message,
                      style: TextStyle(
                        height: 1.3, // Interligne légèrement augmenté
                        color: isMe
                            ? Colors.black87 // Noir pour l'utilisateur
                            : theme.colorScheme.onSecondary, // Couleur contrastante du thème pour l'interlocuteur
                      ),
                      softWrap: true, // Retour à la ligne automatique
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}