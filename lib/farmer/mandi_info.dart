// Paste 1
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MandiInfoPage extends StatefulWidget {
  const MandiInfoPage({Key? key}) : super(key: key);

  @override
  State<MandiInfoPage> createState() => _MandiInfoPageState();
}

class _MandiInfoPageState extends State<MandiInfoPage> {
  bool _isLoading = false;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedMandi;
  List<String> _states = [];
  List<String> _districts = [];
  List<String> _mandis = [];
  Map<String, dynamic>? _mandiInfo;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _trendingCrops = [];

  @override
  void initState() {
    super.initState();
    _fetchStates();
    _loadTrendingCrops();
  }

  void _loadTrendingCrops() {
    setState(() {
      _trendingCrops = [
        {
          'name': 'Wheat',
          'price': 2275.0,
          'trend': 'stable',
          'description': 'Trading around MSP of ₹2275/quintal',
        },
        {
          'name': 'Chana (Gram)',
          'price': 5820.0,
          'trend': 'up',
          'description': '7% above MSP of ₹5440/quintal due to lower output',
        },
        {
          'name': 'Mustard',
          'price': 5050.0,
          'trend': 'down',
          'description': '11% below MSP of ₹5650/quintal due to bumper harvest',
        },
        {
          'name': 'Soybean',
          'price': 5000.0,
          'trend': 'up',
          'description': '9% above MSP due to strong demand',
        },
        {
          'name': 'Potato',
          'price': 1075.0,
          'trend': 'fluctuating',
          'description':
              'Prices vary from ₹200 to ₹1400 per quintal based on quality',
        },
      ];
    });
  }

  Future<void> _fetchStates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://directory.apisetu.gov.in/api/mandi/states'),
        headers: {
          'Authorization': 'Bearer 5fe9e884-14e1-3294-943b-b6daab40b04e',
          'Content-Type': 'application/json',
          'deptId': '324',
          'srvId': '1408',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _states = List<String>.from(
            data['states'].map((state) => state['stateName']),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _states = [
            'Delhi',
            'West Bengal',
            'Maharashtra',
            'Uttar Pradesh',
            'Tamil Nadu',
            'Karnataka',
            'Gujarat',
            'Punjab',
          ];
          _selectedState = 'Delhi';
          _errorMessage =
              'Using default state list due to API error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _states = [
          'Delhi',
          'West Bengal',
          'Maharashtra',
          'Uttar Pradesh',
          'Tamil Nadu',
          'Karnataka',
          'Gujarat',
          'Punjab',
        ];
        _selectedState = 'Delhi';
        _errorMessage = 'Using default state list: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDistricts(String stateName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _districts = [];
      _selectedDistrict = null;
      _mandis = [];
      _selectedMandi = null;
      _mandiInfo = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://directory.apisetu.gov.in/api/mandi/districts'),
        headers: {
          'Authorization': 'Bearer 5fe9e884-14e1-3294-943b-b6daab40b04e',
          'Content-Type': 'application/json',
          'deptId': '324',
          'srvId': '1408',
        },
        body: json.encode({'stateName': stateName}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _districts = List<String>.from(
            data['districts'].map((district) => district['districtName']),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          if (stateName == 'Delhi') {
            _districts = [
              'Central Delhi',
              'East Delhi',
              'New Delhi',
              'North Delhi',
              'South Delhi',
            ];
            _selectedDistrict = 'Central Delhi';
          } else if (stateName == 'West Bengal') {
            _districts = ['Murshidabad', 'Kolkata', 'Howrah', 'Darjeeling'];
            _selectedDistrict = 'Murshidabad';
          } else {
            _districts = ['District 1', 'District 2', 'District 3'];
            _selectedDistrict = 'District 1';
          }
          _errorMessage =
              'Using default district list due to API error: ${response.statusCode}';
          _isLoading = false;
        });
        _fetchMandis(stateName, _selectedDistrict!);
      }
    } catch (e) {
      setState(() {
        if (stateName == 'Delhi') {
          _districts = [
            'Central Delhi',
            'East Delhi',
            'New Delhi',
            'North Delhi',
            'South Delhi',
          ];
          _selectedDistrict = 'Central Delhi';
        } else if (stateName == 'West Bengal') {
          _districts = ['Murshidabad', 'Kolkata', 'Howrah', 'Darjeeling'];
          _selectedDistrict = 'Murshidabad';
        } else {
          _districts = ['District 1', 'District 2', 'District 3'];
          _selectedDistrict = 'District 1';
        }
        _errorMessage = 'Using default district list: $e';
        _isLoading = false;
      });
      _fetchMandis(stateName, _selectedDistrict!);
    }
  }

  Future<void> _fetchMandis(String stateName, String districtName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mandis = [];
      _selectedMandi = null;
      _mandiInfo = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://directory.apisetu.gov.in/api/mandi/mandis'),
        headers: {
          'Authorization': 'Bearer 5fe9e884-14e1-3294-943b-b6daab40b04e',
          'Content-Type': 'application/json',
          'deptId': '324',
          'srvId': '1408',
        },
        body: json.encode({
          'stateName': stateName,
          'districtName': districtName,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _mandis = List<String>.from(
            data['mandis'].map((mandi) => mandi['mandiName']),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          if (stateName == 'West Bengal' && districtName == 'Murshidabad') {
            _mandis = [
              'Jiyaganj Krishak Bazar',
              'Murshidabad Mandi',
              'Berhampore Mandi',
            ];
            _selectedMandi = 'Jiyaganj Krishak Bazar';
          } else {
            _mandis = ['Local Mandi 1', 'Local Mandi 2', 'Local Mandi 3'];
            _selectedMandi = 'Local Mandi 1';
          }
          _errorMessage =
              'Using default mandi list due to API error: ${response.statusCode}';
          _isLoading = false;
        });
        _generateMockMandiInfo(stateName, districtName, _selectedMandi!);
      }
    } catch (e) {
      setState(() {
        if (stateName == 'West Bengal' && districtName == 'Murshidabad') {
          _mandis = [
            'Jiyaganj Krishak Bazar',
            'Murshidabad Mandi',
            'Berhampore Mandi',
          ];
          _selectedMandi = 'Jiyaganj Krishak Bazar';
        } else {
          _mandis = ['Local Mandi 1', 'Local Mandi 2', 'Local Mandi 3'];
          _selectedMandi = 'Local Mandi 1';
        }
        _errorMessage = 'Using default mandi list: $e';
        _isLoading = false;
      });
      _generateMockMandiInfo(stateName, districtName, _selectedMandi!);
    }
  }

  Future<void> _fetchMandiInfo(
    String stateName,
    String districtName,
    String mandiName,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mandiInfo = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://directory.apisetu.gov.in/umang/apisetu/dept/enamapi/ws1/getMandiInfoForMI',
        ),
        headers: {
          'Authorization': 'Bearer 5fe9e884-14e1-3294-943b-b6daab40b04e',
          'Content-Type': 'application/json',
          'deptId': '324',
          'srvId': '1408',
          'subsid': '0',
          'subsid2': '0',
          'formtrkr': '0',
          'x-api-key': 'qkNR1lrrxxxxnDf2tHMU9wh',
        },
        body: json.encode({
          'tkn': 'cocaa6d9b4-6825-4bb2-bee8-2b7817c0de89/2',
          'trkr': '213132',
          'usrid': '09',
          'srvid': '1408',
          'mode': 'web',
          'pltfrm': 'apisetu',
          'did': null,
          'deptid': '324',
          'subsid': '0',
          'subsid2': '0',
          'formtrkr': '0',
          'getMandiInfoForMI': {
            'language': 'en',
            'stateName': stateName,
            'districtName': districtName,
            'mandiName': mandiName,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _mandiInfo = data;
          _isLoading = false;
        });
      } else {
        _generateMockMandiInfo(stateName, districtName, mandiName);
        setState(() {
          _errorMessage =
              'Using mock mandi data due to API error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      _generateMockMandiInfo(stateName, districtName, mandiName);
      setState(() {
        _errorMessage = 'Using mock mandi data: $e';
        _isLoading = false;
      });
    }
  }

  void _generateMockMandiInfo(
    String stateName,
    String districtName,
    String mandiName,
  ) {
    setState(() {
      _mandiInfo = {
        'address': '$mandiName, $districtName, $stateName - 741318',
        'contact': '+91 9876543210',
        'lastUpdated': DateFormat('dd MMM yyyy').format(DateTime.now()),
        'commodities': [
          {
            'name': 'Rice',
            'minPrice': '2100',
            'maxPrice': '2300',
            'modalPrice': '2200',
          },
          {
            'name': 'Wheat',
            'minPrice': '1950',
            'maxPrice': '2100',
            'modalPrice': '2050',
          },
          {
            'name': 'Potato',
            'minPrice': '950',
            'maxPrice': '1200',
            'modalPrice': '1075',
          },
          {
            'name': 'Onion',
            'minPrice': '1800',
            'maxPrice': '2200',
            'modalPrice': '2000',
          },
        ],
      };
    });
  }

  void _searchCrop() {
    if (_searchController.text.isNotEmpty && _mandiInfo != null) {
      final searchText = _searchController.text.toLowerCase();
      final commodities = _mandiInfo!['commodities'] as List;

      final filteredCommodities =
          commodities
              .where(
                (commodity) => commodity['name']
                    .toString()
                    .toLowerCase()
                    .contains(searchText),
              )
              .toList();

      if (filteredCommodities.isNotEmpty) {
        setState(() {
          _mandiInfo = {..._mandiInfo!, 'commodities': filteredCommodities};
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No crops found matching: ${_searchController.text}'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a mandi first or enter a search term'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mandi Information'),
        backgroundColor: colors.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for crops...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _searchCrop(),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.search), onPressed: _searchCrop),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Trending crops section
            Text(
              'Trending Crops',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            Container(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _trendingCrops.length,
                itemBuilder: (context, index) {
                  final crop = _trendingCrops[index];
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              crop['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              crop['trend'] == 'up'
                                  ? Icons.trending_up
                                  : crop['trend'] == 'down'
                                  ? Icons.trending_down
                                  : Icons.trending_flat,
                              color:
                                  crop['trend'] == 'up'
                                      ? Colors.green
                                      : crop['trend'] == 'down'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₹${crop['price'].toStringAsFixed(2)}/quintal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            crop['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // Market trends section
            Text(
              'Market Trends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Market Insights',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            Text(
              'Select State',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: colors.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Select a state'),
                  value: _selectedState,
                  items:
                      _states.map((String state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedState = newValue;
                      });
                      _fetchDistricts(newValue);
                    }
                  },
                ),
              ),
            ),

            SizedBox(height: 16),

            // District dropdown (only show if state is selected)
            if (_selectedState != null) ...[
              Text(
                'Select District',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Select a district'),
                    value: _selectedDistrict,
                    items:
                        _districts.map((String district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && _selectedState != null) {
                        setState(() {
                          _selectedDistrict = newValue;
                        });
                        _fetchMandis(_selectedState!, newValue);
                      }
                    },
                  ),
                ),
              ),
            ],

            SizedBox(height: 16),

            // Mandi dropdown (only show if district is selected)
            if (_selectedDistrict != null) ...[
              Text(
                'Select Mandi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Select a mandi'),
                    value: _selectedMandi,
                    items:
                        _mandis.map((String mandi) {
                          return DropdownMenuItem<String>(
                            value: mandi,
                            child: Text(mandi),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null &&
                          _selectedState != null &&
                          _selectedDistrict != null) {
                        setState(() {
                          _selectedMandi = newValue;
                        });
                        _fetchMandiInfo(
                          _selectedState!,
                          _selectedDistrict!,
                          newValue,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],

            SizedBox(height: 24),

            // Loading indicator
            if (_isLoading) Center(child: CircularProgressIndicator()),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ],
                ),
              ),

            // Mandi information
            if (_mandiInfo != null) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outline.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mandi Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    Divider(height: 24),
                    _buildInfoRow('Mandi Name', _selectedMandi ?? 'N/A'),
                    _buildInfoRow('Address', _mandiInfo?['address'] ?? 'N/A'),
                    _buildInfoRow('Contact', _mandiInfo?['contact'] ?? 'N/A'),

                    SizedBox(height: 16),
                    Text(
                      'Commodity Prices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Commodity prices table
                    if (_mandiInfo?['commodities'] != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colors.outline.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DataTable(
                          columnSpacing: 16,
                          headingRowColor: MaterialStateProperty.all(
                            colors.primaryContainer.withOpacity(0.5),
                          ),
                          columns: [
                            DataColumn(label: Text('Commodity')),
                            DataColumn(label: Text('Min Price')),
                            DataColumn(label: Text('Max Price')),
                            DataColumn(label: Text('Modal Price')),
                          ],
                          rows: List<DataRow>.from(
                            (_mandiInfo?['commodities'] as List).map(
                              (commodity) => DataRow(
                                cells: [
                                  DataCell(Text(commodity['name'] ?? 'N/A')),
                                  DataCell(
                                    Text('₹${commodity['minPrice'] ?? 'N/A'}'),
                                  ),
                                  DataCell(
                                    Text('₹${commodity['maxPrice'] ?? 'N/A'}'),
                                  ),
                                  DataCell(
                                    Text(
                                      '₹${commodity['modalPrice'] ?? 'N/A'}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else
                      Text('No commodity prices available'),

                    SizedBox(height: 16),

                    // Last updated info
                    Text(
                      'Last Updated: ${_mandiInfo?['lastUpdated'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Use this price button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _mandiInfo != null
                          ? () {
                            // Find the price for the searched crop
                            final commodities =
                                _mandiInfo?['commodities'] as List?;
                            final searchText =
                                _searchController.text.toLowerCase();
                            final targetCommodity = commodities?.firstWhere(
                              (commodity) => commodity['name']
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchText),
                              orElse: () => {'modalPrice': '0'},
                            );

                            final price = targetCommodity?['modalPrice'] ?? '0';

                            // Return the selected price to the previous screen
                            Navigator.pop(
                              context,
                              double.tryParse(price.toString()) ?? 0.0,
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Use Market Price',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}
