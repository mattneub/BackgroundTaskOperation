
import UIKit

class BackgroundTaskOperationTest : BackgroundTaskOperation {
    override func cancel() {
        print("my cancel was called", self)
        super.cancel()
    }
    deinit {
        print("farewell from", self)
    }
}

let backgroundTaskQueue : OperationQueue = {
    let q = OperationQueue()
    q.maxConcurrentOperationCount = 1
    return q
}()

func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        backgroundTaskQueue.cancelAllOperations()
        let task = BackgroundTaskOperationTest()
        task.whatToDo = { [weak task] in
            guard let task = task else {return}
            print("here goes nothing", task)
            // time-consuming stuff
            print(1, task)
            for i in 1...10000 {
                guard !task.isCancelled else {
                    print("cancelled, interrupting", task as Any)
                    return
                }
                func dummy(_ : Any) {}
                for j in 1...150000 {
                    let k = i*j
                    dummy(k)
                }
            }
            guard !task.isCancelled else {
                print("cancelled, interrupting", task as Any)
                return
            }
            task.doOnMainQueueAndBlockUntilFinished {
                let f = DateFormatter()
                f.dateFormat = "HH':'mm':'ss"
                UserDefaults.standard.set(f.string(from: Date()), forKey:"now")
                print("laid down marker on main queue")
            }
            print("finished", task)
        }
        backgroundTaskQueue.addOperation(task)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let now = UserDefaults.standard.string(forKey:"now") {
            print(now)
        } else {
            print("got nothing")
        }
    }



}

