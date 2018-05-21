import CoreBluetooth

protocol CBPeripheralDelegateProtocol {
    func peripheral(_ peripheral: CBPeripheralProtocol, didDiscoverServices error: Error?)
    func peripheral(_ peripheral: CBPeripheralProtocol, didDiscoverCharacteristicsFor service: CBServiceProtocol, error: Error?)
    func peripheral(_ peripheral: CBPeripheralProtocol, didUpdateValueFor characteristic: CBCharacteristicProtocol, error: Error?)
}
