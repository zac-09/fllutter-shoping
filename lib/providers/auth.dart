import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_shop/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

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

  String get userId {
    return _userId.toString();
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
      _autoLogout();
      notifyListeners();
      print("authenticated");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String()
      });
      print("saved data");
      print(userData);
      await prefs.setString('userData', userData);
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

  Future<bool> tryAutoLogin() async {
    print("trying auto login");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("trying shared prefs");

    if (prefs.containsKey("userData")) {
      print("returned false user data");

      return false;
    }
    final extractedUserData =
        prefs.getString("userData") as Map<String, Object>;
    print("trying ext data");

    final expiryDate =
        DateTime.parse(extractedUserData["expiryDate"].toString());
    if (expiryDate.isBefore(DateTime.now())) {
      print("returned false expiry");

      return false;
    }
    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    print("returned true");
    return true;
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
