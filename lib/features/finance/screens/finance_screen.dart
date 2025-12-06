import 'package:flutter/material.dart';
import 'expense_screen.dart';
import 'budget_screen.dart';
import 'savings_goals_screen.dart';
import 'recurring_expenses_screen.dart';

/// Finance screen with tabs for expenses, budget, savings, and recurring
class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Finance'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.receipt),
              text: 'Expenses',
            ),
            Tab(
              icon: Icon(Icons.account_balance_wallet),
              text: 'Budget',
            ),
            Tab(
              icon: Icon(Icons.savings),
              text: 'Savings',
            ),
            Tab(
              icon: Icon(Icons.repeat),
              text: 'Recurring',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExpenseScreen(),
          BudgetScreen(),
          SavingsGoalsScreen(),
          RecurringExpensesScreen(),
        ],
      ),
    );
  }
}
