# DragGrid

这是一个支持拖动 Item 的 GridView，支持在拖动中进行动画过渡，同时还提供 gridController 支持手动更新排序。

<p>
  <img 
    src="https://linpengteng.github.io/resource/flutter-grid/vertical-1.gif" 
    alt="vertical-1.gif"
    width="32%"
  >
  <img
    src="https://linpengteng.github.io/resource/flutter-grid/vertical-2.gif"
    alt="vertical-2.gif"
    width="32%"
  >
  <img
    src="https://linpengteng.github.io/resource/flutter-grid/horizontal-1.gif"
    alt="horizontal-1.gif"
    width="32%"
  >
</p>

<br/>

## 实现原理

如果你对 **DragGrid** 如何实现的原理感兴趣，可以看这篇 [图文详解 - 如何开发 Draggable GridView 组件](https://juejin.cn/post/7380233813987426354) 文章

<br/>

## 如何安装

1. 在 `pubspec.yaml` 添加

   ```
     dependencies:
       drag_grid: ^1.0.6
   ```

2. 在命令行运行如下

   ```
    flutter pub get
   ```

<br/>

## 简单使用

```dart
  class DragGridUsage extends StatelessWidget {
    const DragGridUsage({super.key});

    @override
    Widget build(BuildContext context) {
      return DragGrid<String>(
        itemList: List.generate(16, (i) => '$i'),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
        sliverGridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, item, index) {
          return Container(
            width: 64.0,
            height: 64.0,
            alignment: Alignment.center,
            color: const Color(0xfff0f0f0),
            child: Text(
              item,
              style: const TextStyle(
                color: Color(0xff404244),
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                height: 1,
              ),
            ),
          );
        },
      );
    }
  }
```

<br/>

## API 文档

### DragGrid

| API                | 说明                                                                      | 必选 | 默认值                               |
| :----------------- | :------------------------------------------------------------------------ | :--- | :----------------------------------- |
| onDragStarted      | 来自于 LongPressDraggable onDragStarted                                   | 否   |                                      |
| onDragUpdate       | 来自于 LongPressDraggable onDragUpdate                                    | 否   |                                      |
| onDragEnd          | 来自于 LongPressDraggable onDragEnd                                       | 否   |                                      |
| sortChanger        | Grid Item 拖拽过程中，itemList 排序发生变化时触发                         | 否   |                                      |
| itemListChanger    | Grid Item 拖拽结束后触发，同步更新 itemList。手动更新排序也会触发         | 否   |                                      |
| isItemListChanged  | 外部 Widget 变化时, **DragGrid** 是否重新渲染（Using in didUpdateWidget） | 否   |                                      |
| gridController     | DragGrid Controller (手动更新 itemList, 支持动画过渡)                     | 否   |                                      |
| scrollController   | GridView scrollController                                                 | 否   |                                      |
| sliverGridDelegate | GridView SliverGridDelegate                                               | 是   |                                      |
| ScrollPhysics      | GridView physics                                                          | 否   | const NeverScrollableScrollPhysics() |
| itemBuilder        | GridView item builder                                                     | 是   |                                      |
| padding            | GridView padding                                                          | 否   | EdgeInsets.zero                      |
| duration           | 指定 动画时长                                                             | 否   | const Duration(milliseconds: 500)    |
| crossCount         | 指定 GridView 横轴数量（默认: 从 sliverGridDelegate 获取）                | 否   |                                      |
| direction          | GridView 方向，默认 Axis.vertical                                         | 否   | Axis.vertical                        |
| itemList           | DragGrid item 数据源 (拷贝)，用来计算实时排序                             | 是   |                                      |
| shrinkWrap         | GridView shrinkWrap                                                       | 否   | true                                 |
| animation          | 是否启用 DragGrid 过渡动画                                                | 否   | true                                 |
| enable             | 是否启用 DragGrid，当值为 false 时，单纯渲染为 GridView                   | 否   | true                                 |

### GridController

| API    | 说明                                                                | 参数                                                    |
| :----- | :------------------------------------------------------------------ | :------------------------------------------------------ |
| update | 用来从 DragGrid 获取最新的 itemList Api                             | List\<T> itemList                                       |
| append | 手动追加新 Grid Item, 会重新渲染 DragGrid，并触发 itemListChanger   | {required T item, bool animation = true}                |
| remove | 手动移除某个 Grid Item, 会重新渲染 DragGrid，并触发 itemListChanger | {required int index, bool animation = true}             |
| insert | 手动插入某个 Grid Item, 会重新渲染 DragGrid，并触发 itemListChanger | {int index = 0, required T item, bool animation = true} |
| reset  | 手动重置 itemList, 会重新渲染 DragGrid，并触发 itemListChanger      | {required List\<T> itemList, bool animation = true}     |

<br/>

## 其他说明

如果您发现任何错误，请提交一个 [issues](https://github.com/flutter-library-provider/DragGrid/issues)。如果你愿意自己修复或增强东西，非常欢迎你提 **PR**。
