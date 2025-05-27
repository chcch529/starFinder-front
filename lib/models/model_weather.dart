class Weather {
  double? T1H;  // 기온
  int? SKY;     // 하늘 상태

  Weather({this.T1H = 0.0, this.SKY = 0});
}
//   factory Weather.fromJson(Map<String, dynamic> json){
//     return Weather(
//       T1H: json['T1H'] as double,
//       SKY: json['SKY'] as int,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'T1H': T1H,
//     'SKY': SKY,
//   };
//
// }
// RN1, T1H, UUU, VVV, WSD 실수로 제공