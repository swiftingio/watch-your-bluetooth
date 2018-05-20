import CoreBluetooth

protocol CBServiceProtocol {
    var peripheral: CBPeripheral { get }
    var isPrimary: Bool { get }
    var includedServices: [CBService]? { get }
    var characteristics: [CBCharacteristic]? { get }
}

extension CBService: CBServiceProtocol {}
