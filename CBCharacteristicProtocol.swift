import CoreBluetooth

protocol CBCharacteristicProtocol: CBAttributeProtocol {
    var properties: CBCharacteristicProperties { get }
    var value: Data? { get }
    var descriptors: [CBDescriptor]? { get }
    var isNotifying: Bool { get }
}

extension CBCharacteristic: CBCharacteristicProtocol {}
