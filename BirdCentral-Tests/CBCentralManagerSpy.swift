import CoreBluetooth

class CBCentralManagerSpy: NSObject, CBCentralManagerProtocol {
    var delegate: CBCentralManagerDelegate?
    var state: CBManagerState = .poweredOff
    func stopScan() {}
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] { return [] }
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral] { return [] }
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {}
    func connect(_ peripheral: CBPeripheral, options: [String : Any]?) {}
    func connect(_ peripheral: CBPeripheralProtocol, options: [String: Any]?) {}
    func cancelPeripheralConnection(_ peripheral: CBPeripheral) {}
}
