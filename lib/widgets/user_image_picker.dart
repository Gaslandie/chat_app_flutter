// Importation des packages nécessaires
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget permettant à l'utilisateur de sélectionner une image de profil.
/// Ce composant :
/// - Affiche un avatar circulaire (vide ou avec l'image choisie)
/// - Propose un bouton pour prendre une photo via l'appareil photo
/// - Appelle un callback pour transmettre l'image sélectionnée au parent
class UserImagePicker extends StatefulWidget {
  /// Constructeur du composant
  /// [onPickImage] : fonction callback appelée lorsque l'utilisateur sélectionne une image
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

/// Classe associée au widget UserImagePicker
/// Utilise un `StatefulWidget` car on doit stocker l'image sélectionnée localement
class _UserImagePickerState extends State<UserImagePicker> {
  /// Variable pour stocker l'image sélectionnée (de type File)
  File? _pickedImageFile;

  /// Fonction déclenchée quand l'utilisateur appuie sur le bouton d'ajout d'image
  /// Utilise `ImagePicker` pour ouvrir l'appareil photo
  void _pickImage() async {
    // Ouvre l'appareil photo et récupère l'image prise
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera, // Source : appareil photo
      imageQuality: 50, // Compression de l'image pour limiter le poids
      maxWidth: 150, // Taille max en largeur pour limiter la résolution
    );

    // Si l'utilisateur annule la prise de photo, on quitte la fonction
    if (pickedImage == null) {
      return;
    }

    // On transforme le fichier récupéré (XFile) en File classique de Dart
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    // On appelle le callback du parent pour lui transmettre l'image sélectionnée
    widget.onPickImage(_pickedImageFile!);
  }

  /// Construction de l'interface graphique
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar circulaire qui affiche l'image choisie si elle existe
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImageFile != null
              ? FileImage(_pickedImageFile!) // Affiche l'image sélectionnée
              : null, // Sinon reste vide
        ),

        // Bouton permettant d'ouvrir l'appareil photo
        TextButton.icon(
          icon: const Icon(Icons.image),
          onPressed: _pickImage, // Action : ouvrir appareil photo
          label: Text(
            'Add Image',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
