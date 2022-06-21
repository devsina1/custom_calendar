import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  TextStyle? style;
  String? startDay;
  String? endDay;
  List<List<String>> dayList = [];
  int? year;
  int? month;
  List<String> dayName = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    style = const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
    initDay();
    initDayList();
  }

  /// 날짜 초기화 (월초, 월말)
  void initDay() {
    DateTime now = DateTime.now();
    if (year == null && month == null) {
      year = now.year;
      month = now.month;
    }
    startDay = DateFormat('yyyy-MM-dd').format(DateTime(year!, month!, 1));
    endDay = DateFormat('yyyy-MM-dd').format(DateTime(year!, month! + 1, 0));
  }

  /// 월별 날짜 초기화
  void initDayList() {
    dayList = [];
    List<String> list = [];
    int _start = DateTime.parse(startDay!).day;
    int _end = DateTime.parse(endDay!).day;

    for (int day = _start; day <= _end; day++) {
      DateTime _day = DateTime(year!, month!, day);

      // 월 초가 일요일이 아닌 경우
      if (_day == DateTime.parse(startDay!) && _day.weekday != 7) {
        int aboveDay = _day.weekday;
        list.addAll(insertEmptyList(aboveDay));
      }
      list.add(DateFormat('yyyy-MM-dd').format(_day));

      // 월 말이 토요일이 아닌 경우
      if (_day == DateTime.parse(endDay!) && _day.weekday != 6) {
        int aboveDay = _day.weekday == 7 ? 6 : 6 - _day.weekday;
        list.addAll(insertEmptyList(aboveDay));
      }

      // 한 주가 다 채워진 경우
      if (list.length == 7) {
        dayList.add(list);
        list = [];
      }
    }
  }

  /// 공란 채우기
  List<String> insertEmptyList(int value) {
    List<String> list = [];
    for (int i = 0; i < value; i++) {
      list.add('');
    }
    return list;
  }

  /// 일자 박스
  Widget _box(String text, {int? weekday}) {
    return Container(
      height: 50,
      alignment: Alignment.topRight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      child: Text(
        '$text ',
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 14,
          color: weekday != null ? _dayColor(weekday) : Colors.black,
        ),
      ),
    );
  }

  /// 날짜 색상
  Color _dayColor(int weekday) {
    switch (weekday) {
      case 6:
        return Colors.blue;
      case 7:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  /// 이전 달 이동
  void prevMonth() {
    setState(() {
      if (month == 1) {
        month = 12;
        year = year! - 1;
      } else {
        month = month! - 1;
      }

      initDay();
      initDayList();
    });
  }

  /// 다음 달 이동
  void nextMonth() {
    setState(() {
      if (month == 12) {
        month = 1;
        year = year! + 1;
      } else {
        month = month! + 1;
      }
      initDay();
      initDayList();
    });
  }

  /// 달력 헤더 색상
  Color _dayNameColor(String name) {
    switch (name) {
      case '일':
        return Colors.red;
      case '토':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Calendar'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.arrow_back_ios),
                          ),
                          onTap: () {
                            prevMonth();
                          }),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          '${year!}년 ${month!}월',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: const Icon(Icons.arrow_forward_ios),
                          ),
                          onTap: () {
                            nextMonth();
                          }),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Row(
                    children: dayName.map((e) {
                      return Expanded(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Text(
                            '$e',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: _dayNameColor(e)
                            ),
                          ),
                        ),
                      );
                    }).toList()),
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                alignment: Alignment.topCenter,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: dayList.map((e) {
                      return Row(
                        children: e.map((day) {
                          String? text;
                          DateTime? _day;
                          if (day != '') {
                            _day = DateTime.parse(day);
                            text = DateFormat('dd').format(_day);
                          } else {
                            text = '\t';
                          }
                          return Expanded(
                              child: day != ''
                                  ? InkWell(
                                child: _box(text, weekday: _day!.weekday),
                                onTap: () {
                                  print('>>>> $day');
                                },
                              )
                                  : _box(text));
                        }).toList(),
                      );
                    }).toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}