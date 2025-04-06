import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  bool isLoading = true;
  Map<String, dynamic>? weatherData;
  List<dynamic>? forecastData;
  Position? currentPosition;
  String errorMessage = '';
  String farmingAdvice = '';
  bool adviceAlreadyGenerated = false;

  // You'll need to get your own API key from OpenWeatherMap
  final String apiKey = 'YOUR_API_KEY';

  @override
  void initState() {
    super.initState();
    _getLocationAndWeather();
  }

  Future<void> _getLocationAndWeather() async {
    await getPermission(context);
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Request location permission
      var status = await Permission.location.request();

      if (status.isGranted) {
        // Get current position
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
        );

        setState(() {
          currentPosition = position;
        });

        // Fetch weather data
        await _fetchWeatherData(position.latitude, position.longitude);
        await _fetchForecastData(position.latitude, position.longitude);
      } else {
        setState(() {
          errorMessage = 'Location permission denied. Using default location.';
          // Use a default location (e.g., New Delhi)
          _fetchWeatherData(28.6139, 77.2090);
          _fetchForecastData(28.6139, 77.2090);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error getting location: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> getPermission(BuildContext context) async {
    final status = await Permission.location.request();
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load weather data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching weather data: $e';
      });
    }
  }

  // Add this new method to get state information
  Future<void> _fetchLocationDetails(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            // Add state information to weatherData
            weatherData!['state'] = data[0]['state'] ?? '';
          });
        }
      }
    } catch (e) {
      // Just log the error - we'll handle the UI regardless
      print('Error getting state details: $e');
    }
  }

  Future<void> _fetchForecastData(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          forecastData = data['list'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load forecast data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching forecast data: $e';
        isLoading = false;
      });
    }
  }

  String _getWeatherIcon(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  Future<void> _getFarmingAdvice(String weatherMain, double temp) async {
    if (adviceAlreadyGenerated) {
      return;
    }
    try {
      // Initialize the Gemini model
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'YOUR_API_KEY', // Replace with your actual API key
      );

      // Create a prompt that describes the current weather conditions
      final prompt =
          'As a farming expert, provide specific and concise advice (maximum 2-3 sentences) for farmers based on these weather conditions: Weather type: $weatherMain, Temperature: $temp°C. Include practical recommendations for crop protection, field work, irrigation, or livestock care as appropriate.';

      // Generate content using Gemini
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        farmingAdvice =
            response.text ??
            'Unable to generate farming advice. Please check weather conditions and try again.';
        adviceAlreadyGenerated = true;
      });
    } catch (e) {
      farmingAdvice =
          'Unable to generate farming advice due to a technical issue. Please try again later.';
      adviceAlreadyGenerated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Weather Forecast',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            onPressed: _getLocationAndWeather,
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: colorScheme.tertiary),
              )
              : errorMessage.isNotEmpty && weatherData == null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.onPrimaryFixed,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _getLocationAndWeather,
                        child: Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.tertiary,
                          foregroundColor: colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _getLocationAndWeather,
                color: colorScheme.tertiary,
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 16),
                  children: [
                    if (weatherData != null) _buildCurrentWeather(colorScheme),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: colorScheme.onPrimaryFixed),
                        ),
                      ),
                    if (weatherData != null) _buildFarmingAdvice(colorScheme),
                    if (forecastData != null) _buildHourlyForecast(colorScheme),
                    if (forecastData != null) _buildDailyForecast(colorScheme),
                    SizedBox(
                      height: 60,
                    ), // Add padding at the bottom for navigation bar
                  ],
                ),
              ),
    );
  }

  Widget _buildCurrentWeather(ColorScheme colorScheme) {
    final weather = weatherData!;
    final temp = weather['main']['temp'];
    final weatherMain = weather['weather'][0]['main'];
    final weatherDesc = weather['weather'][0]['description'];
    final iconCode = weather['weather'][0]['icon'];
    final cityName = weather['name'];
    final humidity = weather['main']['humidity'];
    final windSpeed = weather['wind']['speed'];

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cityName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Add state name here
                    if (weather.containsKey('state') && weather['state'] != '')
                      Text(
                        weather['state'],
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onPrimary.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      DateFormat('EEEE, d MMMM').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.onSecondaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: FittedBox(child: Text(_getWeatherEmoji(iconCode))),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${temp.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      weatherMain,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      weatherDesc,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onPrimary.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.onPrimaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weatherInfoItem(
                  Icons.water_drop,
                  '$humidity%',
                  'Humidity',
                  colorScheme,
                ),
                _weatherInfoItem(
                  Icons.air,
                  '${windSpeed} m/s',
                  'Wind',
                  colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherInfoItem(
    IconData icon,
    String value,
    String label,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Icon(icon, color: colorScheme.onPrimary, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onPrimary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecastData!.length > 8 ? 8 : forecastData!.length,
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final forecast = forecastData![index];
              final dateTime = DateTime.fromMillisecondsSinceEpoch(
                forecast['dt'] * 1000,
              );
              final temp = forecast['main']['temp'];
              final iconCode = forecast['weather'][0]['icon'];

              return Container(
                width: 100,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(dateTime),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: FittedBox(child: Text(_getWeatherEmoji(iconCode))),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${temp.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast(ColorScheme colorScheme) {
    // Group forecast by day
    Map<String, List<dynamic>> dailyForecasts = {};

    for (var forecast in forecastData!) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
        forecast['dt'] * 1000,
      );
      final day = DateFormat('yyyy-MM-dd').format(dateTime);

      if (!dailyForecasts.containsKey(day)) {
        dailyForecasts[day] = [];
      }

      dailyForecasts[day]!.add(forecast);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '5-Day Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: dailyForecasts.length > 5 ? 5 : dailyForecasts.length,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final day = dailyForecasts.keys.elementAt(index);
            final forecasts = dailyForecasts[day]!;

            // Calculate average temperature and get the most common weather condition
            double sumTemp = 0;
            Map<String, int> weatherFrequency = {};

            for (var forecast in forecasts) {
              sumTemp += forecast['main']['temp'];
              final weather = forecast['weather'][0]['main'];
              weatherFrequency[weather] = (weatherFrequency[weather] ?? 0) + 1;
            }

            double avgTemp = sumTemp / forecasts.length;
            String mainWeather =
                weatherFrequency.entries
                    .reduce((a, b) => a.value > b.value ? a : b)
                    .key;

            final iconCode = forecasts.first['weather'][0]['icon'];
            final dateTime = DateTime.fromMillisecondsSinceEpoch(
              forecasts.first['dt'] * 1000,
            );

            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      DateFormat('EEEE').format(dateTime),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: Text(_getWeatherEmoji(iconCode)),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            mainWeather,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${avgTemp.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFarmingAdvice(ColorScheme colorScheme) {
    final weather = weatherData!;
    final temp = weather['main']['temp'];
    final weatherMain = weather['weather'][0]['main'];
    _getFarmingAdvice(weatherMain, temp);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.tertiary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: colorScheme.tertiary, size: 24),
              SizedBox(width: 8),
              Text(
                'Farming Advice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            farmingAdvice,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.tertiary.withOpacity(0.7),
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recommendations based on current weather conditions',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWeatherEmoji(String iconCode) {
    switch (iconCode) {
      case '01d':
        return '☀️'; // clear sky day
      case '01n':
        return '🌙'; // clear sky night
      case '02d':
        return '⛅'; // few clouds day
      case '02n':
        return '☁️🌙'; // few clouds night
      case '03d':
      case '03n':
        return '☁️'; // scattered clouds
      case '04d':
      case '04n':
        return '☁️☁️'; // broken clouds
      case '09d':
      case '09n':
        return '🌧️'; // shower rain
      case '10d':
        return '🌦️'; // rain day
      case '10n':
        return '🌧️🌙'; // rain night
      case '11d':
      case '11n':
        return '⛈️'; // thunderstorm
      case '13d':
      case '13n':
        return '❄️'; // snow
      case '50d':
      case '50n':
        return '🌫️'; // mist
      default:
        return '🌈'; // default to rainbow for unknown conditions
    }
  }
}
