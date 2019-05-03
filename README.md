# BackgroundTaskOperation

In iOS, you should use a background task for any time-consuming operation whose completion you want to ensure in case the app goes into the background. Therefore your code is likely to end up peppered with repetitions of the same boilerplate code for calling `beginBackgroundTask` and `endBackgroundTask` coherently.

To prevent this repetition, it is reasonable to package up the boilerplate into some single encapsulated entity. I think the best way is to use an Operation subclass:

* You can enqueue the Operation onto any OperationQueue and manipulate that queue as you see fit. For example, you are free to cancel prematurely any existing operations on the queue.

* If you have more than one thing to do, you can chain multiple background task Operations. Operations support dependencies.

* The Operation Queue can (and should) be a background queue; thus, there is no need to worry about performing asynchronous code inside your task, because the Operation _is_ the asynchronous code. (Indeed, it makes no sense to execute _another_ level of asynchronous code inside an Operation, as the Operation would finish before that code could even start. If you needed to do that, you'd use another Operation.)

This project demonstrates an implementation for such an Operation.

### How to use

We'll need a background operation queue:

```
let backgroundTaskQueue : OperationQueue = {
    let q = OperationQueue()
    q.maxConcurrentOperationCount = 1
    return q
}()
```

Then for a typical time-consuming batch of code we would say:

    let task = BackgroundTaskOperation()
    task.whatToDo = {
        // do something here
    }
    backgroundTaskQueue.addOperation(task)

In case you have cleanup to do when the background task itself is cancelled prematurely, I've also provided an optional `cleanup` handler property.
