import Foundation

open class AsyncOperation: Operation {

    private var _finished = false
    private var _executing = false
    private var _cancelled = false

    open override var isAsynchronous: Bool {
        return true
    }

    open override var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    open override var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    open override var isCancelled: Bool {
        get { return _cancelled }
        set {
            willChangeValue(forKey: "isCancelled")
            _cancelled = newValue
            didChangeValue(forKey: "isCancelled")
        }
    }
}
