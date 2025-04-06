import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'mainNav.dart';

class FarmerAwareness extends StatefulWidget {
  @override
  _FarmerAwarenessState createState() => _FarmerAwarenessState();
}

class _FarmerAwarenessState extends State<FarmerAwareness>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get current season based on month
  String _getCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;

    // Adjust these ranges based on your region's seasons
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Autumn';
    return 'Winter';
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentSeason = _getCurrentSeason();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Farmer Knowledge Hub',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.tertiary,
          labelColor: colorScheme.tertiary,
          unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
          tabs: [
            Tab(text: 'Seasonal', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Techniques', icon: Icon(Icons.eco)),
            Tab(text: 'Resources', icon: Icon(Icons.library_books)),
            Tab(text: 'Training', icon: Icon(Icons.school)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSeasonalAdviceTab(context, currentSeason),
          _buildTechniquesTab(context),
          _buildResourcesTab(context),
          _buildTrainingTab(context),
        ],
      ),
    );
  }

  Widget _buildSeasonalAdviceTab(BuildContext context, String season) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final formatter = DateFormat('MMMM yyyy');

    // Content based on current season
    List<Map<String, dynamic>> seasonalTips = _getSeasonalTips(season);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.tertiary,
                  colorScheme.tertiary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$season Season',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onTertiary,
                      ),
                    ),
                    Text(
                      formatter.format(now),
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onTertiary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Recommendations for this season',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onTertiary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Key Activities This Month',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12),
          ...seasonalTips.map((tip) => _buildTipCard(context, tip)).toList(),
          SizedBox(height: 20),
          _buildWeatherAlertCard(context),
          SizedBox(height: 20),
          _buildMarketInsightsCard(context),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSeasonalTips(String season) {
    switch (season) {
      case 'Spring':
        return [
          {
            'title': 'Soil Preparation',
            'description':
                'Test soil pH and nutrient levels. Add organic matter and necessary amendments based on test results.',
            'icon': Icons.landscape,
            'priority': 'High',
          },
          {
            'title': 'Planting Schedule',
            'description':
                'Begin planting early season crops like peas, spinach, and radishes. Start seedlings indoors for summer crops.',
            'icon': Icons.grass,
            'priority': 'High',
          },
          {
            'title': 'Pest Monitoring',
            'description':
                'Set up pest traps and monitoring systems. Watch for early signs of common spring pests like aphids and cutworms.',
            'icon': Icons.bug_report,
            'priority': 'Medium',
          },
          {
            'title': 'Equipment Maintenance',
            'description':
                'Service all farming equipment before the busy season begins. Check irrigation systems for leaks or blockages.',
            'icon': Icons.build,
            'priority': 'Medium',
          },
        ];
      case 'Summer':
        return [
          {
            'title': 'Water Management',
            'description':
                'Implement efficient irrigation practices during hot weather. Water deeply but less frequently to encourage deep root growth.',
            'icon': Icons.water_drop,
            'priority': 'High',
          },
          {
            'title': 'Heat Protection',
            'description':
                'Use shade cloth for sensitive crops. Mulch around plants to retain soil moisture and reduce soil temperature.',
            'icon': Icons.wb_sunny,
            'priority': 'High',
          },
          {
            'title': 'Disease Prevention',
            'description':
                'Monitor for fungal diseases that thrive in humid conditions. Ensure proper air circulation between plants.',
            'icon': Icons.healing,
            'priority': 'Medium',
          },
          {
            'title': 'Harvesting Schedule',
            'description':
                'Harvest crops in the early morning when temperatures are cooler. Process or store harvested crops promptly.',
            'icon': Icons.shopping_basket,
            'priority': 'Medium',
          },
        ];
      case 'Autumn':
        return [
          {
            'title': 'Soil Enrichment',
            'description':
                'Plant cover crops to prevent soil erosion and add nutrients. Consider green manures like clover or winter rye.',
            'icon': Icons.compost,
            'priority': 'High',
          },
          {
            'title': 'Crop Storage',
            'description':
                'Prepare storage facilities for harvested crops. Ensure proper temperature and humidity controls are in place.',
            'icon': Icons.inventory_2,
            'priority': 'High',
          },
          {
            'title': 'Winter Preparation',
            'description':
                'Protect perennial plants with mulch. Clean and store tools and equipment properly for the winter.',
            'icon': Icons.ac_unit,
            'priority': 'Medium',
          },
          {
            'title': 'Market Planning',
            'description':
                "Analyze this year's market performance and begin planning for next season's crops and marketing strategies.",
            'icon': Icons.trending_up,
            'priority': 'Medium',
          },
        ];
      case 'Winter':
        return [
          {
            'title': 'Crop Planning',
            'description':
                'Review last season\'s notes and plan crop rotations. Order seeds and supplies for the upcoming growing season.',
            'icon': Icons.event_note,
            'priority': 'High',
          },
          {
            'title': 'Infrastructure Maintenance',
            'description':
                'Repair buildings, fences, and other infrastructure. Perform maintenance on equipment while workload is lighter.',
            'icon': Icons.home_repair_service,
            'priority': 'Medium',
          },
          {
            'title': 'Soil Health',
            'description':
                'Review soil test results and plan amendments. Research new sustainable practices to implement in spring.',
            'icon': Icons.spa,
            'priority': 'Medium',
          },
          {
            'title': 'Education & Training',
            'description':
                'Attend agricultural workshops and conferences. Update knowledge on new farming techniques and technologies.',
            'icon': Icons.school,
            'priority': 'Medium',
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildTipCard(BuildContext context, Map<String, dynamic> tip) {
    final colorScheme = Theme.of(context).colorScheme;

    Color priorityColor;
    switch (tip['priority']) {
      case 'High':
        priorityColor = Colors.red.shade700;
        break;
      case 'Medium':
        priorityColor = Colors.orange.shade700;
        break;
      default:
        priorityColor = Colors.green.shade700;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(tip['icon'], color: colorScheme.tertiary),
        ),
        title: Text(
          tip['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Priority: ${tip['priority']}',
                style: TextStyle(
                  fontSize: 12,
                  color: priorityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              tip['description'],
              style: TextStyle(
                height: 1.5,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAlertCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.warning_amber, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Weather Alert',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Upcoming weather patterns may affect your farming activities. Check the weather tab for detailed forecasts and prepare accordingly.',
            style: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to weather tab
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MainNavigation(
                        selectedIndex: 4,
                        username: 'farmer', // Replace with actual username
                        UniqueId: 'farmer', // Replace with actual role
                      ),
                ),
              );
            },
            icon: Icon(Icons.cloud),
            label: Text('View Weather Forecast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.tertiary,
              foregroundColor: colorScheme.onTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketInsightsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.trending_up, color: colorScheme.tertiary),
              SizedBox(width: 8),
              Text(
                'Market Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildMarketItem(
            context,
            crop: 'Rice',
            trend: 'up',
            price: '₹2,100/quintal',
            change: '+5.2%',
          ),
          _buildMarketItem(
            context,
            crop: 'Wheat',
            trend: 'down',
            price: '₹1,950/quintal',
            change: '-2.1%',
          ),
          _buildMarketItem(
            context,
            crop: 'Soybeans',
            trend: 'up',
            price: '₹3,800/quintal',
            change: '+3.7%',
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to market prices page or external resource
                _launchUrl('https://agmarknet.gov.in/');
              },
              child: Text(
                'View All Market Prices',
                style: TextStyle(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketItem(
    BuildContext context, {
    required String crop,
    required String trend,
    required String price,
    required String change,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            crop,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      trend == 'up'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      trend == 'up' ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: trend == 'up' ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 12,
                        color: trend == 'up' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechniquesTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTechniqueCard(
          context,
          title: 'Sustainable Farming',
          description:
              'Sustainable farming practices focus on producing crops and livestock while reducing environmental impact and maintaining economic viability.',
          steps: [
            'Implement crop rotation to maintain soil health',
            'Use organic fertilizers and natural pest control',
            'Practice water conservation techniques',
            'Adopt integrated pest management (IPM)',
          ],
          icon: Icons.eco,
        ),
        _buildTechniqueCard(
          context,
          title: 'Precision Agriculture',
          description:
              'Utilize technology to optimize field-level management of crop farming.',
          steps: [
            'Use soil sensors for moisture monitoring',
            'Implement GPS-guided equipment',
            'Analyze satellite imagery for crop health',
            'Apply variable-rate technology for inputs',
          ],
          icon: Icons.precision_manufacturing,
        ),
        _buildTechniqueCard(
          context,
          title: 'Vertical Farming',
          description:
              'Grow crops in vertically stacked layers using controlled environment agriculture.',
          steps: [
            'Optimize space utilization',
            'Use hydroponic or aeroponic systems',
            'Control temperature and lighting',
            'Implement automated nutrient delivery',
          ],
          icon: Icons.vertical_align_center,
        ),
        _buildTechniqueCard(
          context,
          title: 'Organic Farming',
          description:
              'Production system that avoids synthetic inputs and relies on ecological processes.',
          steps: [
            'Use compost and green manure',
            'Practice biological pest control',
            'Maintain biodiversity',
            'Follow certification standards',
          ],
          icon: Icons.spa,
        ),
      ],
    );
  }

  Widget _buildTechniqueCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<String> steps,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.tertiary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Steps:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
                  ),
                ),
                SizedBox(height: 8),
                ...steps
                    .map(
                      (step) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: colorScheme.tertiary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.8),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildResourceCard(
          context,
          title: 'Government Schemes',
          description:
              'Access information about agricultural subsidies and government programs',
          links: [
            {'title': 'PM-KISAN Scheme', 'url': 'https://pmkisan.gov.in/'},
            {
              'title': 'Soil Health Card',
              'url': 'https://soilhealth.dac.gov.in/',
            },
            {
              'title': 'National Mission on Agriculture',
              'url': 'https://nmsa.dac.gov.in/',
            },
          ],
          icon: Icons.agriculture,
        ),
        _buildResourceCard(
          context,
          title: 'Agricultural Guides',
          description: 'Download official farming guidelines and manuals',
          links: [
            {
              'title': 'Crop Cultivation Guide',
              'url': 'https://www.india.gov.in/topics/agriculture/crops',
            },
            {
              'title': 'Pest Management Handbook',
              'url': 'https://ppqs.gov.in/',
            },
            {
              'title': 'Organic Farming Manual',
              'url': 'https://pgsindia-ncof.gov.in/',
            },
          ],
          icon: Icons.library_books,
        ),
        _buildResourceCard(
          context,
          title: 'Market Tools',
          description: 'Tools for better market access and price information',
          links: [
            {
              'title': 'e-NAM Market Platform',
              'url': 'https://www.enam.gov.in/',
            },
            {'title': 'Agri Market Prices', 'url': 'https://agmarknet.gov.in/'},
            {'title': 'Export Opportunities', 'url': 'https://apeda.gov.in/'},
          ],
          icon: Icons.analytics,
        ),
      ],
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<Map<String, String>> links,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.tertiary),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...links
              .map(
                (link) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.link,
                    size: 20,
                    color: colorScheme.tertiary,
                  ),
                  title: Text(
                    link['title']!,
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () => _launchUrl(link['url']!),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTrainingTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTrainingCard(
          context,
          title: 'Krishi Vigyan Kendras',
          description:
              'Hands-on training programs at agricultural science centers',
          contact: 'Visit kvk.icar.gov.in',
          icon: Icons.school,
        ),
        _buildTrainingCard(
          context,
          title: 'Online Courses',
          description: 'Free agricultural courses from ICAR institutes',
          contact: 'Explore elearning.icar.gov.in',
          icon: Icons.computer,
        ),
        _buildTrainingCard(
          context,
          title: 'Workshops & Seminars',
          description: 'Upcoming events on modern farming techniques',
          contact: 'Contact local agriculture office',
          icon: Icons.event,
        ),
        _buildTrainingCard(
          context,
          title: 'Extension Services',
          description: 'Get personalized farming advice from experts',
          contact: 'Dial Kisan Call Center: 1551',
          icon: Icons.phone_in_talk,
        ),
      ],
    );
  }

  Widget _buildTrainingCard(
    BuildContext context, {
    required String title,
    required String description,
    required String contact,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.tertiary),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: colorScheme.onSurface.withOpacity(0.1)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: colorScheme.tertiary),
              SizedBox(width: 8),
              Text(
                contact,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
