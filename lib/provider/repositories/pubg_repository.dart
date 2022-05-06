import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/models/profile/pubg.dart';

class PUBGRepository {
  final headers = {
    'Authorization': 'Bearer ${dotenv.env['pubg_key']!}',
    'Accept': 'application/vnd.api+json'
  };
  final steamKey = dotenv.env['steam_key']!;

  Future getSteamProfile(String username) async {
    final url =
        'http://api.steampowered.com/ISteamUser/ResolveVanityURL/v0001/?key=${steamKey}&vanityurl=${username}';
    final response = await http.get(
      Uri.parse(url),
    );
    if (jsonDecode(response.body)['response']['success'] == 1) {
      return await getSteamProfileImage(
          jsonDecode(response.body)['response']['steamid']);
    } else
      return null;
  }

  Future getSteamProfileImage(String steamid) async {
    final url =
        'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=${steamKey}&steamids=${steamid}';
    final response = await http.get(
      Uri.parse(url),
    );
    return jsonDecode(response.body)['response']['players'][0]['avatarfull'];
  }

  Future getCurrentSeason() async {
    const url = 'https://api.pubg.com/shards/steam/seasons';
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
      return await getUserData(season, userInfo, server, username);
    }
  }

  Future getUserData(
      String season, List userInfo, String server, String username) async {
    final url =
        'https://api.pubg.com/shards/$server/players/${userInfo.first['id']}/seasons/$season/ranked';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final profileImage = await getSteamProfile(username);
      final Map<String, dynamic> userData = jsonDecode(response.body);
      final Map<String, dynamic> rankData =
          userData['data']['attributes']['rankedGameModeStats'];
      return PUBGUser.fromJson(userInfo, rankData, profileImage, server);
    } else
      return null;
  }
}
