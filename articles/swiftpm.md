---
title: "Swift Package Manager in 2021"
date: 2021-07-25T10:40:20+05:00
new: true
tags: SPM
---

## Вопросы

- Почему стоит уйти с Cocoapods?
- Как интегрировать пакеты? Что со сборкой на CI?
- Как структурировать пакеты в SwiftPM
- Как удобно разрабатывать отдельный пакет
- Как удобно выделять модуль для приложением
- Как выпускать версии пакетов и библиотек

## Почему стоит уйти с Cocoapods

SwiftPM поддерживает всё, что поддерживает Cocoapods и даже чуть больше.

### Поддержка ресурсов

Работает, начиная с Xcode 12 и Swift 5.3.

Ресурсы не обязательно объявлять в Package.swift файле. Например, asset catalogs, xib/storyboard, .lproj файлы будут включены в Bundle автоматически.

> When you add a resource to your Swift package, Xcode detects common resource types for Apple platforms and treats them as a resource automatically. For example, you don’t need to make changes to your package manifest for the following resources:
>
> - Interface Builder files; for example, XIB files and storyboards
> - Core Data files; for example, xcdatamodeld files
> - Asset catalogs
> - .lproj folders you use to provide localized resources
>
> <cite>[Bundling resources](https://developer.apple.com/documentation/swift_packages/bundling_resources_with_a_swift_package)</cite>

Использовать ресурсы в коде стало проще. Внутри Swift Package Manager пакета мы можем написать просто `Bundle.module`.

`UIImage(named: "some_image", bundle: .module)`

Это работает благодаря флагу SWIFT_PACKAGE, который доступен внутри пакета.

Пример добавления ресурсов описан в статье [useyourloaf](https://useyourloaf.com/blog/add-resources-to-swift-packages/).

Подробнее в видео [WWDC20. Swift packages: Resources and localization](https://developer.apple.com/wwdc20/10169)

### SwiftGen, R.swift

Работает через Bundle.module.

Нет явных шагов для билда ресурсов, как и с обычными пакетами. Кажется, имеет смысл держать рядом папку scripts с cli. И запускать периодически в терминале.

### Умеет в версионирование

- Выбор версии до следующей мажорной (95% использования)
- Конкретная версия
- Конкретная ветка

### Поддерживает binary frameworks

Поддержка xcframework нужна для библиотек, у которых мы хотим закрыть исходный код. Или, например, у KMM библиотеки, которая нужна как зависимость.

Такие фреймворки ограничены только Apple платформой и теми архитектурами, под которые они собраны. Это может вызывать проблемы при разработке.

Подробнее об этих фреймоврках и интеграции в Swift Package Manager в [видео Distribute binary frameworks as Swift Packages](https://developer.apple.com/wwdc20/10147) и [документации о Binary Frameworks](https://developer.apple.com/documentation/swift_packages/distributing_binary_frameworks_as_swift_packages)

## Интеграция пакетов и сборка на CI

### Внешние пакеты внутри приложения

Пакеты можно добавлять через `File` > `Swift Packages`. Поиск по `url` пакета. Пакет скачается и попробует построить дерево совместимости.

![](/swiftpm/dependencies.png)

`swift package` умеет создавать, собирать и запускать модули. Поставляется вместе с Xcode.

На CI пакеты резолвятся автоматически при начале сборки, и дополнительных действий делать не нужно.

### Модульное приложение на Swift Package Manager

**Модули** выделять стало намного проще. `File` > `New` > `Swift Package`. Добавляя его в репозиторий и проект - появляется понятная структура. Она повторяет файлы внутри, в отличие от обычных проектов. Генерируется папка тестов, автоматом считывается Scheme для билда и тестирования пакета. Зависимости такого модуля можно объявить в Package.swift

## Структура пакетов

1 репозиторий = коллекция пакетов.

**Executable** — cli. Удобно разрабатывать с любыми пакетами, которые тоже поддерживают SwiftPM. [swift-argument-parser](https://github.com/apple/swift-argument-parser) — мощь.

К сожалению, использовать с SPM SwiftGen/R.swift и любые другие CLI, как это было с Cocoapods - не получится. Валидные решения такие:

- положить бинарь с утилитой в код проекта и запускать внутри. Будет не очень удобно обновляться, но все остальные удобства останутся.
- использовать Brewfile/Gemfile для контроля зависимостей. Будет удобно обновлять, но нужно запускать перед билдом brew install/bundle install

**Library** — библиотека. Может быть как статической, так и динамической.

## Как удобно разрабатывать

### Файловая структура пакета

Внутри репозитория пакета можно собрать такую иерархию файлов:

- 📁 Project (git repo)
  - 📄 Package.swift
  - 📄 Package.resolved
  - 📄 README.md
  - 📁 Sources
    - 📁 Helpers
    - 📁 BigModule
  - 📁 Tests
    - 📁 BigModuleTests (folder)
  - 📁 Example
    - Example.xcodeproj
    - ... any structure of example project
  - 📄 Packages.xcworkspace
  - Packages.playground (еще не пробовал, но должно тоже работать)

xcworkspace файл объединит в себе две группы

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
    location = "group:.">
   </FileRef>
   <FileRef
      location = "group:Example/Example.xcodeproj">
   </FileRef>
</Workspace>
```

В таком случае xcworkspace повторяет всю структуру папок, при этом имея все схемы для сборки пакетов + схему для сборки Example проекта.

К сожалению, иногда приходится закрыть-открыть workspace. Обычно это проблемы со схемами или резолвом пакетов.

**Kontur**: мы используем такую иерархию в packages-ios.

### Package.swift

`// swift-tools-version:5.3` - актуальная версия тулзов. Актуальная фича в этой версии - process/copy ресурсов.

[API Reference swift.org](https://docs.swift.org/package-manager/PackageDescription/index.html) — место, где можно посмотреть документацию к каждому вызову внутри Package.swift

Про отличие static и dynamic библиотек можно почитать [в блоге theswiftdev](https://theswiftdev.com/deep-dive-into-swift-frameworks/).

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "SimplePackage",
  platforms: [
    .iOS(.v11) // поддерживает только iOS с версии 11
  ],
  products: [
    .library(
      name: "Helpers",
      targets: ["Helpers"]
    ),
    .library(
      name: "BigModule",
      targets: ["BigModule"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "3.3.3")),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
    .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0.0")
  ],
  targets: [
    .target(
      name: "Helpers",
      dependencies: ["PhoneNumberKit"]
    ),
    .target(
      name: "BigModule",
      dependencies: [
        .product(name: "FirebaseRemoteConfig", package: "Firebase"),
        "RxSwift",
        .product(name: "RxCocoa", package: "RxSwift")
      ],
      resources: [.process("Resources")] // Resources — папка в Sources/BigModule
    ),
    .testTarget(
      name: "BigModuleTests",
      dependencies: ["BigModule"]
    ),
  ]
)

```

### Релизы

Релизы легче, чем в cocoapods, так как централизованного хранилища версий необходимости держать нет. Просто добавляем тег версии по [semver](semver.org), и пакеты готовы к обновлению.

Если хочется выложить пакет в общий доступ и позволить пользователям искать его в общем списке — посмотри на [Swift Package Index](https://swiftpackageindex.com).

## Как решать проблемы

Пакеты начинают резолвиться при открытии Xcode проекта. Если удалить пакеты, то они пропадут и билд не будет их видеть. Тогда нужно воспользоваться меню `File` > `Swift Packages` > `Resolve Package Versions`

**Проблемы кэширования** решаются удалением кэша 😀 Ссылка на него лежит в `~/.swiftpm/cache`. Оригинал лежит в `~/Library/Caches/org.swift.swiftpm`. Рядом с кэшем Cocoapods.

**Проблема совместимости** с тем, что модули не подходят друг другу решается вручную. Как, например, если мы поставим [RxSwift](https://github.com/ReactiveX/RxSwift) 6.0.0+ и последнюю версию [Moya](https://github.com/Moya/Moya/releases/tag/14.0.1), которая работает с RxSwift 5.0.0+. Тогда нужно явно указать, что версия RxSwift необходима старая. Автоматически это не решится, но лог пишется понятный.

![](/swiftpm/versions.png)

**Проблема с разными версиями одного пакета**

```text
Dependencies could not be resolved because root depends on 'Moya' 14.0.1..<15.0.0 and root depends on 'Quick' 4.0.0..<5.0.0.
'Moya' >= 14.0.1 practically depends on 'Quick' 2.0.0..<3.0.0 because 'Moya' 14.0.1 depends on 'Quick' 2.0.0..<3.0.0 and no versions of 'Moya' match the requirement 14.0.2..<15.0.0.
```

Не вижу возможного решения в текущей версии, так как Package.swift нельзя выделить отдельно. Думал о том, чтобы Quick с версией другой имел название библиотеки вроде `Quick-4`, и тогда бы не должна была ломаться связка. Но как такое решить с текущей интеграцией Xcode - не понятно.

Валидные решения на сейчас:

- выпилить Quick из тестов :)
- обновить Moya в отдельном репозитории. Версия 15 с поддержкой RxSwift давно готова. Но её не выпускают непонятно почему. Скорее всего, проблема в документации.

## Полезные ссылки

[Обзор по SwiftPM от Apple](https://swift.org/package-manager/)

[Документация по API SwiftPM в Package.swift файле](https://docs.swift.org/package-manager/)

[Видео WWDC про Swift Packages](https://developer.apple.com/videos/developer-tools/swift?q=package)

[Публичный список доступных пакетов в SwiftPM](https://swiftpackageindex.com)

## UPD: 12.2021

Всё ещё очень долго происходит загрузка пакетов при открытии проекта в Xcode. Если подряд открыть проект несколько раз — то и загрузка будет происходить каждый из этих раз. Это может занимать очень много времени. В Cocoapods же можно было не обновлять и не подтягивать каждый раз пакеты.
