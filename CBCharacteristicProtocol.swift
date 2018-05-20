import CoreBluetooth

protocol CBCharacteristicProtocol {
    var service: CBService { get }
    var properties: CBCharacteristicProperties { get }
    var value: Data? { get }
    var descriptors: [CBDescriptor]? { get }
    var isNotifying: Bool { get }
}

extension CBCharacteristic: CBCharacteristicProtocol {}
