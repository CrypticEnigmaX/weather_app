import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final String iconcode;
  final String temperature;
  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.iconcode,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    DateTime localTime = DateTime.parse(time).toLocal();
    String timeOnly = DateFormat('HH:mm a').format(localTime);

    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),

        child: Column(
          children: [
            Text(
              timeOnly,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 48,
              width: 48,
              child: Image.network(
                "https://openweathermap.org/img/wn/$iconcode@2x.png",
              ),
            ),
            const SizedBox(height: 8),
            Text(temperature),
          ],
        ),
      ),
    );
  }
}
