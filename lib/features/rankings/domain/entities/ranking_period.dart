enum RankingPeriod {
  yesterday('昨日', '15'),
  month('上月', '13'),
  year('去年', '12'),
  allTime('总榜', '11');

  const RankingPeriod(this.label, this.endpointValue);

  final String label;
  final String endpointValue;
}
