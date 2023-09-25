import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:to_d/controllers/task_controller.dart';
import 'package:to_d/services/theme_services.dart';
import 'package:to_d/ui/pages/add_task_page.dart';
import 'package:to_d/ui/size_config.dart';
import 'package:to_d/ui/widgets/task_tile.dart';
import '../../models/task.dart';
import '../theme.dart';
import '../widgets/button.dart';
import 'notification_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late NotifyHelper notifyHelper;

  @override
  void initState() {
    super.initState();

    _taskController.getTasks();

    // notifyHelper = NotifyHelper();
    // notifyHelper.requestIOSPermissions();
    // notifyHelper.initializeNotification();
  }

  DateTime _selectedDate = DateTime.now();

  final TaskController _taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(
            height: 10,
          ),
          _showTasks(),
        ],
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                'Today',
                style: subHeadingStyle,
              )
            ],
          ),
          MyButton(
              label: '+ Add Task',
              onTap: () async {
                await Get.to(AddTaskPage());
                _taskController.getTasks();
              })
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 20),
      child: DatePicker(
        DateTime.now(),
        width: 80,
        height: 100,
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        dateTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        )),
        dayTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        )),
        monthTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        )),
        initialSelectedDate: _selectedDate,
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  Future <void> _onRefresh() async{
    await _taskController.getTasks();

  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        if (_taskController.taskList.isEmpty) {
          return noTaskMsg();
        
        } else {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
            scrollDirection: SizeConfig.orientation == Orientation.landscape
                ? Axis.horizontal
                : Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              var task = _taskController.taskList[index];

              if (task.repeat == 'Daily' ||task.date == DateFormat.yMd().format(_selectedDate)|| 
              ((task.repeat == 'Monthly') && DateFormat.yMd().parse(task.date!).day == _selectedDate.day) ||
              ((task.repeat == 'Weekly') && _selectedDate.difference(DateFormat.yMd().parse(task.date!)).inDays %7 == 0)){

                // print('task ${task.date}');
                // print('task after 7 ${DateFormat.yMd().format(_selectedDate.subtract(Duration(days: 7)))}');
              var hour = task.startTime.toString().split(':')[0];
              var minutes = task.startTime.toString().split(':')[1];
              var date = DateFormat().add_jm().parse(task.startTime!);
                
              var myTime = DateFormat('hh:mm a').format(date);
              return AnimationConfiguration.staggeredList(
                duration: Duration(milliseconds: 1375),
                position: index,
                child: SlideAnimation(
                  horizontalOffset: 300,
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () {
                        _showBottomSheet(context, task);
                      },
                      child: TaskTile(task),
                    ),
                  ),
                ),
              );
              }
              else return Container();
                
                
              
                
              // notifyHelper.scheduledNotification(
              //   11,//int.parse(myTime.toString().split(':')[0]),
              //   47,//int.parse(myTime.toString().split(':')[1]),
              //   task,
              // );
              
            },
            itemCount: _taskController.taskList.length,
                ),
          );
      }
          
        }),
    );
  
  }

  _appBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          ThemeServices().switchTheme();
          // notifyHelper.displayNotification(title: 'Theme changed', body: 'body');

          // notifyHelper.scheduledNotification();
        },
        icon: Icon(
          Get.isDarkMode ? Icons.sunny : Icons.nightlight,
          size: 24,
          color: Get.isDarkMode ? Colors.white : darkGreyClr,
        ),
      ),
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      actions: [
        IconButton(
          onPressed:()=> _taskController.deleteAllTasks(),
          icon: Icon(Icons.cleaning_services,
            size: 24,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
            
          ),
        ),
        CircleAvatar(
            backgroundImage: AssetImage('images/person.jpeg'), radius: 18),
        SizedBox(width: 20),
      ],
    );
  }

  noTaskMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 3000),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Wrap(
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? SizedBox(height: 6)
                      : SizedBox(height: 220),
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 90,
                    semanticsLabel: 'Task',
                    color: primaryClr.withOpacity(0.5),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Text(
                        'You do not have any tasks yet!\n'
                        'Add new tasks to make your day productive.',
                        style: subTitleStyle,
                        textAlign: TextAlign.center),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? SizedBox(height: 120)
                      : SizedBox(height: 180),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 4),
        width: SizeConfig.screenWidth,
        height: (SizeConfig.orientation == Orientation.landscape)
            ? (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.6
                : SizeConfig.screenHeight * 0.8)
            : (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.30
                : SizeConfig.screenHeight * 0.39),
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        child: Column(
          children: [
            Flexible(
              child: Container(
                width: 120,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            task.isCompleted == 1
                ? Container()
                : _buildBottomSheet(
                    label: 'Task Completed',
                    onTap: () {
                      _taskController.markIsComleted(task.id!);
                      Get.back();
                    },
                    clr: primaryClr),
            _buildBottomSheet(
                label: 'Delete Completed',
                onTap: () {
                  _taskController.deleteTasks(task);
                  Get.back();
                },
                clr: Colors.red[300]!
                ),
            Divider(
              color: Get.isDarkMode ? Colors.grey : darkGreyClr,
            ),
            _buildBottomSheet(
                label: 'Show Task',
                onTap: () {
                  Get.to(NotificationScreen(payload: '${task.title}|${task.note}|${task.startTime}|',));
                },
                clr: primaryClr),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    ));
  }

  _buildBottomSheet(
      {required String label,
      required Function() onTap,
      required Color clr,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: isClose
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : clr),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
