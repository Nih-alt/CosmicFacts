import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/observation_log.dart';
import '../../theme/app_colors.dart';

class AddObservationScreen extends StatefulWidget {
  const AddObservationScreen({super.key, this.initialLog});

  final ObservationLog? initialLog;

  @override
  State<AddObservationScreen> createState() => _AddObservationScreenState();
}

class _AddObservationScreenState extends State<AddObservationScreen> {
  late final TextEditingController _objectNameCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _locationCtrl;

  String _objectType = 'Planet';
  String _equipment = 'Naked Eye';
  String _conditions = 'Good';
  int _rating = 3;
  DateTime _observedAt = DateTime.now();

  static const List<String> _objectTypes = [
    'Planet',
    'Star',
    'Nebula',
    'Galaxy',
    'Constellation',
    'Meteor',
    'Comet',
    'Other',
  ];

  static const List<String> _equipmentOptions = [
    'Naked Eye',
    'Binoculars',
    'Telescope',
    'Camera',
    'Other',
  ];

  static const List<String> _conditionOptions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor',
  ];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isEditing => widget.initialLog != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLog;
    _objectNameCtrl = TextEditingController(text: initial?.objectName ?? '');
    _notesCtrl = TextEditingController(text: initial?.notes ?? '');
    _locationCtrl = TextEditingController(text: initial?.location ?? '');

    if (initial != null) {
      _objectType = initial.objectType;
      _equipment = initial.equipment;
      _conditions = initial.conditions;
      _rating = initial.rating;
      _observedAt = initial.observedAt;
    }
  }

  @override
  void dispose() {
    _objectNameCtrl.dispose();
    _notesCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF080818)
          : const Color(0xFFF2F0FF),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF080818)
            : const Color(0xFFF2F0FF),
        surfaceTintColor: isDark
            ? const Color(0xFF080818)
            : const Color(0xFFF2F0FF),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.close, color: _primaryTextColor(isDark)),
        ),
        title: Text(
          _isEditing ? 'Edit Observation' : 'Log Observation',
          style: GoogleFonts.spaceGrotesk(
            color: _primaryTextColor(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveObservation,
            child: Text(
              _isEditing ? 'Update' : 'Save',
              style: GoogleFonts.inter(
                color: isDark ? AppColors.accentCyan : AppColors.accentBlue,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Object Name *', isDark),
              _buildTextField(
                controller: _objectNameCtrl,
                hint: 'e.g. Jupiter, Orion Nebula...',
                isDark: isDark,
                icon: Icons.search,
              ),
              const SizedBox(height: 16),
              _buildSectionLabel('Object Type', isDark),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _objectTypes.map((type) {
                  final selected = _objectType == type;
                  final accent = _getTypeColor(type, isDark);
                  return GestureDetector(
                    onTap: () => setState(() => _objectType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withValues(alpha: isDark ? 0.22 : 0.14)
                            : _surfaceColor(isDark),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? accent : _borderColor(isDark),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getTypeIcon(type),
                              color: selected
                                  ? accent
                                  : _secondaryTextColor(isDark),
                              size: 14),
                          const SizedBox(width: 4),
                          Text(
                            type,
                            style: GoogleFonts.inter(
                              color: selected
                                  ? accent
                                  : _secondaryTextColor(isDark),
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _buildSectionLabel('Date & Time', isDark),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _surfaceColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor(isDark)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: isDark
                            ? AppColors.accentCyan
                            : AppColors.accentBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatDate(_observedAt),
                          style: GoogleFonts.inter(
                            color: _primaryTextColor(isDark),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: _mutedIconColor(isDark),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionLabel('Your Rating', isDark),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: AppColors.starGold,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              _buildSectionLabel('Equipment', isDark),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _equipmentOptions.map((equipment) {
                  final selected = _equipment == equipment;
                  final accent = isDark
                      ? AppColors.accentCyan
                      : AppColors.accentBlue;
                  return GestureDetector(
                    onTap: () => setState(() => _equipment = equipment),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withValues(alpha: isDark ? 0.22 : 0.14)
                            : _surfaceColor(isDark),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? accent : _borderColor(isDark),
                        ),
                      ),
                      child: Text(
                        equipment,
                        style: GoogleFonts.inter(
                          color: selected
                              ? accent
                              : _secondaryTextColor(isDark),
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _buildSectionLabel('Sky Conditions', isDark),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _conditionOptions.map((condition) {
                  final selected = _conditions == condition;
                  final accent = _getConditionColor(condition, isDark);
                  return GestureDetector(
                    onTap: () => setState(() => _conditions = condition),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withValues(alpha: isDark ? 0.22 : 0.14)
                            : _surfaceColor(isDark),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? accent : _borderColor(isDark),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getConditionIcon(condition),
                              color: selected
                                  ? accent
                                  : _secondaryTextColor(isDark),
                              size: 14),
                          const SizedBox(width: 4),
                          Text(
                            condition,
                            style: GoogleFonts.inter(
                              color: selected
                                  ? accent
                                  : _secondaryTextColor(isDark),
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _buildSectionLabel('Location (optional)', isDark),
              _buildTextField(
                controller: _locationCtrl,
                hint: 'e.g. Rooftop, Countryside...',
                isDark: isDark,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildSectionLabel('Notes (optional)', isDark),
              Container(
                decoration: BoxDecoration(
                  color: _surfaceColor(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor(isDark)),
                ),
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  style: GoogleFonts.inter(
                    color: _primaryTextColor(isDark),
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What did you see? Any details...',
                    hintStyle: GoogleFonts.inter(
                      color: _hintTextColor(isDark),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _saveObservation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isDark
                                    ? AppColors.accentCyan
                                    : AppColors.accentBlue)
                                .withValues(alpha: isDark ? 0.18 : 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    _isEditing ? 'Update Observation' : 'Save Observation',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.surfaceLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: _secondaryTextColor(isDark),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor(isDark)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          color: _primaryTextColor(isDark),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: _hintTextColor(isDark),
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: _mutedIconColor(isDark), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final isDark = _isDark;
    final seedColor = isDark ? AppColors.accentCyan : AppColors.accentBlue;

    final date = await showDatePicker(
      context: context,
      initialDate: _observedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_observedAt),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null || !mounted) return;

    setState(() {
      _observedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveObservation() async {
    if (_objectNameCtrl.text.trim().isEmpty) {
      final isDark = _isDark;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            'Please enter the object name',
            style: GoogleFonts.inter(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.surfaceLight,
            ),
          ),
        ),
      );
      return;
    }

    final box = Hive.box<ObservationLog>('observations');
    final existing = widget.initialLog;

    if (existing != null) {
      existing
        ..objectName = _objectNameCtrl.text.trim()
        ..objectType = _objectType
        ..observedAt = _observedAt
        ..notes = _notesCtrl.text.trim()
        ..rating = _rating
        ..equipment = _equipment
        ..conditions = _conditions
        ..location = _locationCtrl.text.trim()
        ..isVisible = true;
      await existing.save();
    } else {
      final log = ObservationLog()
        ..id = DateTime.now().microsecondsSinceEpoch.toString()
        ..objectName = _objectNameCtrl.text.trim()
        ..objectType = _objectType
        ..observedAt = _observedAt
        ..notes = _notesCtrl.text.trim()
        ..rating = _rating
        ..equipment = _equipment
        ..conditions = _conditions
        ..location = _locationCtrl.text.trim()
        ..isVisible = true;
      await box.add(log);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Color _surfaceColor(bool isDark) =>
      isDark ? const Color(0xFF141438) : Colors.white;

  Color _borderColor(bool isDark) =>
      isDark ? AppColors.glassBorder(context) : AppColors.divider(context);

  Color _primaryTextColor(bool isDark) =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  Color _secondaryTextColor(bool isDark) =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  Color _hintTextColor(bool isDark) =>
      isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

  Color _mutedIconColor(bool isDark) =>
      isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight;

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Planet':
        return Icons.public;
      case 'Star':
        return Icons.star_outline;
      case 'Nebula':
        return Icons.cloud_outlined;
      case 'Galaxy':
        return Icons.blur_circular;
      case 'Constellation':
        return Icons.auto_awesome_outlined;
      case 'Meteor':
        return Icons.north_east;
      case 'Comet':
        return Icons.trending_up;
      default:
        return Icons.visibility_outlined;
    }
  }

  Color _getTypeColor(String type, bool isDark) {
    switch (type) {
      case 'Planet':
        return isDark ? AppColors.accentGreen : AppColors.success;
      case 'Star':
        return AppColors.starGold;
      case 'Nebula':
        return AppColors.legacyPurple;
      case 'Galaxy':
        return isDark ? AppColors.accentCyan : AppColors.accentBlueLight;
      case 'Constellation':
        return isDark ? AppColors.accentBlueLight : AppColors.accentBlue;
      case 'Meteor':
        return AppColors.accentOrange;
      case 'Comet':
        return isDark ? AppColors.accentGreen : AppColors.accentCyan;
      default:
        return isDark ? AppColors.accentCyan : AppColors.accentBlue;
    }
  }

  IconData _getConditionIcon(String condition) {
    switch (condition) {
      case 'Excellent':
        return Icons.auto_awesome;
      case 'Good':
        return Icons.wb_sunny_outlined;
      case 'Fair':
        return Icons.nights_stay_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }

  Color _getConditionColor(String condition, bool isDark) {
    switch (condition) {
      case 'Excellent':
        return isDark ? AppColors.accentGreen : AppColors.success;
      case 'Good':
        return isDark ? AppColors.accentCyan : AppColors.accentBlue;
      case 'Fair':
        return AppColors.starGold;
      default:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $hour:$minute $ampm';
  }
}
