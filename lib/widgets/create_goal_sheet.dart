import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../services/goal_service.dart';

class CreateGoalSheet extends StatefulWidget {
  final String userID;
  final Goal? existingGoal;

  const CreateGoalSheet({
    super.key,
    required this.userID,
    this.existingGoal,
  });

  @override
  State<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<CreateGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _goalService = GoalService();

  late TextEditingController _titleController;
  late TextEditingController _targetController;

  GoalMetric _selectedMetric = GoalMetric.calories;
  GoalPeriod _selectedPeriod = GoalPeriod.weekly;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _autoLink = true;
  bool _reminderEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      final goal = widget.existingGoal!;
      _titleController = TextEditingController(text: goal.title);
      _targetController = TextEditingController(text: goal.targetValue.toStringAsFixed(0));
      _selectedMetric = goal.metric;
      _selectedPeriod = goal.period;
      _customStartDate = goal.startDate;
      _customEndDate = goal.endDate;
      _autoLink = goal.autoLink;
      _reminderEnabled = goal.reminderEnabled;
    } else {
      _titleController = TextEditingController();
      _targetController = TextEditingController();
      _updateTitle();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _updateTitle() {
    String title = '';
    switch (_selectedMetric) {
      case GoalMetric.calories:
        title = 'Burn Calories';
        break;
      case GoalMetric.duration:
        title = 'Workout Duration';
        break;
      case GoalMetric.workouts:
        title = 'Complete Workouts';
        break;
    }

    if (_selectedPeriod == GoalPeriod.weekly) {
      title = 'Weekly $title';
    } else if (_selectedPeriod == GoalPeriod.monthly) {
      title = 'Monthly $title';
    }

    _titleController.text = title;
  }

  (DateTime, DateTime) _calculateDates() {
    final now = DateTime.now();

    if (_selectedPeriod == GoalPeriod.custom) {
      return (_customStartDate ?? now, _customEndDate ?? now.add(const Duration(days: 7)));
    }

    if (_selectedPeriod == GoalPeriod.weekly) {
      // final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeek = now; // start from current moment
      final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
      return (startOfWeek, endOfWeek);
    }

    // Monthly
    // final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfMonth = now; // start from current moment
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59);
    return (startOfMonth, endOfMonth);
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final dates = _calculateDates();

    setState(() => _isLoading = true);

    try {
      if (widget.existingGoal != null) {
        // Update existing goal
        final updatedGoal = widget.existingGoal!.copyWith(
          title: _titleController.text,
          targetValue: double.parse(_targetController.text),
          metric: _selectedMetric,
          period: _selectedPeriod,
          startDate: dates.$1,
          endDate: dates.$2,
          autoLink: _autoLink,
          reminderEnabled: _reminderEnabled,
        );
        await _goalService.updateGoal(updatedGoal);
      } else {
        // Create new goal
        await _goalService.createGoal(
          userID: widget.userID,
          title: _titleController.text,
          metric: _selectedMetric,
          targetValue: double.parse(_targetController.text),
          period: _selectedPeriod,
          startDate: dates.$1,
          endDate: dates.$2,
          autoLink: _autoLink,
          reminderEnabled: _reminderEnabled,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingGoal != null
                ? 'Goal updated successfully'
                : 'Goal created successfully'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.existingGoal != null ? 'Edit Goal' : 'Create New Goal',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Metric Selection
                  const Text(
                    'Goal Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildMetricChip(GoalMetric.calories, 'Calories', Icons.local_fire_department),
                      _buildMetricChip(GoalMetric.duration, 'Duration', Icons.timer),
                      _buildMetricChip(GoalMetric.workouts, 'Workouts', Icons.fitness_center),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Goal Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.flag),
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),

                  // Target Value
                  TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target Value',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.trending_up),
                      suffixText: _getUnitLabel(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Please enter target value';
                      if (double.tryParse(value!) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Period Selection
                  const Text(
                    'Time Period',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildPeriodChip(GoalPeriod.weekly, 'Weekly'),
                      _buildPeriodChip(GoalPeriod.monthly, 'Monthly'),
                      _buildPeriodChip(GoalPeriod.custom, 'Custom'),
                    ],
                  ),

                  if (_selectedPeriod == GoalPeriod.custom) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePicker(
                            label: 'Start Date',
                            date: _customStartDate,
                            onTap: () => _selectDate(isStart: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDatePicker(
                            label: 'End Date',
                            date: _customEndDate,
                            onTap: () => _selectDate(isStart: false),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Auto-link toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sync, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Auto-sync from workouts',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Automatically track progress from completed sessions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoLink,
                          onChanged: (value) => setState(() => _autoLink = value),
                          activeColor: const Color(0xFF3C467B),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Reminder toggle
                  SwitchListTile(
                    title: const Text('Enable Reminders'),
                    subtitle: const Text('Get notified about your goal progress'),
                    value: _reminderEnabled,
                    onChanged: (value) => setState(() => _reminderEnabled = value),
                    activeColor: const Color(0xFF3C467B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.grey[50],
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C467B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : Text(
                        widget.existingGoal != null ? 'Update Goal' : 'Create Goal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(GoalMetric metric, String label, IconData icon) {
    final isSelected = _selectedMetric == metric;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedMetric = metric;
            _updateTitle();
          });
        }
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF3C467B).withOpacity(0.2),
      checkmarkColor: const Color(0xFF3C467B),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF3C467B) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF3C467B) : Colors.transparent,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildPeriodChip(GoalPeriod period, String label) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPeriod = period;
            _updateTitle();
          });
        }
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF3C467B).withOpacity(0.2),
      checkmarkColor: const Color(0xFF3C467B),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF3C467B) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF3C467B) : Colors.transparent,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormat('MMM d, yyyy').format(date) : 'Select date',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_customStartDate ?? DateTime.now())
        : (_customEndDate ?? DateTime.now().add(const Duration(days: 7)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _customStartDate = picked;
        } else {
          _customEndDate = picked;
        }
      });
    }
  }

  String _getUnitLabel() {
    switch (_selectedMetric) {
      case GoalMetric.calories:
        return 'kcal';
      case GoalMetric.duration:
        return 'minutes';
      case GoalMetric.workouts:
        return 'sessions';
    }
  }
}