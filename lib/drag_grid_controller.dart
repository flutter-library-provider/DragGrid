import 'package:flutter/material.dart';

/// Dragging GridView Controller (manual update GridView sorting, support animation)
class GridController<T> extends ChangeNotifier {
  /// Grid Items
  List<T> _itemList = [];

  /// Enable Animation
  bool _animation = true;

  /// Getter get _itemList
  get itemList => _itemList;

  /// Getter get _animation
  get animation => _animation;

  /// Update itemList from DragGrid
  void update(List<T> itemList) {
    _itemList = [...itemList];
  }

  /// Append Grid Item to update itemList, and render DragGrid
  void append({required T item, bool animation = true}) {
    _itemList.removeWhere((opt) => opt == item);
    _animation = animation;
    _itemList.add(item);
    notifyListeners();
  }

  /// Remove Grid Item to update itemList, and render DragGrid
  void remove({required int index, bool animation = true}) {
    if (index < 0) {
      index = itemList.length + index;
    }

    if (index >= 0 && index < _itemList.length) {
      _itemList.removeAt(index);
      _animation = animation;
      notifyListeners();
    }
  }

  /// Insert Grid Item to update itemList, and render DragGrid
  void insert({int index = 0, required T item, bool animation = true}) {
    if (index < 0) {
      index = itemList.length + index;
    }

    if (index >= 0 && index < _itemList.length) {
      _itemList.removeWhere((opt) => opt == item);
      _itemList.insert(index, item);
      _animation = animation;
      notifyListeners();
    }
  }

  /// Reset itemList of DragGrid, and render DragGrid
  void reset({required List<T> itemList, bool animation = true}) {
    _animation = animation;
    _itemList = itemList;
    notifyListeners();
  }
}
