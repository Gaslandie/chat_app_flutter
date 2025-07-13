// Importation des fonctionnalités de gestion de fichiers
import 'dart:io';

// Importation des widgets de base de Flutter et des packages utilisés
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Référence à l'instance de Firebase Auth
final _firebase = FirebaseAuth.instance;

/// Écran d'authentification de l'application.
/// Ce widget permet à l'utilisateur de :
/// - Se connecter avec un email/mot de passe existant
/// - Créer un nouveau compte avec image de profil et pseudo
/// - Basculer entre login et inscription
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreen();
  }
}

/// Classe associée à l'écran d'authentification
/// Utilise un `StatefulWidget` car l'état du formulaire change dynamiquement
class _AuthScreen extends State<AuthScreen> {
  /// Clé pour identifier le formulaire et permettre sa validation
  final _form = GlobalKey<FormState>();

  // Variables pour stocker les valeurs saisies dans le formulaire
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;

  /// Booléen pour déterminer si on est en mode connexion (true) ou inscription (false)
  var _isLogin = true;

  /// Booléen pour afficher un indicateur de chargement lors de l'authentification
  var _isAuthenticating = false;

  /// Fonction appelée lorsque l'utilisateur valide le formulaire
  void _submit() async {
    // Validation des champs du formulaire
    final isValid = _form.currentState!.validate();

    // Si formulaire invalide ou pas d'image sélectionnée en mode signup → on quitte
    if (!isValid || (!_isLogin && _selectedImage == null)) {
      return;
    }

    // Sauvegarde des données saisies (déclenche les `onSaved` des champs)
    _form.currentState!.save();

    try {
      // Active l'indicateur de chargement
      setState(() {
        _isAuthenticating = true;
      });

      // Connexion utilisateur
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      }
      // Inscription utilisateur
      else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Stockage de l'image de profil sur Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref() // Racine du stockage
            .child('user_images') // Dossier des images utilisateurs
            .child('${userCredentials.user!.uid}.jpg'); // Nom unique pour chaque image

        // Upload du fichier image
        await storageRef.putFile(_selectedImage!);

        // Récupération de l'URL publique de l'image
        final imageUrl = await storageRef.getDownloadURL();

        // Enregistrement des infos utilisateur dans Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid) // Doc avec même UID que l'utilisateur
            .set({
              'username': _enteredUsername,
              'email': _enteredEmail,
              'image_url': imageUrl,
            });
      }
    }

    // Gestion des erreurs d'authentification
    on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // Optionnel : traitement spécifique si email déjà utilisé
      }
      // Affichage d'un message via SnackBar
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentification failed')),
      );
    }

    // Quoi qu'il arrive, on désactive le chargement à la fin
    finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  /// Construction de l'interface graphique
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Couleur de fond de l'écran
      backgroundColor: Theme.of(context).colorScheme.primary,

      // Centrage vertical et horizontal du contenu
      body: Center(
        child: SingleChildScrollView(
          // Permet le scroll si le clavier masque les éléments
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou image de présentation en haut
              Container(
                margin: const EdgeInsets.all(20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),

              // Formulaire contenu dans une carte
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form, // Clé du formulaire
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Picker d'image uniquement en mode inscription
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),

                          // Champ Email
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),

                          // Champ Username (uniquement inscription)
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter a valid username (at least 4 characters)';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),

                          // Champ Password
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Indicateur de chargement ou bouton de soumission
                          if (_isAuthenticating)
                            const CircularProgressIndicator()
                          else
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_isLogin ? 'Login' : 'Signup'),
                            ),

                          // Bouton pour basculer entre Login et Signup
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Create an account'
                                  : 'I already have an account, Login.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
