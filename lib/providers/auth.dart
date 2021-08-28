import 'package:flutter/widgets.dart';
import 'package:flutter_shop/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token.toString();
    } else {
      return '';
    }
  }

  Future<void> _authenticate(
      String email, String password, bool isSignup) async {
    final url = isSignup
        ? "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAvz9wE_vSjkQqs0LGwhoUsJrLrh6Ke4OE"
        : "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAvz9wE_vSjkQqs0LGwhoUsJrLrh6Ke4OE";
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, true);
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, false);
  }
}
