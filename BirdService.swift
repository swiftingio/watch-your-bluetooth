import CoreBluetooth

enum BirdService {
    static let uuid: CBUUID = CBUUID(string: "B7AC06DC-09FF-40ED-B03A-55D09B08EB4A")
    static let colorCharacteristicUUID: CBUUID = CBUUID(string: "B7AC06DC-09FF-40ED-B03A-55D09B080001")
    static let nameCharacteristicUUID: CBUUID = CBUUID(string: "B7AC06DC-09FF-40ED-B03A-55D09B080002")
    static let alphaCharacteristicUUID: CBUUID = CBUUID(string: "B7AC06DC-09FF-40ED-B03A-55D09B080003")
    
    static let characteristics: [CBUUID] = [
        colorCharacteristicUUID,
        nameCharacteristicUUID,
        alphaCharacteristicUUID,
        ]
}
