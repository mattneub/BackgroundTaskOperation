

import UIKit

// this is the actual class; everything else is just a test bed,
// exercising it under various operation aspects

class BackgroundTaskOperation: Operation {
    var whatToDo : (() -> ())?
    var cleanup : (() -> ())?
    override func main() {
        guard !self.isCancelled else { print("oops, cancelled"); return }
        guard let whatToDo = self.whatToDo else { return }
        guard !Thread.isMainThread else { fatalError("must be called in background!")}
        // boilerplate
        print("start", self)
        var bti : UIBackgroundTaskIdentifier = .invalid
        bti = UIApplication.shared.beginBackgroundTask {
            self.cleanup?()
            print("premature cleanup", self)
            UIApplication.shared.endBackgroundTask(bti) // cancellation
        }
        guard bti != .invalid else { return }
        whatToDo()
        print("end", self)
        UIApplication.shared.endBackgroundTask(bti) // completion
    }
    func doOnMainQueueAndBlockUntilFinished(_ f:@escaping ()->()) {
        OperationQueue.main.addOperations([BlockOperation(block: f)], waitUntilFinished: true)
    }
}
