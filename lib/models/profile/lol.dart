class LOLUser {
  String? id;
  String? name;
  int? profileIconId;
  int? summonerLevel;
  String? soloTier;
  String? soloRank;
  int? soloLeaguePoints;
  String? flexTier;
  String? flexRank;
  int? flexLeaguePoints;

  LOLUser(
      {this.id,
      this.name,
      this.profileIconId,
      this.summonerLevel,
      this.soloTier,
      this.soloRank,
      this.soloLeaguePoints,
      this.flexTier,
      this.flexRank,
      this.flexLeaguePoints});

  @override
  String toString() {
    return "LOLUser: {id: $id, name: $name, profileIconId: $profileIconId, summonerLevel: $summonerLevel, soloTier: $soloTier, soloRank: $soloRank, soloLeaguePoints: $soloLeaguePoints, flexTier: $flexTier, flexRank: $flexRank, flexLeaguePoints: $flexLeaguePoints}";
  }

  factory LOLUser.fromJson(List<dynamic> json) {
    // 랭크 기록이 없을 때
    if (json.length == 1) {
      return LOLUser(
        id: json[0]["id"],
        name: json[0]["name"],
        profileIconId: json[0]["profileIconId"],
        summonerLevel: json[0]["summonerLevel"],
      );
    }
    // 솔로 랭크 기록이 있을 때
    else if (json[1]["queueType"] == "RANKED_SOLO_5x5") {
      // 솔로 랭크, 자유 랭크 모두 있을 때
      if (json.length > 2) {
        return LOLUser(
          id: json[0]["id"],
          name: json[0]["name"],
          profileIconId: json[0]["profileIconId"],
          summonerLevel: json[0]["summonerLevel"],
          soloTier: json[1]["tier"],
          soloRank: json[1]["rank"],
          soloLeaguePoints: json[1]["leaguePoints"],
          flexTier: json[2]["tier"],
          flexRank: json[2]["rank"],
          flexLeaguePoints: json[2]["leaguePoints"],
        );
      }
      // 솔로 랭크 기록만 있을 때
      else {
        return LOLUser(
          id: json[0]["id"],
          name: json[0]["name"],
          profileIconId: json[0]["profileIconId"],
          summonerLevel: json[0]["summonerLevel"],
          soloTier: json[1]["tier"],
          soloRank: json[1]["rank"],
          soloLeaguePoints: json[1]["leaguePoints"],
        );
      }
    }
    // 자유 랭크 기록이 있을 때
    else if (json[1]["queueType"] == "RANKED_FLEX_SR") {
      // 솔로 랭크, 자유 랭크 모두 있을 때
      if (json.length > 2) {
        return LOLUser(
          id: json[0]["id"],
          name: json[0]["name"],
          profileIconId: json[0]["profileIconId"],
          summonerLevel: json[0]["summonerLevel"],
          soloTier: json[2]["tier"],
          soloRank: json[2]["rank"],
          soloLeaguePoints: json[2]["leaguePoints"],
          flexTier: json[1]["tier"],
          flexRank: json[1]["rank"],
          flexLeaguePoints: json[1]["leaguePoints"],
        );
      }
      // 자유 랭크 기록만 있을 때
      else {
        return LOLUser(
          id: json[0]["id"],
          name: json[0]["name"],
          profileIconId: json[0]["profileIconId"],
          summonerLevel: json[0]["summonerLevel"],
          flexTier: json[1]["tier"],
          flexRank: json[1]["rank"],
          flexLeaguePoints: json[1]["leaguePoints"],
        );
      }
    }
    // 아무 기록도 없을 때
    else
      return LOLUser();
  }
  String get profileIconUrl =>
      "https://ddragon.leagueoflegends.com/cdn/11.6.1/img/profileicon/$profileIconId.png";
}
