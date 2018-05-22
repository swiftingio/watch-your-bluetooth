import CoreBluetooth
@testable import bluetooth_demo

class CBServiceSpy: CBServiceProtocol {
    var uuid: CBUUID = BirdService.uuid
    var isPrimary: Bool = true
    var includedServices: [CBService]? = []
    var characteristics: [CBCharacteristic]? = []
}
