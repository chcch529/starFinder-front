import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoul/models/model_weather.dart';
import 'package:seoul/weather/provideWeather.dart';

class WeatherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.wth.isEmpty) {
          return Center(child: Text('No weather data available.'));
        }
        return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(50),
          width: 100, height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: provider.wth.map((weather) {
              return Column(
                children: <Widget>[
                  _getWeatherIcon(weather.SKY!),
                  SizedBox(height: 5),
                  Text('${weather.T1H.toString()}°C',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _getWeatherIcon(int sky) {
    if (sky <= 5) {
      return Icon(Icons.wb_sunny_outlined, size: 30,);  // 맑음
    } else if (sky <= 8) {
      return SizedBox(
        width: 30,
        height: 30,
        child: Image.asset('assets/images/suncloud.png'),  // 구름 많음
      );
    } else {
      return Icon(Icons.cloud_queue, size: 30,);  // 흐림
    }
  }
}
