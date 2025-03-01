import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'consts.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  List<Weather> _forecast = [];
  Weather? _currentWeather;
  int _currentDateOffset = 0;

  final List<String> _municipalities = [
    "Tagbilaran City", "Pilar", "Dimiao", "Guindulman", "Alburquerque", "Alicia", "Antequera", "Baclayon", "Balilihan", "Batuan",
    "Bien Unido", "Bilar", "Buenavista", "Calape", "Candijay", "Carmen", "Catigbian", "Clarin", "Corella", "Cortes",
    "Dagohoy", "Duero", "Danao", "Garcia Hernandez", "Getafe", "Inabanga", "Jagna", "Lila", "Loay", "Loboc", "Loon",
    "Mabini", "Maribojoc", "Dauis", "Anda", "Sagbayan", "San Isidro", "San Miguel", "Sevilla", "Sierra Bullones", "Sikatuna",
    "Talibon", "Trinidad", "Tubigon", "Ubay", "Valencia", "Bien Unido"
  ];

  int _currentMunicipalityIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchWeatherForecast(_municipalities[_currentMunicipalityIndex]);
  }

  Future<void> _fetchWeatherForecast(String cityName) async {
    try {
      List<Weather> forecast = await _wf.fiveDayForecastByCityName(cityName);
      Weather currentWeather = forecast[0];

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

  void _onMunicipalitySelected(String municipality) {
    setState(() {
      _currentMunicipalityIndex = _municipalities.indexOf(municipality);
    });
    _fetchWeatherForecast(municipality);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Search City", // Changed from "Weather Forecast" to "Search City"
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MunicipalitySearchDelegate(
                  municipalities: _municipalities,
                  onMunicipalitySelected: _onMunicipalitySelected,
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            // Provide a fallback for when _currentWeather or weatherDescription is null
            image: AssetImage(_getBackgroundImage(_currentWeather?.weatherDescription ?? "default")),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    if (_currentWeather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    Weather weather = _getWeatherForSelectedDate();
    String backgroundImage = _getBackgroundImage(weather.weatherDescription ?? "default");

    return Stack(
      children: [
        // Background Image
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add a SizedBox to create space between the AppBar and the city name
            SizedBox(height: MediaQuery.of(context).size.height * 0.10),

            // City Name Header (placed moderately down)
            _locationHeader(),

            // Additional Spacing after city name
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),

            // Date and Time Information
            _dateTimeInfo(),

            // Weather icon, temperature, and additional information
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            _weatherIcon(weather),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _currentTemp(weather),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _extraInfo(weather),

            // Navigation buttons to navigate through days
            SizedBox(height: 80),
            _dateNavigationButtons(),
          ],
        ),
      ],
    );
  }

  Weather _getWeatherForSelectedDate() {
    int index = (_currentDateOffset + _forecast.length) % _forecast.length;
    return _forecast[index];
  }

  Widget _locationHeader() {
    return Text(
      _municipalities[_currentMunicipalityIndex],
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = DateTime.now().add(Duration(days: _currentDateOffset));
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(fontSize: 35),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              "  ${DateFormat("d/MM/y").format(now)}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon(Weather weather) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("http://openweathermap.org/img/wn/${weather.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          weather.weatherDescription ?? "",
          style: const TextStyle(color: Colors.black, fontSize: 20),
        ),
      ],
    );
  }

  Widget _currentTemp(Weather weather) {
    return Text(
      "${weather.temperature?.celsius?.toStringAsFixed(0)}°C",
      style: const TextStyle(color: Colors.black, fontSize: 90, fontWeight: FontWeight.w500),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Wind: ${weather.windSpeed?.toStringAsFixed(0)}m/s", style: const TextStyle(color: Colors.white, fontSize: 15)),
              Text("Humidity: ${weather.humidity?.toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Max: ${weather.tempMax?.celsius?.toStringAsFixed(0)}°C", style: const TextStyle(color: Colors.white, fontSize: 15)),
              Text("Min: ${weather.tempMin?.celsius?.toStringAsFixed(0)}°C", style: const TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

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

  void _changeDay(int offset) {
    setState(() {
      _currentDateOffset += offset;
    });
  }

  // This function returns the correct background image based on weather description
  String _getBackgroundImage(String weatherDescription) {
    switch (weatherDescription.toLowerCase()) {
      case 'light rain':
        return 'lib/assets/4.webp'; // Use your local path to the image
      case 'overcast clouds':
        return 'lib/assets/5.webp'; // Use your local path to the image
      case 'clear sky':
        return 'lib/assets/6.webp'; // Use your local path to the image
      case 'few clouds':
        return 'lib/assets/8.webp';
      case 'scattered clouds':
        return 'lib/assets/9.webp';
      case 'broken clouds':
        return 'lib/assets/10.webp';
      default:
        return 'lib/assets/7.webp'; // Default weather background
    }
  }
}

class MunicipalitySearchDelegate extends SearchDelegate<String> {
  final List<String> municipalities;
  final Function(String) onMunicipalitySelected;

  MunicipalitySearchDelegate({
    required this.municipalities,
    required this.onMunicipalitySelected,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = municipalities
        .where((municipality) => municipality.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            onMunicipalitySelected(suggestions[index]);
            close(context, suggestions[index]);
          },
        );
      },
    );
  }
}
