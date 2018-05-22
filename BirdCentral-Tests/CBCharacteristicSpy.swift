import CoreBluetooth
@testable import bluetooth_demo

class CBCharacteristicSpy: CBCharacteristicProtocol {
    var uuid: CBUUID = CBUUID()
    var properties: CBCharacteristicProperties = [.read, .write, .notify]
    var value: Data? {
        return stubbedValue?.data(using: .utf8, allowLossyConversion: false)
    }
    var descriptors: [CBDescriptor]?
    var isNotifying: Bool = false
    var stubbedValue: String?
}
