import CoreBluetooth

public protocol CBPeripheralManagerProtocol: class {
    var delegate: CBPeripheralManagerDelegate? { get set }
    var state: CBManagerState { get }
    var isAdvertising: Bool { get }
    static func authorizationStatus() -> CBPeripheralManagerAuthorizationStatus
    func startAdvertising(_ advertisementData: [String : Any]?)
    func stopAdvertising()
    func setDesiredConnectionLatency(_ latency: CBPeripheralManagerConnectionLatency, for central: CBCentral)
    func add(_ service: CBMutableService)
    func remove(_ service: CBMutableService)
    func removeAllServices()
    func respond(to request: CBATTRequest, withResult result: CBATTError.Code)
    func updateValue(_ value: Data, for characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool
}

extension CBPeripheralManager: CBPeripheralManagerProtocol {}
