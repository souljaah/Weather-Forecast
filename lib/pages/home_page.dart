import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'consts.dart';  // Make sure you have your OPENWEATHER_API_KEY here

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  List<Weather> _forecast = []; // Holds forecast data
  Weather? _currentWeather;
  int _currentDateOffset = 0; // 0 = today, -1 = yesterday, +1 = tomorrow

  // List of municipalities in Bohol
  final List<String> _municipalities = [
    "\n\n\nTagbilaran City", "\n\n\nPilar", "\n\n\nDimiao", "\n\n\nGuindulman", "\n\n\nAlburquerque", "\n\n\nAlicia", "\n\n\nAntequera", "\n\n\nBaclayon", "\n\n\nBalilihan", "\n\n\nBatuan",
    "\n\n\nBien Unido", "\n\n\nBilar", "\n\n\nBuenavista", "\n\n\nCalape", "\n\n\nCandijay", "\n\n\nCarmen", "\n\n\nCatigbian",
    "\n\n\nClarin", "\n\n\nCorella", "\n\n\nCortes", "\n\n\nDagohoy", "\n\n\nDuero", "\n\n\nDanao",
    "\n\n\nGarcia Hernandez", "\n\n\nGetafe", "\n\n\nInabanga", "\n\n\nJagna", "\n\n\nLila", "\n\n\nLoay",
    "\n\n\nLoboc", "\n\n\nLoon", "\n\n\nMabini", "\n\n\nMaribojoc", "\n\n\nDauis", "\n\n\nAnda",
    "\n\n\nSagbayan", "\n\n\nSan Isidro", "\n\n\nSan Miguel", "\n\n\nSevilla", "\n\n\nSierra Bullones", "\n\n\nSikatuna",
    "\n\n\nTalibon", "\n\n\nTrinidad", "\n\n\nTubigon", "\n\n\nUbay", "\n\n\nValencia", "\n\n\nBien Unido"
  ];

  int _currentMunicipalityIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchWeatherForecast(); // Fetch weather forecast for the first municipality (default)
  }

  // Fetch weather forecast for the current municipality
  Future<void> _fetchWeatherForecast() async {
    try {
      // Get 7-day forecast
      List<Weather> forecast = await _wf.fiveDayForecastByCityName(_municipalities[_currentMunicipalityIndex]);
      Weather currentWeather = forecast[0]; // Assume first entry is current day

      setState(() {
        _forecast = forecast;
        _currentWeather = currentWeather;
      });
    } catch (error) {
      print("Failed to fetch weather data: $error");
      setState(() {
        _forecast = [];
        _currentWeather = null;
      });
    }
  }

  // Navigate to the next municipality
  void _nextMunicipality() {
    setState(() {
      _currentMunicipalityIndex = (_currentMunicipalityIndex + 1) % _municipalities.length;
    });
    _fetchWeatherForecast();
  }

  // Navigate to the previous municipality
  void _previousMunicipality() {
    setState(() {
      _currentMunicipalityIndex = (_currentMunicipalityIndex - 1 + _municipalities.length) % _municipalities.length;
    });
    _fetchWeatherForecast();
  }

  // Navigate to the next day or previous day
  void _changeDay(int offset) {
    setState(() {
      _currentDateOffset += offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_currentWeather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Get current weather or forecasted weather based on the selected date
    Weather weather = _getWeatherForSelectedDate();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
          ),
          _dateTimeInfo(), // Shows current date and time
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          _weatherIcon(weather),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _currentTemp(weather),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          _extraInfo(weather),
          SizedBox(height: 20),
          _navigationButtons(), // Add the Next/Back buttons for municipalities
          SizedBox(height: 10),
          _dateNavigationButtons(), // Add the Previous Day/Next Day buttons
        ],
      ),
    );
  }

  Weather _getWeatherForSelectedDate() {
    int index = (_currentDateOffset + _forecast.length) % _forecast.length; // Adjust date offset
    return _forecast[index];
  }

  Widget _locationHeader() {
    return Text(
      _municipalities[_currentMunicipalityIndex], // Display current municipality
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = DateTime.now().add(Duration(days: _currentDateOffset)); // Adjust for past/future dates
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now), // Show time in hours and minutes
          style: const TextStyle(
            fontSize: 35,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now), // Show the day of the week
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "  ${DateFormat("d/MM/y").format(now)}", // Show the date
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon(Weather weather) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${weather.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          weather.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        )
      ],
    );
  }

  Widget _currentTemp(Weather weather) {
    return Text(
      "${weather.temperature?.celsius?.toStringAsFixed(0)}°C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 90,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _extraInfo(Weather weather) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 0.80,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${weather.windSpeed?.toStringAsFixed(0)}m/s",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                "Humidity: ${weather.humidity?.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Max: ${weather.tempMax?.celsius?.toStringAsFixed(0)}°C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                "Min: ${weather.tempMin?.celsius?.toStringAsFixed(0)}°C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation buttons for Next and Back (municipalities)
  Widget _navigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _previousMunicipality,
          child: const Text("Back"),
        ),
        ElevatedButton(
          onPressed: _nextMunicipality,
          child: const Text("Next"),
        ),
      ],
    );
  }

  // Navigation buttons for changing the date (yesterday, today, tomorrow, etc.)
  Widget _dateNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _changeDay(-1),
          child: const Text("Previous Day"),
        ),
        ElevatedButton(
          onPressed: () => _changeDay(1),
          child: const Text("Next Day"),
        ),
      ],
    );
  }
}
