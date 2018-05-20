import CoreBluetooth
import UIKit

protocol BirdCentralDelegate: class {
    
    func central(_ central: BirdCentral, didPerformAction: BirdCentral.Action)
    
}

class BirdCentral: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    weak var delegate: BirdCentralDelegate?
    fileprivate let centralManager: CBCentralManagerProtocol
    
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
    
    init(centralManager: CBCentralManagerProtocol) {
        self.centralManager = centralManager
        super.init()
        centralManager.delegate = self
    }
    
    //TODO: scan

    func scanServices() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [BirdService.uuid], options: nil)
    }
    
    //TODO: state updated
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        scanServices()
    }
    
    //TODO: peripheral found + stop + store + delegate + connect
    
    fileprivate  var peripheral: CBPeripheralProtocol?
   
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        central.stopScan()
        self.peripheral = peripheral
        peripheral.delegate = self
        central.connect(peripheral, options: nil)
    }
    
    
    //TODO: failed + un-store + scan + Main - Action.connectPeripheral(true)
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error.debugDescription)
        self.peripheral = nil
        scanServices()
        DispatchQueue.main.async {
            self.delegate?.central(self, didPerformAction: Action.connectPeripheral(false))
        }
    }
    
    //TODO: connected: discover services + Main - Action.connectPeripheral(false)
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([BirdService.uuid])
        DispatchQueue.main.async {
            self.delegate?.central(self, didPerformAction: Action.connectPeripheral(true))
        }
    }
    
    //TODO: disconnected + un-store + scan + Main - Action.disconnectPeripheral(Bool)
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let error = error else { return }
        print("DISCONNECTED ", peripheral, error)
        reset()
        DispatchQueue.main.async {
            self.delegate?.central(self, didPerformAction: BirdCentral.Action.disconnectPeripheral)
        }
        scanServices()
    }
    
    var birdService: CBServiceProtocol?
    
    func reset() {
        peripheral = nil
        birdService = nil
        nameCharacteristic = nil
        alphaCharacteristic = nil
        colorCharacteristic = nil
    }
    
    //TODO: services discovererd + discover characteristics
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        guard let service = (peripheral.services?.filter { $0.uuid == BirdService.uuid })?.first else { return }
        peripheral.discoverCharacteristics(BirdService.characteristics, for: service)
    }
    
    //TODO: characteristics discovererd + read + subscribe + store
    
    fileprivate var nameCharacteristic: CBCharacteristicProtocol?
    fileprivate var colorCharacteristic: CBCharacteristicProtocol?
    fileprivate var alphaCharacteristic: CBCharacteristicProtocol?
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
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
    
    func readValues() {
        birdService?.characteristics?.forEach {
            peripheral?.readValue(for: $0)
        }
    }
    
    //TODO: value updated + Main - Action.read(Value)
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
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

extension BirdCentral {
    class func create() -> BirdCentral {
        //TODO: queue and centralManager
        let queue = DispatchQueue(label: "io.swifting.bluetooth")
        let centralManager = CBCentralManager(delegate: nil, queue: queue)
        let central = BirdCentral(centralManager: centralManager)
        return central
    }
}
