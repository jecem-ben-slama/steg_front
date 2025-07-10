class Validators {
  /* Name Validation */
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Veillez Remplir ce champs";
    } else if (!RegExp(r"^[a-zA-Z ]+$").hasMatch(value)) {
      return "Ce champs ne doit contenir que des lettres et des espaces";
    } else {
      return null;
    }
  }

  /* LastName Validation */
  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return "Veillez Remplir ce champs";
    } else if (!RegExp(r"^[a-zA-Z ]+$").hasMatch(value)) {
      return "Le Prénom ne doit contenir que des lettres et des espaces";
    } else {
      return null;
    }
  }

  /* Phone Number Validation */
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Veillez Remplir ce champs";
    } else if (!RegExp(r"^[0-9]+$").hasMatch(value)) {
      return "Le numéro de téléphone ne doit contenir que des chiffres";
    } else if (value.length < 8) {
      return "Le numéro de téléphone doit contenir 8 chiffres";
    } else {
      return null; // Validation passed
    }
  }

  /* Mail Validation */
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Veillez Remplir ce champs";
    } else if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    ).hasMatch(value)) {
      return 'Veuillez saisir une adresse e-mail valide';
    }
    return null;
  }

  /* Password Validation */
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Veillez Remplir ce champs";
    } else if (value.length < 5) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  /* Number Validator */
  static String? validateNmbrs(String? value) {
    if (value == null || value.isEmpty) {
      return "Veillez Remplir ce champs";
    } else if (!RegExp(r"^[a-zA-Z0-9 ]+$").hasMatch(value)) {
      return "ce champs ne doit contenir que des lettres et des nombres";
    } else {
      return null;
    }
  }

  /* Standard Validator */
  static String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return "Veillez Remplir ce champs";
    } /*  else if (!RegExp(r"^[a-zA-Z0-9 ]+$").hasMatch(value)) {
      return "ce champs ne doit contenir que des lettres et des nombres";
    } */ else {
      return null;
    }
  }
}
