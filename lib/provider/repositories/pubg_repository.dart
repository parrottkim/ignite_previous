import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ignite/models/profile/pubg.dart';

class PUBGRepository {
  final headers = {
    'Authorization': 'Bearer XXXX',
    'Accept': 'application/vnd.api+json'
  };

  Future getCurrentSeason() async {
    final url = 'https://api.pubg.com/shards/steam/seasons';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> seasonData = jsonDecode(response.body);
      List seasons = seasonData['data'];
      for (var season in seasons) {
        // 현재 활성화된 시즌 찾아서 리턴
        if (season['attributes']['isCurrentSeason'] == true) {
          print(season['id']);
          return season['id'];
        }
      }
    }
  }

  Future getUserName(String username, String server) async {
    final url =
        'https://api.pubg.com/shards/$server/players?filter[playerNames]=$username';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = jsonDecode(response.body);
      List userInfo = userData['data'];
      String season = await getCurrentSeason();
      return await getUserData(season, userInfo, server);
    }
  }

  Future getUserData(String season, List userInfo, String server) async {
    final url =
        'https://api.pubg.com/shards/$server/players/${userInfo.first['id']}/seasons/$season/ranked';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = jsonDecode(response.body);
      final Map<String, dynamic> rankData =
          userData['data']['attributes']['rankedGameModeStats'];
      print(rankData);
      return PUBGUser.fromJson(userInfo, rankData);
    } else
      return null;
  }
}
