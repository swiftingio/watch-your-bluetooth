import CoreBluetooth

protocol CBServiceProtocol: CBAttributeProtocol {
    var isPrimary: Bool { get }
    var includedServices: [CBService]? { get }
    var characteristics: [CBCharacteristic]? { get }
}

extension CBService: CBServiceProtocol {}
