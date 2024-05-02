# Swift Concurrency

## Resources: 

- 🗒️ [How async/await works internally in Swift. SwiftRocks by Bruno Rocha](http://swiftrocks.com/how-async-await-works-internally-in-swift)
- 📹 [Василий Усов — А так ли нужна Swift Modern Concurrency?](https://youtu.be/DIDoHx6KP50?si=ntBfNkoQ9gYgx6f_)
- 🗒️ ??? [Подборка материалов по swift concurrency (async/await) | JonFir](https://jonfir.github.io/posts/async-await-materials/)
- 🗒️ ??? [awesome-swift-async-await](https://github.com/artemnovichkov/awesome-swift-async-await?tab=readme-ov-file)
-  Proposals
	-  [Actors](https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md)
	-  [async/await](https://github.com/apple/swift-evolution/blob/main/proposals/0296-async-await.md)
	-  [Clarify the Execution of Non-Actor-Isolated Async Functions](https://github.com/apple/swift-evolution/blob/main/proposals/0338-clarify-execution-non-actor-async.md)
-  Docs
	-  [Sendable](https://developer.apple.com/documentation/swift/sendable)
 	-  [Task](https://developer.apple.com/documentation/swift/task)

---

[Rob](https://stackoverflow.com/users/1271826/rob) answers:
---


> tl;dr
>
> The deinit approach may not work for reasons outlined below. Manually canceling that unstructured concurrency from onDisappear is often what we have to do. The exception is .task view modifier which will cancel its tasks automatically (when combined either with structured concurrency or unstructured concurrency wrapped in a withTaskCancellationHandler).
>
> https://stackoverflow.com/questions/75799089/proper-cancellation-of-tasks-in-view-model

---

> on asyncstream subscription when deinit is never called
> 
> https://stackoverflow.com/questions/72561360/issues-with-retain-cycle-using-asyncstream-in-a-task/72581727#72581727)

---

> Bottom line, there is often little point in using [weak self] capture lists with Task objects. Use cancelation patterns instead.
> 
> https://stackoverflow.com/a/71739896/4933617