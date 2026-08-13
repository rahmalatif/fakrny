import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../core/design/theme/app_color.dart';
import '../core/design/widgets/nav_bar.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({super.key});

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 20),

              Text(
                AppLocalizations.of(context)!.calender,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              _buildCalendar(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.of(context)!.todaysSchadule,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  _taskCard(
                    title: 'تحضير العرض التقديمي',
                    time: '9:00 - 11:00 ص',
                    icon: Icons.work_outline,
                  ),

                  const SizedBox(height: 12),

                  _taskCard(
                    title: 'غداء مع الفريق',
                    time: '1:00 - 2:00 م',
                    icon: Icons.restaurant_outlined,
                  ),

                  const SizedBox(height: 12),

                  _taskCard(
                    title: 'مذاكرة Flutter',
                    time: '4:00 - 6:00 م',
                    icon: Icons.menu_book_outlined,
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColor.Grad3,
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildCalendar() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: TableCalendar(
        locale: AppLocalizations.of(context)!.calenderlang,

        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),

        focusedDay: _focusedDay,
        currentDay: DateTime.now(),

        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },

        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },

        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,

          leftChevronIcon: Icon(Icons.chevron_left, size: 20),

          rightChevronIcon: Icon(Icons.chevron_right, size: 20),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontSize: 11, color: Colors.grey),

          weekendStyle: TextStyle(fontSize: 11, color: Colors.grey),
        ),

        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,

          defaultTextStyle: const TextStyle(fontSize: 11),

          weekendTextStyle: const TextStyle(fontSize: 11),

          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),

          todayTextStyle: const TextStyle(color: Colors.black, fontSize: 11),

          selectedDecoration: const BoxDecoration(
            color: Color(0xff5B5BFF),
            shape: BoxShape.circle,
          ),

          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),

          cellMargin: const EdgeInsets.all(4),
        ),
      ),
    );
  }

  Widget _taskCard({
    required String title,
    required String time,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xffEEEEFF),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xff5B5BFF),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, color: Colors.white, size: 20),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
