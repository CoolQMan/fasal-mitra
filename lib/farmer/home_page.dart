import 'package:flutter/material.dart';
import 'package:gdg_solution/farmer/farmer_awareness.dart';
import 'package:gdg_solution/farmer/listing_page.dart';
import 'package:gdg_solution/farmer/mainNav.dart';
import 'package:gdg_solution/farmer/profile.dart';
import 'package:gdg_solution/farmer/weather.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String UniqueId;

  HomePage({required this.username, required this.UniqueId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String? _selected_Lang = "English";
  final List<String> Lang_Support = ["English", "Hindi"];

  late AnimationController _my_LottieAnimationController;
  late String username_IN;
  late String role_IN;

  // Add variables for the AI assistant
  final TextEditingController _questionController = TextEditingController();
  String _farmingAdvice =
      "Ask me anything about farming, crops, weather, or agricultural practices!";
  bool _isLoading = false;

  @override
  void initState() {
    username_IN = widget.username;
    role_IN = widget.UniqueId;
    super.initState();
    _my_LottieAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  final List<String> lottie_icon = [
    'lib/assets/animation_json/Listing.json',
    'lib/assets/animation_json/shovel.json',
    'lib/assets/animation_json/human_leaf.json',
    'lib/assets/animation_json/weather.json',
  ];

  final List<String> tileName = [
    'Listings',
    'Seeds and Tools',
    'Farmer Awareness',
    'Weather',
  ];

  final List<String> pages = [
    '/listing_page',
    '/Seeds_and_tools',
    '/farmer_awareness_page',
    '/weather_page',
  ];

  late List<Widget> _pages = [
    ListingPage(username: username_IN, UniqueId: role_IN),
    FarmerAwareness(),
    Weather(),
  ];

  // Function to get farming advice from Gemini
  Future<void> getFarmingAdvice() async {
    if (_questionController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize the Gemini model
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'YOUR_API_KEY', // Replace with your actual API key
      );

      // Create a prompt that includes the user's question
      final prompt =
          'As a friendly farming expert, please provide specific and practical advice on the following farming question. Keep your answer concise (2-3 sentences if possible): ${_questionController.text}';

      // Generate content using Gemini
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _farmingAdvice =
            response.text ??
            "I couldn't generate advice at the moment. Please try again.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _farmingAdvice =
            "Sorry, I couldn't process your request. Please check your connection and try again.";
        _isLoading = false;
      });
      print('Error generating farming advice: $e');
    }
  }

  void voice_assistant() {
    print("clicked");
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Get screen size to make layout responsive
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Container(
          margin: EdgeInsets.only(top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Use Expanded to prevent overflow in username
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome!",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.username,
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              DropdownButton<String>(
                value: _selected_Lang,
                borderRadius: BorderRadius.circular(15),
                underline: Container(),
                icon: Icon(Icons.keyboard_arrow_down_rounded),
                items:
                    Lang_Support.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selected_Lang = newValue!;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Icon(Icons.person, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FarmerProfile()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              flex: 3, // Allocate less space for the grid
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0, // Make cells square
                  crossAxisSpacing: 10, // Add spacing between columns
                  mainAxisSpacing: 10, // Add spacing between rows
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      NavigationHelper.navigateToTab(index + 1, context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade50,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: colors.onSurface.withAlpha(30),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Use Expanded for Lottie to take available space
                          Expanded(
                            flex: 3, // 75% of space for animation
                            child: Lottie.asset(
                              lottie_icon[index],
                              fit: BoxFit.contain, // Ensure animation fits
                            ),
                          ),
                          SizedBox(height: 4),
                          // Use Expanded for text to take remaining space
                          Expanded(
                            flex: 1, // 25% of space for text
                            child: Center(
                              child: Text(
                                tileName[index],
                                style: TextStyle(
                                  fontSize: 16, // Slightly smaller font
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                maxLines:
                                    2, // Allow up to 2 lines for longer text
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: 4,
              ),
            ),

            // Add Gemini AI Farming Assistant Section
            Expanded(
              flex: 2, // Allocate space for the AI assistant
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 10, 16, 10),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: colors.onSurface.withAlpha(20),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.agriculture, color: Colors.green.shade700),
                        SizedBox(width: 8),
                        Text(
                          "AI Farming Assistant",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child:
                          _isLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.green.shade700,
                                ),
                              )
                              : SingleChildScrollView(
                                child: Text(
                                  _farmingAdvice,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              textSelectionTheme: TextSelectionThemeData(
                                cursorColor: Colors.green.shade700,
                                selectionColor: Colors.green.shade200,
                                selectionHandleColor: Colors.green.shade700,
                              ),
                            ),
                            child: TextField(
                              controller: _questionController,
                              decoration: InputDecoration(
                                hintText: "Ask about farming...",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: getFarmingAdvice,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
