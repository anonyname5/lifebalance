import 'package:flutter/material.dart';
import 'water_tracking_screen.dart';
import 'meal_logging_screen.dart';

/// Wellness screen with tabs for water and meals
class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.water_drop),
              text: 'Water',
            ),
            Tab(
              icon: Icon(Icons.restaurant),
              text: 'Meals',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          WaterTrackingScreen(),
          MealLoggingScreen(),
        ],
      ),
    );
  }
}
