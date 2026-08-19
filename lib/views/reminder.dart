import 'package:flutter/material.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../core/design/widgets/form.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _titleController = TextEditingController();
  String selectedCategory = 'study';
  String selectedPriority = 'high';
  int reminderBefore = 30;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  String _getDateText() {
    if (selectedDate == null) {
      return AppLocalizations.of(context)!.chooseDate;
    }

    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  String _getTimeText() {
    if (selectedTime == null) {
      return AppLocalizations.of(context)!.chooseTime;
    }

    return selectedTime!.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
        
                      const Spacer(),
        
                      Text(
                        AppLocalizations.of(context)!.createReminder,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
        
                      const Spacer(),
        
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
        
                Text(
                  AppLocalizations.of(context)!.createReminderSub,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
        
                const SizedBox(height: 15),
        
                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  child: AppTextField(
                    hintText: AppLocalizations.of(context)!.titleHint,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(Icons.file_copy_outlined),
                    title: AppLocalizations.of(context)!.title,
                    controller: _titleController,
                  ),
                ),
                const SizedBox(height: 15),
        
                _container(
                  value: _getDateText(),
                  title: AppLocalizations.of(context)!.date,
                  icon: const Icon(Icons.date_range),
                  onTap: _selectDate,
                  height: 50,
                ),
        
                const SizedBox(height: 20),
        
                _container(
                  value: _getTimeText(),
                  title: AppLocalizations.of(context)!.time,
                  icon: const Icon(Icons.access_time),
                  onTap: _selectTime,
                  height: 50,
                ),
        
                const SizedBox(height: 10),
        
                _categorycontainer(),
                const SizedBox(height: 10),
        
                _prioritySection(),
        
                SizedBox(height: 120),
        
                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.deepPurple.withOpacity(.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none, size: 20),
        
                        const SizedBox(width: 8),
        
                        Text(
                          AppLocalizations.of(context)!.saveReminder,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _container({
    required String value,
    required String title,
    required Icon icon,
    required VoidCallback onTap,
    required double height,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width * .9,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const Spacer(),

            IconButton(onPressed: onTap, icon: icon),
          ],
        ),
      ),
    );
  }

  Widget _categorycontainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              Text(
                AppLocalizations.of(context)!.chooseCategory,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _categoryItem(
              value: 'study',
              title: AppLocalizations.of(context)!.study,
              icon: Icons.school_outlined,
            ),

            const SizedBox(width: 8),

            _categoryItem(
              value: 'work',
              title: AppLocalizations.of(context)!.work,
              icon: Icons.work_outline,
            ),

            const SizedBox(width: 8),

            _categoryItem(
              value: 'health',
              title: AppLocalizations.of(context)!.health,
              icon: Icons.favorite_border,
            ),

            const SizedBox(width: 8),

            _categoryItem(
              value: 'other',
              title: AppLocalizations.of(context)!.other,
              icon: Icons.more_horiz,
            ),
          ],
        ),
      ],
    );
  }

  Widget _categoryItem({
    required String value,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = selectedCategory == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = value;
        });
      },
      child: Container(
        width: 68,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.withOpacity(.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurple.withOpacity(.3)
                : Colors.grey.withOpacity(.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.deepPurple : Colors.grey,
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.deepPurple : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Text(
            AppLocalizations.of(context)!.priority,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _priorityItem(
              value: 'high',
              title: AppLocalizations.of(context)!.high,
              iconColor: Colors.red,
            ),

            const SizedBox(width: 8),

            _priorityItem(
              value: 'medium',
              title: AppLocalizations.of(context)!.medium,
              iconColor: Colors.orange,
            ),

            const SizedBox(width: 8),

            _priorityItem(
              value: 'low',
              title: AppLocalizations.of(context)!.low,
              iconColor: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _priorityItem({
    required String value,
    required String title,
    required Color iconColor,
  }) {
    final bool isSelected = selectedPriority == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPriority = value;
        });
      },
      child: Container(
        width: 92,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? iconColor.withOpacity(.25)
                : Colors.grey.withOpacity(.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? iconColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),

            const SizedBox(width: 8),

            Icon(Icons.flag_outlined, size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }
}
