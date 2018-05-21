import CoreBluetooth

protocol CBCentralManagerDelegateProtocol {
    func centralManagerDidUpdateState(_ central: CBCentralManagerProtocol)
    func centralManager(_ central: CBCentralManagerProtocol, didDiscover peripheral: CBPeripheralProtocol, advertisementData: [String : Any], rssi RSSI: NSNumber)
    func centralManager(_ central: CBCentralManagerProtocol, didFailToConnect peripheral: CBPeripheralProtocol, error: Error?)
    func centralManager(_ central: CBCentralManagerProtocol, didConnect peripheral: CBPeripheralProtocol)
    func centralManager(_ central: CBCentralManagerProtocol, didDisconnectPeripheral peripheral: CBPeripheralProtocol, error: Error?)
}
