import CoreBluetooth
@testable import bluetooth_demo

class BirdCentralDelegateSpy: NSObject, BirdCentralDelegate {
    var delegateAction: ((BirdCentral.Action) -> Void)?
    func central(_ central: BirdCentral, didPerformAction action: BirdCentral.Action) {
        delegateAction?(action)
    }
}
