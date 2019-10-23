

import UIKit

// this is the actual class; everything else is just a test bed,
// exercising it under various operation aspects

class BackgroundTaskOperation: Operation {
    var whatToDo : (() -> ())?
    var cleanup : (() -> ())?
    override func main() {
        guard !self.isCancelled else { print("oops, cancelled"); return }
        assert(!Thread.isMainThread)
        // boilerplate
        print("start", self)
        var bti : UIBackgroundTaskIdentifier = .invalid
        bti = UIApplication.shared.beginBackgroundTask {
            print("out of time, cleaning up")
            self.cleanup?()
            print("canceling")
            self.cancel()
            print("calling endBackgroundTask")
            UIApplication.shared.endBackgroundTask(bti)
        }
        guard bti != .invalid else { return }
        whatToDo?()
        print("completed")
        guard !self.isCancelled else { return }
        print("calling endBackgroundTask")
        UIApplication.shared.endBackgroundTask(bti)
    }
    func doOnMainQueueAndBlockUntilFinished(_ f:@escaping ()->()) {
        OperationQueue.main.addOperations([BlockOperation(block: f)], waitUntilFinished: true)
    }
}
