import 'package:flutter/material.dart';
import 'package:drag_grid/drag_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DragGrid', (WidgetTester tester) async {
    expect(
      DragGrid(
        itemList: const [],
        sliverGridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, list, index) {
          return const Align(
            alignment: Alignment.center,
            child: SizedBox(width: 72, height: 72),
          );
        },
      ),
      isA<Widget>(),
    );
  });
}
