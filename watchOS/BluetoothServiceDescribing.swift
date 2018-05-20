import CoreBluetooth

public protocol BluetoothServiceDescribing {
    static var uuid: CBUUID { get }
    static var characteristics: [CBUUID] { get }
    static var subscribableCharacteristics: [CBUUID] { get }
}

public extension BluetoothServiceDescribing {
    static var characteristics: [CBUUID] { return [] }
    static var subscribableCharacteristics: [CBUUID] { return [] }
}
