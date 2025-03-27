import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:whether_app/aditional_weather.dart';
import 'package:whether_app/secrets.dart';
import 'package:whether_app/weather_forcast_item.dart';
import 'package:http/http.dart' as http;

class WhetherScreen extends StatefulWidget {
  const WhetherScreen({super.key});

  @override
  State<WhetherScreen> createState() => _WhetherScreenState();
}

class _WhetherScreenState extends State<WhetherScreen> {
  String cityName = 'London';
  String prevCity = '';
  void _showSearchDialog() {
    TextEditingController cityController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter City Name'),
          content: TextField(
            controller: cityController,
            decoration: InputDecoration(hintText: 'Type City Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newCity = cityController.text.trim();
                if (newCity.isEmpty) {
                  // Show a message instead of closing immediately
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a city name')),
                  );
                  return;
                }
                setState(() {
                  if (newCity.isNotEmpty) {
                    cityName = newCity[0].toUpperCase() + newCity.substring(1);
                    prevCity = cityName;
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> getCurrentWeather(String searchcity) async {
    try {
      String city = searchcity;
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$openwhetherapikey',
        ),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != "200") {
        throw Exception('City not found or API error.');
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Weather App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: Icon(Icons.refresh),
            ),
          ],
          leading: IconButton(
            onPressed: _showSearchDialog,
            icon: Icon(Icons.search_sharp),
          ),
        ),
      ),
      body: FutureBuilder(
        future: getCurrentWeather(cityName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'] - 273.15;
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentIconCode = currentWeatherData['weather'][0]['icon'];
          // aditional information
          final humdity = currentWeatherData['main']['humidity'];
          final windspeed = currentWeatherData['wind']['speed'];
          final presure = currentWeatherData['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              // Added to make the content scrollable
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color.fromARGB(255, 122, 130, 138),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin),
                                      Text(
                                        cityName,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${currentTemp.toStringAsFixed(0)}°C',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    height: 65,
                                    width: 65,
                                    child: Image.network(
                                      "https://openweathermap.org/img/wn/$currentIconCode@2x.png",
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    currentSky,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // weather forecast cards
                  const SizedBox(height: 60),
                  Text(
                    'Hourly Forecast',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data['list'].length - 1,
                      itemBuilder: (context, index) {
                        return HourlyForecastItem(
                          time: data['list'][index + 1]['dt_txt'].toString(),
                          iconcode:
                              data['list'][index + 1]['weather'][0]['icon'],
                          temperature:
                              '${(data['list'][index + 1]['main']['temp'] - 273.15).toStringAsFixed(0)}°C',
                        );
                      },
                    ),
                  ),
                  // additional weather information
                  const SizedBox(height: 60),
                  Text(
                    'Additional Information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      aditionalweatherinformation(
                        icon: Icons.water_drop_sharp,
                        condition: 'Humidity',
                        valcondion: humdity.toString(),
                      ),
                      aditionalweatherinformation(
                        icon: Icons.air_sharp,
                        condition: 'Wind Speed',
                        valcondion: windspeed.toString(),
                      ),
                      aditionalweatherinformation(
                        icon: Icons.thermostat_sharp,
                        condition: 'Pressure',
                        valcondion: presure.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
