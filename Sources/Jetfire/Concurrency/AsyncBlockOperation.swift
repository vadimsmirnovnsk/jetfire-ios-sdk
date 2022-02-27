import Foundation

public final class AsyncBlockOperation: AsyncOperation {

    private var operationBlock: (_ completion: @escaping () -> Void) -> Void

    public init(operationBlock: @escaping (_ completion: @escaping () -> Void) -> Void) {
        self.operationBlock = operationBlock
        super.init()
    }

    public override func main() {
        self.operationBlock {
            self.isExecuting = false
            self.isFinished = true
        }
    }
}
