
var _username = ["admin@gmail.com"];
var _password = ["password123"];
int _i = 1;

class Authentication {
  bool fetchCredentials(String username, String password) {
    for (var j = 0; j < _username.length; j++) {
      if (username == _username[j] && password == _password[j]) {
        return true;
      }
    }
    return false;
  }

  bool checkUserRepeat(username) {
    for (var j = 0; j < _username.length; j++) {
      if (username == _username[j]) {
        print(username);
        return true;
      }
    }
    return false;
  }

  void insertCredentials(username, password) {
    _username.add(username);
    _password.add(password);
    _i++;
  }

  bool isPasswordCompliant(String password, [int minLength = 6]) {
    if (password.isEmpty) {
      return false;
    }

    bool hasUppercase = password.contains( RegExp(r'[A-Z]'));
    bool hasDigits = password.contains( RegExp(r'[0-9]'));
    bool hasLowercase = password.contains( RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length > minLength;

    return hasDigits &
        hasUppercase &
        hasLowercase &
        hasSpecialCharacters &
        hasMinLength;
  }
}