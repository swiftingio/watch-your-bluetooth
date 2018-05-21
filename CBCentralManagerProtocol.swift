import CoreBluetooth

public protocol CBCentralManagerProtocol: class {
    var delegate: CBCentralManagerDelegate? { get set }
    var state: CBManagerState { get }
    func stopScan()
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral]
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral]
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?)
    func connect(_ peripheral: CBPeripheral, options: [String : Any]?)
    func connect(_ peripheral: CBPeripheralProtocol, options: [String: Any]?)
    func cancelPeripheralConnection(_ peripheral: CBPeripheral)
}

extension CBCentralManager: CBCentralManagerProtocol {
    public func retrievePeripheral(withIdentifier identifier: UUID) -> CBPeripheralProtocol? {
        let peripherals: [CBPeripheral] =
            retrievePeripherals(withIdentifiers: [identifier])
        return peripherals.first
    }
    
    public func retrieveConnectedPeripherals(withServices services: [CBUUID]) -> [CBPeripheralProtocol] {
        let peripherals: [CBPeripheral] = retrieveConnectedPeripherals(withServices: services)
        // Force the array copy to avoid error: array cannot be bridged from Objective-C
        return peripherals.map { $0 as CBPeripheralProtocol }
    }
    
    public func connect(_ peripheral: CBPeripheralProtocol, options: [String: Any]?) {
        guard let corePeripheral = peripheral as? CBPeripheral else {
            fatalError("Called CBCentralManager with a mocked peripheral")
        }
        
        connect(corePeripheral, options: options)
    }
    
    public func cancelPeripheralConnection(_ peripheral: CBPeripheralProtocol) {
        guard let corePeripheral = peripheral as? CBPeripheral else {
            fatalError("Called CBCentralManager with a mocked peripheral")
        }
        
        cancelPeripheralConnection(corePeripheral)
    }
}
