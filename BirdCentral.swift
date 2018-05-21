import CoreBluetooth
import UIKit

protocol BirdCentralDelegate: class {
    func central(_ central: BirdCentral, didPerformAction: BirdCentral.Action)
}

class BirdCentral: NSObject {
    
    weak var delegate: BirdCentralDelegate?
    
    var name: String {
        return nameCharacteristic?.value?.string ?? "Bird"
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

extension BirdCentral {
    
    //TODO: scan
    
    func scanServices() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [BirdService.uuid], options: nil)
    }
    
    //TODO: read values
    
    func readValues() {
        birdService?.characteristics?.forEach {
            peripheral?.readValue(for: $0)
        }
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
    
    //TODO: peripheral found + stop + store + delegate + connect
    
    func centralManager(_ central: CBCentralManagerProtocol, didDiscover peripheral: CBPeripheralProtocol, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        central.stopScan()
        self.peripheral = peripheral
        peripheral.delegate = self
        central.connect(peripheral, options: nil)
    }
    
    //TODO: failed + un-store + scan + Main - Action.connectPeripheral(true)
    
    func centralManager(_ central: CBCentralManagerProtocol, didFailToConnect peripheral: CBPeripheralProtocol, error: Error?) {
        print(error.debugDescription)
        self.peripheral = nil
        scanServices()
        DispatchQueue.main.async {
            self.delegate?.central(self, didPerformAction: Action.connectPeripheral(false))
        }
    }
    
    //TODO: connected: discover services + Main - Action.connectPeripheral(false)
    
    func centralManager(_ central: CBCentralManagerProtocol, didConnect peripheral: CBPeripheralProtocol) {
        peripheral.delegate = self
        peripheral.discoverServices([BirdService.uuid])
        DispatchQueue.main.async {
            self.delegate?.central(self, didPerformAction: Action.connectPeripheral(true))
        }
    }
    
    //TODO: disconnected + un-store + scan + Main - Action.disconnectPeripheral(Bool)
    
    func centralManager(_ central: CBCentralManagerProtocol, didDisconnectPeripheral peripheral: CBPeripheralProtocol, error: Error?) {
        
        guard let error = error else { return }
        print("DISCONNECTED ", peripheral, error)
        reset()
        DispatchQueue.main.async {
            self.delegate?.central(self, didPerformAction: BirdCentral.Action.disconnectPeripheral)
        }
        scanServices()
    }
    
    //TODO: reset
    
    private func reset() {
        peripheral = nil
        birdService = nil
        nameCharacteristic = nil
        alphaCharacteristic = nil
        colorCharacteristic = nil
    }
    
}


extension BirdCentral: CBPeripheralDelegateProtocol {
    
    //TODO: services discovererd + discover characteristics
    
    func peripheral(_ peripheral: CBPeripheralProtocol, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        guard let service = (peripheral.services?.filter { $0.uuid == BirdService.uuid })?.first else { return }
        peripheral.discoverCharacteristics(BirdService.characteristics, for: service)
    }
    
    //TODO: characteristics discovererd + read + subscribe + store
    
    func peripheral(_ peripheral: CBPeripheralProtocol, didDiscoverCharacteristicsFor service: CBServiceProtocol, error: Error?) {
        guard error == nil else { return }
        birdService = service
        service.characteristics?.forEach {
            peripheral.readValue(for: $0)
            peripheral.setNotifyValue(true, for: $0)
            switch $0.uuid {
            case BirdService.nameCharacteristicUUID:
                nameCharacteristic = $0
            case BirdService.alphaCharacteristicUUID:
                alphaCharacteristic = $0
            case BirdService.colorCharacteristicUUID:
                colorCharacteristic = $0
            default:
                return
            }
        }
    }
    
    //TODO: value updated + Main - Action.read(Value)
    
    func peripheral(_ peripheral: CBPeripheralProtocol, didUpdateValueFor characteristic: CBCharacteristicProtocol, error: Error?) {
        guard error == nil else { return }
        
        let response: Value
        
        switch characteristic.uuid {
        case BirdService.nameCharacteristicUUID:
            response = .name(name)
        case BirdService.alphaCharacteristicUUID:
            response = .alpha(alpha)
        case BirdService.colorCharacteristicUUID:
            response = .color(color)
        default:
            return
        }
        DispatchQueue.main.async {
            self.delegate?.central(self, didPerformAction: .read(response))
        }
    }
}

extension BirdCentral {
    
    //TODO: return a `BirdCentral` with queue and centralManager

    class func create() -> BirdCentral {
        let queue = DispatchQueue(label: "io.swifting.bluetooth")
        let centralManager = CBCentralManager(delegate: nil, queue: queue)
        let central = BirdCentral(centralManager: centralManager)
        return central
    }
    
}
