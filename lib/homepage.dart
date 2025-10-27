// lib/homepage.dart
import 'package:flutter/material.dart';

// Home page for Trip Fuel Cost Estimator
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // controllers for numeric inputs
  final TextEditingController distanceController = TextEditingController(); // km
  final TextEditingController efficiencyController = TextEditingController(); // km per L
  final TextEditingController priceController = TextEditingController(); // RM per L

  // dropdown for fuel type
  final List<String> _fuelTypes = ['RON95', 'RON97', 'Diesel'];
  String _selectedFuel = 'RON95';

  // fixed prices for fuel types (you can update these to the official rates)
  final Map<String, double> _fuelPrices = {
    'RON95': 2.60,
    'RON97': 3.14,
    'Diesel': 2.89,
  };

  String resultText = '';   // result display
  String? warningText;      // inline warning

  @override
  void initState() {
    super.initState();
    // initialize price field with default for the selected fuel
    priceController.text = _fuelPrices[_selectedFuel]!.toStringAsFixed(2);
  }

  @override
  void dispose() {
    distanceController.dispose();
    efficiencyController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // calculation using setState only
  void calculateCost() {
    setState(() {
      warningText = null;
      resultText = '';

      // parse inputs safely
      final double? distance = double.tryParse(distanceController.text.trim());
      final double? efficiency = double.tryParse(efficiencyController.text.trim());
      final double? price = double.tryParse(priceController.text.trim());

      // validation
      if (distance == null || efficiency == null || price == null) {
        warningText = 'Please enter numeric values for distance, efficiency and price.';
        return;
      }
      if (distance <= 0 || efficiency <= 0 || price < 0) {
        warningText = 'Distance and efficiency must be > 0. Price must be ≥ 0.';
        return;
      }

      // perform calculation
      final double litersNeeded = distance / efficiency; // liters = distance ÷ km per L
      final double totalCost = litersNeeded * price;

      // rounding to two decimals
      final double litersRounded = (litersNeeded * 100).roundToDouble() / 100.0;
      final double costRounded = (totalCost * 100).roundToDouble() / 100.0;

      // result message includes fuel type and currency RM
      resultText =
          'Fuel type: $_selectedFuel\n'
          'Litres needed: $litersRounded L\n'
          'Estimated cost: RM${costRounded.toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Fuel Cost Estimator')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 0), // lecturer-style padding
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Estimate fuel cost for your trip',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              // Row: distance input + fuel type dropdown
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Distance (km)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: distanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'e.g., 120',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.map),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dropdown: fuel type
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fuel Type'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFuel,
                              items: _fuelTypes
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() {
                                  _selectedFuel = val;
                                  // auto-fill the price field with the fixed price
                                  final double price = _fuelPrices[_selectedFuel] ?? 0.0;
                                  priceController.text = price.toStringAsFixed(2);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Row: efficiency and price
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Car fuel efficiency (km/L)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: efficiencyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'e.g., 12',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.local_gas_station),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fuel price (RM/L)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'e.g., 2.05',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.attach_money),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // show warning if any
              if (warningText != null)
                Text(
                  warningText!,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 8),

              // calculate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: calculateCost,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Calculate'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // result area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  resultText.isEmpty ? 'Enter values and press Calculate.' : resultText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
