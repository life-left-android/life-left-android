import 'package:flutter/material.dart';

void main() {
  runApp(const LifeLeftApp());
}

class LifeLeftApp extends StatelessWidget {
  const LifeLeftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Left',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _daysLeft = 0;
  double _progress = 0.0;
  List<DateTime> _yearDays = [];
  bool _showDays = true; // Toggle between days and percentage
  String _displayText = '2025'; // Bottom left display text

  @override
  void initState() {
    super.initState();
    _calculateDaysLeft();
  }

  void _calculateDaysLeft() {
    final now = DateTime.now();
    final currentYear = now.year;
    final endOfYear = DateTime(currentYear, 12, 31, 23, 59, 59);
    final startOfYear = DateTime(currentYear, 1, 1);
    
    final daysLeft = endOfYear.difference(now).inDays + 1;
    final totalDays = endOfYear.difference(startOfYear).inDays + 1;
    
    // Generate all days of the year
    final yearDays = <DateTime>[];
    for (int i = 0; i < totalDays; i++) {
      yearDays.add(startOfYear.add(Duration(days: i)));
    }
    
    setState(() {
      _daysLeft = daysLeft;
      _progress = daysLeft / totalDays;
      _yearDays = yearDays;
    });
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
  
  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  Widget _buildHeatmap(ThemeData theme) {
    final now = DateTime.now();
    const double iconSize = 16.5;
    const double spacing = 6.0;
    
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(_yearDays.length, (index) {
        final day = _yearDays[index];
        final isToday = day.year == now.year && 
                       day.month == now.month && 
                       day.day == now.day;
        final isPassed = day.isBefore(now);
        
        Color heartColor;
        if (isToday) {
          heartColor = Colors.red;
        } else if (isPassed) {
          // Grey for completed days
          heartColor = Colors.grey.withOpacity(0.4);
        } else {
          // White for remaining days
          heartColor = Colors.white;
        }
        
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            setState(() {
              _displayText = '${_getDayName(day.weekday)}, ${_getMonthName(day.month)} ${day.day}';
            });
          },
          onExit: (_) {
            setState(() {
              _displayText = '2025';
            });
          },
          child: GestureDetector(
            onTap: () {
              setState(() {
                _displayText = '${_getDayName(day.weekday)}, ${_getMonthName(day.month)} ${day.day}';
              });
              // Reset to year after 2 seconds
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _displayText = '2025';
                  });
                }
              });
            },
            child: Icon(
              Icons.favorite,
              size: iconSize,
              color: heartColor,
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.favorite,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Full screen heatmap
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Legend at top
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildLegendItem(theme, 'Completed', Colors.grey.withOpacity(0.4)),
                                _buildLegendItem(theme, 'Today', Colors.red),
                                _buildLegendItem(theme, 'Remaining', Colors.white),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Full screen heatmap
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildHeatmap(theme),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom left date display
          Positioned(
            bottom: 24,
            left: 24,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _displayText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          
          // Bottom right statistics
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showDays = !_showDays;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        _showDays 
                        ? '$_daysLeft Days Left'
                        : '${(_progress * 100).toStringAsFixed(1)}% Left',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
