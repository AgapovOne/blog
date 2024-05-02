# Swift multithread utilization

https://khanlou.com/2016/04/the-GCD-handbook/

[Multithreading in iOS| Difference between GCD and NSOperation](https://medium.com/@abhimuralidharan/understanding-threads-in-ios-5b8d7ab16f09)

[All about Concurrency in Swift - Part 1: The Present](https://www.uraimo.com/2017/05/07/all-about-concurrency-in-swift-1-the-present/#dispatch-assertions)

[Многопоточность (concurrency) в Swift 3. GCD и Dispatch Queues](https://habr.com/ru/post/320152/)

https://tclementdev.com/posts/libdispatch_efficiency_tips.html

## GCD
[Ultimate Grand Central Dispatch tutorial in Swift - The.Swift.Dev.](https://theswiftdev.com/2018/07/10/ultimate-grand-central-dispatch-tutorial-in-swift/)

### Операции
Нужно сабклассить, переопределять
Операции когда нужна отмена, и блоки хорошо можно разделить

### Dispatch Group/Queue
GCD когда просто распараллелить, раскидать.

## Mutex vs Semaphore
Семафор - понижает счетчик до 0 от заданного числа, блокирует блок кода
Мьютекс - частный случай семафора (с цифрой 1), но чуть со своими прелестями. Мьютекс в своем потоке должен освободить, а семафор в любом может сигнал подать и разрешить продолжить.
Бинарный семафор - альтернатива мьютексу.

## Dispatch barrier
[https://gist.github.com/aainaj/a7ca2a98d0cd791566c46a7a7da5309d](https://www.notion.so/a7ca2a98d0cd791566c46a7a7da5309d)`async(flags: .barrier)` чтобы убрать проблему чтения-записи. Пишем через асинк с барьером, читаем через sync. Глобальная конкаррент очередь.

## Runloop
Постоянный опрос, осмотр эвентов снаружи, таймеров и уведомление всех кто нужен. для таймеров нужно привязывать к ранлупу, или юзать scheduled отдельно. [Run Loops](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)
глобальный скоуп и можно создавать локальные

Приоритет выбирается по режиму ранлупа. И чтобы при скролле таймер работал нужно использовать commonModes режим. Но только при необходимости.

[Доклад про Runloop, Антон Сергеев](https://www.youtube.com/watch?v=s8B6t5XnB7M)

## deadlock
Ситуация, когда управление между потоками передаться не может, так как каждый поток ждет заблокирован, ожидая другой поток. И разрешения ситуации не происходит.

Как повторить: вызвать метод sync на main queue, и это приведет к взаимной блокировке (deadlock) приложения

## livelock
Ситуация, когда каждый поток передает выполнение дальше в следующий поток, не делая на самом деле никакого действия.

### Thread safety (locks & barrier)
[https://swiftrocks.com/thread-safety-in-swift.html](https://swiftrocks.com/thread-safety-in-swift.html)

## Async/await
[artemnovichkov/awesome-swift-async-await: A hand-curated list of Swift async/await resources. Feel free to contribute!](https://github.com/artemnovichkov/awesome-swift-async-await)

[Modern Concurrency in Swift: Introduction • Andy Ibanez](https://www.andyibanez.com/posts/modern-concurrency-in-swift-introduction/)


## Видео

[Доклад: Повседневные асинхронность и многопоточность / Александр Терентьев](https://www.youtube.com/watch?v=0mULRVLex24&list=PLNSmyatBJig7GmFpPEr9oBiFSBai7V3dC&index=5&t=803s)
[Доклад: Устройство многопоточности в iOS / Александр Андрюхин (Авито)](https://youtu.be/GVXyrLB1tbk?si=KaRNwG2dv0W0Wj4x)


## Проблемы синхронизации:
https://github.com/KosyanMedia/aviasales-ios/pull/11712
полезное чтиво от бывшего разработчика GCD:  [https://gist.github.com/tclementdev/6af616354912b0347cdf6db159c37057](https://gist.github.com/tclementdev/6af616354912b0347cdf6db159c37057) 
свеженькое напоминание от перфоманс инженера из Apple:
 [https://twitter.com/catfish_man/status/1516909101149671424?s=21&t=Ky8qqh1u_Ex1sc_DHpYNtw](https://twitter.com/catfish_man/status/1516909101149671424?s=21&t=Ky8qqh1u_Ex1sc_DHpYNtw) 
У меня еще есть примерно десяток ссылок про это, но короче, консенсус сегодняшнего дня в том, что использование конкурентных и глобальных очередей должно триггерить ревьювера)
А как делать то?
 [Вот](https://twitter.com/catfish_man/status/1516910087092113408?s=21&t=Ky8qqh1u_Ex1sc_DHpYNtw) :
Just use a lock. Multi-reader single-writer synchronization always looks appealing, but it has a ton of subtle problems. Async writes sound appealing, but bringing up a thread is many orders of magnitude slower than setting a variable.
Ок, локи, но какие? Будь мы на iOS 16+, ответ был бы прост —  [OSAllocatedUnfairLock](https://developer.apple.com/documentation/os/osallocatedunfairlock) . Это правильная свифтовая обертка над хитрым  [os_unfair_lock](https://twitter.com/beccadax/status/1534722057916731393?s=21&t=Ky8qqh1u_Ex1sc_DHpYNtw) . os_unfair_lock просто так из Свифта не поиспользуешь,  [еще про хитрость](http://www.russbishop.net/the-law) 
Запомним OSAllocatedUnfairLock на будущее, а что пока?
 [вот](https://twitter.com/catfish_man/status/1566573552525983745?s=21&t=Ky8qqh1u_Ex1sc_DHpYNtw) 
A serial queue or an NSLock is fine
Это ответ на вопрос для тех, кто до iOS 16 еще не добрался) В целом, если снова говорить о консенсусе в коммьюнити, наш выбор состоит из: серийная очередь, своя **корректная** обертка над os_unfair_lock или NSLock. Акторы пока опускаем, не видел пока никаких рекомендаций по их использованию на низком уровне.
Серийная очередь понятно, вероятно дороже чем локи. os_unfair_lock — ну можно  [хитрую обертку затащить](https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/Locking.swift) , вероятно очень быстро получится, но что-то слишком много магии в заворачивании этого лока. NSLock — Eskimo  [пишет](https://developer.apple.com/forums/thread/712379) , что до iOS 16 нормально использовать NSLock, а обертки над os_unfair_lock скорее всего того не стоят.
Итого: до iOS 16 я предлагаю использовать NSLock, а точнее  [обертку](https://github.com/pointfreeco/isowords/blob/main/Sources/TcaHelpers/Isolated.swift)  от poinftree (неожиданно?## 😀
), над NSRecursiveLock. Рекурсивный медленнее обычного, но едва ли мы это заметим, зато поддержим какие-то сложные сценарии, что может быть актуально для библиотечной штуки. В поинтфришной обертке есть хитрые оптимизации, например __read, __modify ( [про них](https://trycombine.com/posts/swift-read-modify-coroutines/) ), если страшно, то можно убрать пока непонятные детали, но все же уйти от использования конкурентной очереди в пользу лока или хотя бы серийной очереди