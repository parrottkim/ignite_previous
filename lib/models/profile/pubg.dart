class PUBGUser {
  String? accountId;
  String? name;
  String? soloTier;
  String? soloRank;
  int? soloPoints;
  String? squadTier;
  String? squadRank;
  int? squadPoints;

  PUBGUser(
      {this.accountId,
      this.name,
      this.soloTier,
      this.soloRank,
      this.soloPoints,
      this.squadTier,
      this.squadRank,
      this.squadPoints});

  @override
  String toString() {
    return "USER INFO:\n[name: $name\naccountId: $accountId\nsoloTier: $soloTier\nsoloRank: $soloRank\nsoloPoints: $soloPoints\nsquadTier: $squadTier\nsquadRank: $squadRank\nrankPoints: $squadPoints";
  }

  factory PUBGUser.fromJson(List userInfo, Map<String, dynamic> rankData) {
    if (rankData["solo"] != null) {
      if (rankData["squad"] != null) {
        return PUBGUser(
          accountId: userInfo.first["id"],
          name: userInfo.first["attributes"]["name"],
          soloTier: rankData["solo"]["currentTier"]["tier"],
          soloRank: rankData["solo"]["currentTier"]["subTier"],
          soloPoints: rankData["solo"]["currentRankPoint"],
          squadTier: rankData["squad"]["currentTier"]["tier"],
          squadRank: rankData["squad"]["currentTier"]["subTier"],
          squadPoints: rankData["squad"]["currentRankPoint"],
        );
      } else {
        return PUBGUser(
          accountId: userInfo.first["id"],
          name: userInfo.first["attributes"]["name"],
          soloTier: rankData["solo"]["currentTier"]["tier"],
          soloRank: rankData["solo"]["currentTier"]["subTier"],
          soloPoints: rankData["solo"]["currentRankPoint"],
        );
      }
    } else if (rankData["squad"] != null) {
      return PUBGUser(
        accountId: userInfo.first["id"],
        name: userInfo.first["attributes"]["name"],
        squadTier: rankData["squad"]["currentTier"]["tier"],
        squadRank: rankData["squad"]["currentTier"]["subTier"],
        squadPoints: rankData["squad"]["currentRankPoint"],
      );
    } else if (rankData.isEmpty) {
      return PUBGUser(
        accountId: userInfo.first["id"],
        name: userInfo.first["attributes"]["name"],
      );
    } else
      return PUBGUser();
  }
}
