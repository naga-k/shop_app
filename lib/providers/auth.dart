import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exceptions.dart';

class Auth with ChangeNotifier {
  late String? _token;
  DateTime? _expirey;
  late String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expirey != null &&
        _expirey!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    try {
      final url = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAXhLykz2vZdxPnf-CvrWv8wb_NFUjHlBo');
      final response = await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      // if (response.body == null) {
      //   throw HttpException(message: 'Could not authenticate');
      // }
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(message: responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expirey = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expirey?.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      return _authenticate(email, password, 'signUp');
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logIn(String email, String password) async {
    try {
      return _authenticate(email, password, 'signInWithPassword');
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    } else {
      final extractedUserData = jsonDecode(prefs.getString('userData')!);
      final expiryDate =
          DateTime.parse(extractedUserData['expiryDate'] as String);
      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }
      _token = extractedUserData['token'] as String?;
      _userId = extractedUserData['userId'] as String?;
      _expirey = expiryDate;
      _autoLogout();
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expirey = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    notifyListeners();
  }

  void _autoLogout() {
    _authTimer?.cancel();
    final timeToExpire = _expirey?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire!), logout);
  }
}
