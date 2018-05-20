import CoreBluetooth

public protocol CBPeripheralProtocol: class {
    var delegate: CBPeripheralDelegate? { get set }
    var name: String? { get }
    var rssi: NSNumber? { get }
    var state: CBPeripheralState { get }
    var services: [CBService]? { get }
    var identifier: UUID { get }

    func discoverServices(_: [CBUUID]?)
    func discoverCharacteristics(_: [CBUUID]?, for: CBService)
    func readValue(for: CBCharacteristic)
    func writeValue(_: Data, for: CBCharacteristic, type: CBCharacteristicWriteType)
    func setNotifyValue(_: Bool, for: CBCharacteristic)
}

extension CBPeripheral: CBPeripheralProtocol {}
