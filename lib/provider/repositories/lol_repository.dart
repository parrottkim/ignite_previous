import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ignite/models/profile/lol.dart';

class LOLRepository {
  final headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36',
    'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
    'Accept-Charset': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Origin': 'https://developer.riotgames.com',
    'X-Riot-Token': 'XXXX',
  };

  Future getUserName(String username) async {
    final url =
        'https://kr.api.riotgames.com/lol/summoner/v4/summoners/by-name/' +
            username;
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return await getUserData(body);
    }
  }

  Future getUserData(Map<String, dynamic> userData) async {
    final url =
        'https://kr.api.riotgames.com/lol/league/v4/entries/by-summoner/' +
            userData['id'];
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = [];
      body.add(userData);
      for (var element in jsonDecode(response.body)) {
        body.add(element);
      }
      print(body);
      return LOLUser.fromJson(body);
    } else {
      return null;
    }
  }
}
