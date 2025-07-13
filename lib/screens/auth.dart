import 'dart:io';

// Importation des widgets de base de Flutter

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

// Définition de l'écran d'authentification, c'est un StatefulWidget car on aura des données qui changent (email, password, mode login/signup)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreen();
  }
}

// La classe associée à AuthScreen
class _AuthScreen extends State<AuthScreen> {
  // Clé globale pour identifier et gérer le formulaire
  final _form = GlobalKey<FormState>();

  // Variables pour stocker ce que l'utilisateur tape
  var _enteredEmail = '';
  var _enteredPassword = '';

  File? _selectedImage;

  // Variable pour savoir si on est en mode login ou signup
  var _isLogin = true;

  // Fonction déclenchée quand on clique sur le bouton Login/Signup
  void _submit() async {
    // On valide le formulaire (appel des validateurs des champs)
    final isvalid = _form.currentState!.validate();

    if (!isvalid || !_isLogin && _selectedImage == null) {
      //show error message...
      return;
    }
    // On sauvegarde les valeurs (déclenche les onSaved() de chaque champ)
    _form.currentState!.save();

    try {
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentification failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Couleur de fond de l'écran : on prend celle du thème
      backgroundColor: Theme.of(context).colorScheme.primary,

      // On centre verticalement et horizontalement le contenu
      body: Center(
        child: SingleChildScrollView(
          // Permet de scroller si l'écran est petit (important sur mobile)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image du haut
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),

              // La carte blanche contenant le formulaire
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form, // Clé pour identifier ce formulaire
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          // Champ email
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Adress',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,

                            // Fonction de validation du champ email
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },

                            // Quand on sauvegarde le formulaire, on récupère cette valeur
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),

                          // Champ password
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText:
                                true, // Masque le texte pour le mot de passe
                            // Validation du mot de passe
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },

                            // Sauvegarde de la valeur du mot de passe
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Bouton de soumission (login/signup)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),

                          // Lien pour basculer entre Login et Signup
                          TextButton(
                            onPressed: () {
                              // On inverse l'état du bouton avec setState
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Create an account'
                                  : 'I already have a account, Login.',
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
