import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/core/widgets/app_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Future<bool?> showAddWeightBottomSheet(
  BuildContext context, {
  double? currentWeight,
  double? currentBodyFat,
  double? currentMuscleMass,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => AddWeightBottomSheet(
      currentWeight: currentWeight,
      currentBodyFat: currentBodyFat,
      currentMuscleMass: currentMuscleMass,
    ),
  );
}

class AddWeightBottomSheet extends StatefulWidget {
  final double? currentWeight;
  final double? currentBodyFat;
  final double? currentMuscleMass;

  const AddWeightBottomSheet({
    super.key,
    this.currentWeight,
    this.currentBodyFat,
    this.currentMuscleMass,
  });

  @override
  State<AddWeightBottomSheet> createState() => _AddWeightBottomSheetState();
}

class _AddWeightBottomSheetState extends State<AddWeightBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _weightController;
  late final TextEditingController _bodyFatController;
  late final TextEditingController _muscleMassController;
  late final TextEditingController _noteController;

  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    _weightController = TextEditingController(
      text: widget.currentWeight != null
          ? widget.currentWeight!.toStringAsFixed(1).replaceAll('.', ',')
          : '',
    );
    _bodyFatController = TextEditingController(
      text: widget.currentBodyFat != null
          ? widget.currentBodyFat!.toStringAsFixed(1).replaceAll('.', ',')
          : '',
    );
    _muscleMassController = TextEditingController(
      text: widget.currentMuscleMass != null
          ? widget.currentMuscleMass!.toStringAsFixed(1).replaceAll('.', ',')
          : '',
    );
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double? _parseDecimal(String raw) {
    final cleaned = raw.trim().replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required';
    }
    final parsed = _parseDecimal(value);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < 30 || parsed > 350) {
      return 'Weight must be between 30 and 350 kg';
    }
    return null;
  }

  String? _validateBodyFat(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = _parseDecimal(value);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < 2 || parsed > 70) {
      return 'Body fat must be between 2 and 70%';
    }
    return null;
  }

  String? _validateMuscleMass(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = _parseDecimal(value);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < 5 || parsed > 150) {
      return 'Muscle mass must be between 5 and 150 kg';
    }
    final weightParsed = _parseDecimal(_weightController.text);
    if (weightParsed != null && parsed >= weightParsed) {
      return 'Muscle mass cannot exceed body weight';
    }
    return null;
  }

  String? _validateNote(String? value) {
    if (value != null && value.length > 250) {
      return 'Note cannot exceed 250 characters';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      await HapticService.warning();
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        SnackBarService.error(context, 'You must be signed in to save data.');
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final weight = _parseDecimal(_weightController.text)!;
      final bodyFat = _bodyFatController.text.trim().isNotEmpty
          ? _parseDecimal(_bodyFatController.text)
          : null;
      final muscleMass = _muscleMassController.text.trim().isNotEmpty
          ? _parseDecimal(_muscleMassController.text)
          : null;
      final note = _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null;

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Weight history document — collection name matches ProgressRemoteDatasource
      final historyRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('weight_history')
          .doc();

      final historyData = <String, dynamic>{
        'weight': weight,
        'createdAt': Timestamp.fromDate(_selectedDate),
      };
      if (bodyFat != null) historyData['bodyFat'] = bodyFat;
      if (muscleMass != null) historyData['muscleMass'] = muscleMass;
      if (note != null) historyData['note'] = note;

      batch.set(historyRef, historyData);

      // Update user document with merge so we only touch relevant fields
      final userRef = firestore.collection('users').doc(user.uid);
      final userUpdate = <String, dynamic>{
        'weight': weight,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (bodyFat != null) userUpdate['bodyFat'] = bodyFat;
      if (muscleMass != null) userUpdate['muscleMass'] = muscleMass;

      batch.set(userRef, userUpdate, SetOptions(merge: true));

      await batch.commit();

      await HapticService.success();

      if (mounted) {
        SnackBarService.success(
          context,
          'Weight entry saved successfully.',
          title: 'Saved',
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      await HapticService.error();
      if (mounted) {
        SnackBarService.error(
          context,
          'Failed to save. Please try again.',
          title: 'Error',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    await HapticService.selection();
    if (!mounted) return;
    final now = DateTime.now();
    // ignore: use_build_context_synchronously
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetColor = theme.cardColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_isSaving,
      child: Container(
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXLarge),
          ),
        ),
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_outlined,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add Weight Entry',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track your body measurements',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Date selector
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurface
                        : AppTheme.lightBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.28),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isToday(_selectedDate) ? '(Today)' : '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Weight field (required)
              _SectionLabel(label: 'Weight (kg) *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                validator: _validateWeight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  hintText: 'e.g. 75,5',
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  suffixText: 'kg',
                  suffixStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 18),

              // Body fat field (optional)
              _SectionLabel(label: 'Body Fat (%) — optional'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodyFatController,
                validator: _validateBodyFat,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  hintText: 'e.g. 18,5',
                  prefixIcon: const Icon(Icons.water_drop_outlined),
                  suffixText: '%',
                  suffixStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 18),

              // Muscle mass field (optional)
              _SectionLabel(label: 'Muscle Mass (kg) — optional'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _muscleMassController,
                validator: _validateMuscleMass,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  hintText: 'e.g. 35,0',
                  prefixIcon: const Icon(Icons.fitness_center_rounded),
                  suffixText: 'kg',
                  suffixStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 18),

              // Note field (optional)
              _SectionLabel(label: 'Note — optional'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                validator: _validateNote,
                maxLength: 250,
                maxLines: 2,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Any note about this measurement...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 22),
                    child: Icon(Icons.notes_rounded),
                  ),
                  counterText: '',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 28),

              // Save button
              AppButton(
                text: 'Save Entry',
                icon: Icons.save_rounded,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _save,
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'Cancel',
                type: AppButtonType.ghost,
                onPressed: _isSaving
                    ? null
                    : () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
    );
  }
}
