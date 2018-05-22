import CoreBluetooth
@testable import bluetooth_demo

class CBCentralManagerSpy: NSObject, CBCentralManagerProtocol {
    var delegate: CBCentralManagerDelegate?
    var state: CBManagerState = .poweredOff
    var stopScanCalled: Bool = false
    func stopScan() {
        stopScanCalled = true
    }
    var retrievePeripheralsCalled: Bool = false
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] {
        retrievePeripheralsCalled = true
        return []
    }
    var retrieveConnectedPeripheralsCalled: Bool = false
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral] {
        retrieveConnectedPeripheralsCalled = true
        return []
    }
    var scanForPeripheralsCalled: Bool = false
    var scanForPeripheralsUUIDs: [CBUUID]?
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {
        scanForPeripheralsCalled = true
        scanForPeripheralsUUIDs = serviceUUIDs
    }
    var connectCBPeripheralCalled: Bool = false
    func connect(_ peripheral: CBPeripheral, options: [String : Any]?) {
        connectCBPeripheralCalled = true
    }
    var connectCBPeripheralProtocolCalled: Bool = false
    func connect(_ peripheral: CBPeripheralProtocol, options: [String: Any]?) {
        connectCBPeripheralProtocolCalled = true
    }
    var cancelPeripheralConnectionCalled: Bool = false
    func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        cancelPeripheralConnectionCalled = true
    }
}
