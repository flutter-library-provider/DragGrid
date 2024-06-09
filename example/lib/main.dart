import 'package:flutter/material.dart';
import 'package:drag_grid/drag_grid.dart';
import 'package:drag_grid/drag_grid_controller.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

void main() {
  runApp(const MyApp());
}

class TestData {
  TestData({
    this.value = '0',
    this.color,
  });

  String value;
  Color? color;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DragGrid - Axis.vertical'),
        ),
        body: const DragGridUsage(),
        backgroundColor: Colors.white,
      ),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 22.0,
          ),
          titleTextStyle: TextStyle(
            color: Color(0xff000000),
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
    );
  }
}

class DragGridUsage extends StatefulWidget {
  const DragGridUsage({super.key});

  @override
  State<DragGridUsage> createState() => _DragGridUsageState();
}

class _DragGridUsageState extends State<DragGridUsage> {
  GridController<TestData> gridController = GridController();
  List<TestData> itemList = [];
  int lastIndex = 0;

  @override
  void initState() {
    super.initState();

    itemList = List.generate(16, (i) => TestData(value: '$i'));
    lastIndex = 16;
  }

  @override
  Widget build(BuildContext context) {
    const sliverGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        ListView(
          shrinkWrap: false,
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            right: 19.0,
            bottom: 24.0,
          ),
          children: [
            SizedBox(
              child: DragGrid<TestData>(
                itemList: itemList,
                gridController: gridController,
                sliverGridDelegate: sliverGridDelegate,
                itemBuilder: (context, item, index) {
                  return Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64.0,
                          height: 64.0,
                          decoration: ShapeDecoration(
                            gradient: const RadialGradient(
                              center: Alignment(0.0, 0.0),
                              radius: 1.5,
                              colors: [
                                Color(0xffe0e0e0),
                                Color(0xfff0f0f0),
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                5.0,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item.value,
                                style: const TextStyle(
                                  color: Color(0xff404244),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemListChanger: (list) {
                  setState(() {
                    itemList = list;
                  });
                },
                onDragStarted: () async {
                  if (await Vibrate.canVibrate) {
                    Vibrate.feedback(FeedbackType.heavy);
                  }
                },
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          bottom: 48,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 52.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      gradient: const RadialGradient(
                        center: Alignment(0.0, 0.0),
                        radius: 1.8,
                        colors: [
                          Color(0xffe0e0e0),
                          Color(0xfff0f0f0),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ),
                      ),
                    ),
                    child: const Text(
                      '在第2个元素插入',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff707377),
                        letterSpacing: 1.5,
                        height: 1,
                      ),
                    ),
                  ),
                  onTap: () {
                    gridController.insert(
                      item: TestData(value: '${lastIndex++}'),
                      index: 1,
                    );
                  },
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 52.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      gradient: const RadialGradient(
                        center: Alignment(0.0, 0.0),
                        radius: 1.8,
                        colors: [
                          Color(0xffe0e0e0),
                          Color(0xfff0f0f0),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ),
                      ),
                    ),
                    child: const Text(
                      '删除第2个元素',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff707377),
                        letterSpacing: 1.5,
                        height: 1,
                      ),
                    ),
                  ),
                  onTap: () {
                    gridController.remove(index: 1);
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
