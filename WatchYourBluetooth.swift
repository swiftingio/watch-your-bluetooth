import CoreBluetooth










enum BirdService {
    static let uuid: CBUUID = CBUUID(string: "B7AC06DC-09FF-40ED-B03A-55D09B08EB4A")
    static let colorCharacteristicUUID: CBUUID = CBUUID(string: "B7AC06DC-09FF-40ED-B03A-55D09B080001")
    static let nameCharacteristicUUID: CBUUID = CBUUID(string: "B7AC06DC-09FF-40ED-B03A-55D09B080002")
    static let alphaCharacteristicUUID: CBUUID = CBUUID(string: "B7AC06DC-09FF-40ED-B03A-55D09B080003")
    
    static let characteristics: [CBUUID] = [
        colorCharacteristicUUID,
        nameCharacteristicUUID,
        alphaCharacteristicUUID,
        ]
}











#if !os(macOS)
    import UIKit
    
    
    
    
    
    
    
    
    
    
    
    
    extension UIColor {
        
        convenience init?(hex hexString: String, alpha: Float = 1)  {
            
            guard let hex = Int(hexString, radix: 16) else { return nil }
            
            self.init(red: CGFloat((hex >> 16) & 0xff) / 255.0,
                      green: CGFloat((hex >> 08) & 0xff) / 255.0,
                      blue: CGFloat((hex >> 00) & 0xff) / 255.0,
                      alpha: CGFloat(alpha))
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    extension Data {
        
        var string: String {
            return String(data: self, encoding: String.Encoding.utf8) ?? ""
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    protocol BirdCentralDelegate: class {
        
        func central(_ central: BirdCentral, didPerformAction: BirdCentral.Action)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    class BirdCentral: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
        
        weak var delegate: BirdCentralDelegate?
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        let central: CBCentralManager
        
        override init() {
            //TODO: queue + manager
            let queue = DispatchQueue(label: "io.swifting.bluetooth")
            central = CBCentralManager(delegate: nil, queue: queue)
            
            super.init()
            
            //TODO: delegate
            central.delegate = self
            
            //TODO: scan
            scanServices()
        }
        
        func scanServices() {
            guard central.state == .poweredOn else { return }
            central.scanForPeripherals(withServices: [BirdService.uuid], options: nil)
        }
        
        
        
        
        
        
        
        
        
        
        
        //TODO: state updated
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            scanServices()
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        //TODO: peripheral found + stop + store + delegate + connect
        var peripheral: CBPeripheral?
        
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
            print(error.debugDescription)
            self.peripheral = nil
            scanServices()
            DispatchQueue.main.async {
                self.delegate?.central(self, didPerformAction: BirdCentral.Action.disconnectPeripheral)
            }
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        //TODO: services discovererd + discover characteristics
        
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            guard error == nil else { return }
            guard let service = (peripheral.services?.filter { $0.uuid == BirdService.uuid })?.first else { return }
            peripheral.discoverCharacteristics(BirdService.characteristics, for: service)
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        //TODO: characteristics discovererd + read + subscribe + store
        
        var name: CBCharacteristic?
        var color: CBCharacteristic?
        var alpha: CBCharacteristic?
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            guard error == nil else { return }
            
            service.characteristics?.forEach {
                peripheral.readValue(for: $0)
                peripheral.setNotifyValue(true, for: $0)
                switch $0.uuid {
                case BirdService.nameCharacteristicUUID:
                    name = $0
                case BirdService.alphaCharacteristicUUID:
                    alpha = $0
                case BirdService.colorCharacteristicUUID:
                    color = $0
                default:
                    return
                }
            }
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        //TODO: value updated + Main - Action.read(Value)
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            guard error == nil else { return }
            guard let string = characteristic.value?.string else { return }
            
            let response: Value
            
            switch characteristic.uuid {
            case BirdService.nameCharacteristicUUID:
                response = .name(string)
            case BirdService.alphaCharacteristicUUID:
                guard let int = Int(string) else { return }
                response = .alpha(CGFloat(int) / 100)
            case BirdService.colorCharacteristicUUID:
                guard let color = UIColor(hex: string) else { return }
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
#endif


