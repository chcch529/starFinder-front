import 'package:flutter/cupertino.dart';
import 'package:seoul/weather/loadWeather.dart';

import '../models/model_weather.dart';

class WeatherProvider extends ChangeNotifier {
  LoadWeather _loadWeather = LoadWeather();
  List<Weather> _wth = [];
  List<Weather> get wth => _wth;

  Future<void> loadWeather() async {
    try {
      List<Weather>? listWth = await _loadWeather.getWeather();
      if (listWth != null && listWth.isNotEmpty) {
        _wth = listWth;
        notifyListeners(); // 상태가 업데이트되었음을 알림
      } else {
        print("No data received or data is empty");
      }
    } catch (e) {
      print("Failed to load weather: $e");
    }
  }
}