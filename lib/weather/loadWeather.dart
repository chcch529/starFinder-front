import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:seoul/models/model_weather.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class LoadWeather {
  Future<List<Weather>> getWeather() async {
    String apiKey = "8Ywtz7eDZK6mWNnZgc%2FP7OvdkCB3uLuAaic1CEMTa1%2BstbXTkhQf7HLvTtL3tmMD8nSYoyzwRQTB2wi8WJABew%3D%3D";

    tz.initializeTimeZones(); // 타임존 데이터 초기화
    var seoul = tz.getLocation('Asia/Seoul'); // 서울 타임존 가져오기
    DateTime SeouldateTime = tz.TZDateTime.now(seoul);

    String baseTime;
    String baseDate;
    DateTime yesterday = DateTime(SeouldateTime.year, SeouldateTime.month, SeouldateTime.day - 1);
    String formattedToday = DateFormat('yyyyMMdd').format(SeouldateTime);
    String formattedYesterday = DateFormat('yyyyMMdd').format(yesterday);


    if (SeouldateTime.minute < 40) {
      if (SeouldateTime.hour == 0) {
        // 자정 전이면 전날의 2300 사용
        baseTime = "2300";
        baseDate = formattedYesterday;
      } else {
        // 자정이 아니면 이전 시간의 00분을 사용
        int previousHour = SeouldateTime.hour - 1;
        baseTime = "${previousHour.toString().padLeft(2, '0')}00";
        baseDate = formattedToday;
      }
    } else {
      // 40분 이후라면 현재 시간의 00분을 사용
      baseTime = "${SeouldateTime.hour.toString().padLeft(2, '0')}00";
      baseDate = formattedToday;
    }


    int nx = 59;
    int ny = 127;

    String url = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=${apiKey}&numOfRows=60&pageNo=1&dataType=JSON&base_date=${baseDate}&base_time=${baseTime}&nx=${nx}&ny=${ny}";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = convert.utf8.decode(response.bodyBytes);
      Map<String, dynamic> jsonResult = convert.json.decode(body);
      List<dynamic> items = jsonResult['response']['body']['items']['item'];

      Map<String, Weather> weatherData = {};
      for (var item in items) {
        String dateTimeKey = "${item['baseDate']}${item['baseTime']}";
        if (!weatherData.containsKey(dateTimeKey)) {
          weatherData[dateTimeKey] = Weather();
        }

        switch (item['category']) {
          case 'T1H':
            double? parsedT1H = double.tryParse(item['obsrValue'].toString());
            if (parsedT1H != null) {
              weatherData[dateTimeKey]!.T1H = parsedT1H;
            }
            break;
          case 'SKY':
            int? parsedSKY = int.tryParse(item['obsrValue'].toString());
            if (parsedSKY != null) {
              weatherData[dateTimeKey]!.SKY = parsedSKY;
            }
            break;
        }
      }

      print(baseDate);
      print(baseTime);
      print(SeouldateTime);

      // Ensure only complete Weather objects are returned
      return weatherData.values.where((w) => w.T1H != null && w.SKY != null).toList();
    } else {
      throw Exception('Failed to load weather data with status code: ${response.statusCode}');
    }
  }
}
