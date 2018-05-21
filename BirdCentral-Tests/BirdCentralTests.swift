import XCTest
@testable import bluetooth_demo

class BirdCentralTests: XCTestCase {
    
    var sut: BirdCentral!
    var centralManager: CBCentralManagerSpy!
    
    var peripheral: CBPeripheralProtocol!
    var birdService: CBServiceProtocol!
    var nameCharacteristic: CBCharacteristicProtocol!
    var alphaCharacteristic: CBCharacteristicProtocol!
    var colorCharacteristic: CBCharacteristicProtocol!
    var delegate: BirdCentralDelegate!

    override func setUp() {
        super.setUp()
        centralManager = CBCentralManagerSpy()
        sut = BirdCentral(centralManager: centralManager)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    
    func test() {
        XCTFail("Implement all tests")
    }
}
