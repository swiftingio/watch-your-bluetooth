import CoreBluetooth
import UIKit























class BirdCentral: NSObject {
    
    weak var delegate: BirdCentralDelegate?
    let centralManager: CBCentralManagerProtocol
    
    init(centralManager: CBCentralManagerProtocol) {
        self.centralManager = centralManager
        super.init()
        centralManager.delegate = self
    }
    
    var peripheral: CBPeripheralProtocol?
    var birdService: CBServiceProtocol?
    var nameCharacteristic: CBCharacteristicProtocol?
    var colorCharacteristic: CBCharacteristicProtocol?
    var alphaCharacteristic: CBCharacteristicProtocol?
    
}





















protocol BirdCentralDelegate: class {
    
    func central(_ central: BirdCentral, didPerformAction: BirdCentral.Action)
    
    //ViewController -> iOS
    //InterfaceController -> watchOS
}






















extension BirdCentral {
    
    enum Action {
        case connectPeripheral(Bool)
        case disconnectPeripheral
        case read(Value)
    }
    
    enum Value {
        case name(String)
        case alpha(CGFloat)
        case color(UIColor)
    }
    
}

























extension BirdCentral: CBCentralManagerDelegateProtocol {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    //TODO: state updated
    
    func centralManagerDidUpdateState(_ central: CBCentralManagerProtocol) {
        
        scanServices()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    //TODO: scan
    
    func scanServices() {
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //TODO: peripheral found: stop + store + connect
    
    func centralManager(_ central: CBCentralManagerProtocol, didDiscover peripheral: CBPeripheralProtocol, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //TODO: failed: un-store + scan + Main -> Action.connectPeripheral
    
    func centralManager(_ central: CBCentralManagerProtocol, didFailToConnect peripheral: CBPeripheralProtocol, error: Error?) {
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //TODO: connected: discover services + delegate + Main -> Action.connectPeripheral
    
    func centralManager(_ central: CBCentralManagerProtocol, didConnect peripheral: CBPeripheralProtocol) {
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //TODO: disconnected: reset + scan + Main -> Action.disconnectPeripheral
    
    func centralManager(_ central: CBCentralManagerProtocol, didDisconnectPeripheral peripheral: CBPeripheralProtocol, error: Error?) {
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    private func reset() {
        //TODO: set to nil
    }
    
}
























extension BirdCentral: CBPeripheralDelegateProtocol {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //TODO: services discovererd: store + discover characteristics
    
    func peripheral(_ peripheral: CBPeripheralProtocol, didDiscoverServices error: Error?) {
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //TODO: characteristics discovererd: read + subscribe + store
    
    func peripheral(_ peripheral: CBPeripheralProtocol, didDiscoverCharacteristicsFor service: CBServiceProtocol, error: Error?) {
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //TODO: value updated: + Main -> Action.read
    
    func peripheral(_ peripheral: CBPeripheralProtocol, didUpdateValueFor characteristic: CBCharacteristicProtocol, error: Error?) {
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}

extension BirdCentral {
    
    var name: String {
        return nameCharacteristic?.value?.string ?? "Birdy"
    }
    
    var alpha: CGFloat {
        let string = alphaCharacteristic?.value?.string ?? ""
        guard let int = Int(string)
            else { return 0 }
        return CGFloat(int) / 100
    }
    
    var color: UIColor {
        let string = colorCharacteristic?.value?.string ?? ""
        return UIColor(hex: string) ?? .black
    }
    
    var isConnected: Bool {
        return peripheral?.state ?? .disconnected == .connected
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func readValues() {
        birdService?.characteristics?.forEach {
            peripheral?.readValue(for: $0)
        }
    }
    
    class func create() -> BirdCentral! {
        let queue = DispatchQueue(label: "io.swifting.bluetooth")
        let centralManager = CBCentralManager(delegate: nil, queue: queue)
        let central = BirdCentral(centralManager: centralManager)
        return central
    }
    
}






















extension BirdCentral: CBCentralManagerDelegate {
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        
        let delegate = (self as CBCentralManagerDelegateProtocol)
        delegate.centralManagerDidUpdateState(central)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let delegate = (self as CBCentralManagerDelegateProtocol)
        delegate.centralManager(central, didDiscover: peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let delegate = (self as CBCentralManagerDelegateProtocol)
        delegate.centralManager(central, didFailToConnect: peripheral, error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let delegate = (self as CBCentralManagerDelegateProtocol)
        delegate.centralManager(central, didConnect: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let delegate = (self as CBCentralManagerDelegateProtocol)
        delegate.centralManager(central, didDisconnectPeripheral: peripheral, error: error)
    }
    
}























extension BirdCentral: CBPeripheralDelegate {
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        
        let delegate = (self as CBPeripheralDelegateProtocol)
        delegate.peripheral(peripheral, didDiscoverServices: error)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let delegate = (self as CBPeripheralDelegateProtocol)
        delegate.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let delegate = (self as CBPeripheralDelegateProtocol)
        delegate.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
    }
    
}






















