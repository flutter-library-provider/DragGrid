## 1.0.7

- fix: support SliverGridDelegate mainAxisExtent ([Using mainAxisExtent bug](https://github.com/flutter-library-provider/DragGrid/issues/3))
- fix: grid size boundary bug ([BoxConstraints(w=66.0, h=-8.4; NOT NORMALIZED)](https://github.com/flutter-library-provider/DragGrid/issues/2))

## 1.0.6

- chore: upgrade dependencies, and update README.md

## 1.0.5

- chore: update some docs

## 1.0.4

- chore: upgrade some dependencies

## 1.0.3

- fix the offset bug  
  the offset may not be accurate when external animation is playing  
  for example: using in GetX.bottomSheet

## 1.0.2

- Update README.md

## 1.0.0

- Complete the basic functions of DragGrid
  - Provide gridController (manual update GridView sorting)
  - Provide a draggable GridView (support animation transitions)
  - Provide sortChanger And itemListChanger Callback
