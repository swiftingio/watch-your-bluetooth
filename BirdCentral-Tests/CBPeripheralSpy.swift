import CoreBluetooth
@testable import bluetooth_demo

class CBPeripheralSpy: CBPeripheralProtocol {
    var delegate: CBPeripheralDelegate?
    var name: String?
    var rssi: NSNumber?
    var state: CBPeripheralState = .disconnected
    var services: [CBService]?
    var identifier: UUID = UUID()
    
    var discoverServicesCalled: Bool = false
    var discoverServicesArgument: [CBUUID]?
    func discoverServices(_ services: [CBUUID]?) {
        discoverServicesCalled = true
        discoverServicesArgument = services
    }
    var discoverCharacteristicsArgumentCharacteristics:[CBUUID]?
    var discoverCharacteristicsArgumentService:CBService?
    func discoverCharacteristics(_ characteristics:[CBUUID]?, for service: CBService) {
        discoverCharacteristicsArgumentCharacteristics = characteristics
        discoverCharacteristicsArgumentService = service
    }
    
    var readValueArguments: [CBCharacteristic] = []
    func readValue(for characteristic: CBCharacteristic) {
        readValueArguments.append(characteristic)
    }
    
    func writeValue(_: Data, for: CBCharacteristic, type: CBCharacteristicWriteType) {
        
    }
    
    var setNotifyValueArguments: [CBCharacteristic] = []
    func setNotifyValue(_: Bool, for characteristic: CBCharacteristic) {
        setNotifyValueArguments.append(characteristic)
    }
}
