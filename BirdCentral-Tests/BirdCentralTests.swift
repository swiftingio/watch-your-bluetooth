import XCTest
import CoreBluetooth
@testable import bluetooth_demo

class BirdCentralTests: XCTestCase {
    
    var sut: BirdCentral!
    var centralManager: CBCentralManagerSpy!
    
    var peripheral: CBPeripheralSpy!
    var birdService: CBServiceSpy!
    var nameCharacteristic: CBCharacteristicSpy!
    var alphaCharacteristic: CBCharacteristicSpy!
    var colorCharacteristic: CBCharacteristicSpy!
    var delegate: BirdCentralDelegateSpy!
    
    override func setUp() {
        super.setUp()
        centralManager = CBCentralManagerSpy()
        sut = BirdCentral(centralManager: centralManager)
        
        peripheral = CBPeripheralSpy()
        birdService = CBServiceSpy()
        nameCharacteristic = CBCharacteristicSpy()
        alphaCharacteristic = CBCharacteristicSpy()
        colorCharacteristic = CBCharacteristicSpy()
        delegate = BirdCentralDelegateSpy()
    }
    
    override func tearDown() {
        centralManager = nil
        sut = nil
        peripheral = nil
        birdService = nil
        nameCharacteristic = nil
        alphaCharacteristic = nil
        colorCharacteristic = nil
        delegate = nil
        super.tearDown()
    }
    
    
    //MARK: Starter
    
    func testEmptyImplementationOfBirdCentral() {
        XCTAssertTrue(true, "Maciej, show the audience that app doesn't work on watchOS ⌚️ nor on iOS 📱!")
    }
    
    //MARK: Central Manager Updates State
    
    func testCentralManagerDidUpdateStateWithPoweredOn() {
        //Given:
        centralManager.state = .poweredOn
        
        //When:
        sut.centralManagerDidUpdateState(centralManager)
        
        //Then:
        XCTAssertEqual(centralManager.scanForPeripheralsUUIDs, [BirdService.uuid], "Should scan for Bird Service UUID")
        
    }
    
    func testCentralManagerDidUpdateStateWithPoweredOffOrOtherState() {
        //Given:
        centralManager.state = .poweredOff
        
        //When:
        sut.centralManagerDidUpdateState(centralManager)
        
        //Then:
        XCTAssertFalse(centralManager.scanForPeripheralsCalled, "Should not scan for peripherals")
    }
    
    //MARK: Peripheral Discovery
    
    func testCentralManagerDidDiscoverPeripheral() {
        //Given:
        //Nothing new here
        
        //When:
        sut.centralManager(centralManager, didDiscover: peripheral, advertisementData:[:], rssi: NSNumber(value: -99.0))
        
        //Then:
        XCTAssertTrue(centralManager.stopScanCalled, "Scannig for peripherals should be stopped")
        XCTAssertTrue(sut.peripheral === peripheral, "Should store the peripheral")
//        XCTAssertTrue(peripheral.delegate === sut, "Should become a delegate of the peripheral")
        XCTAssertTrue(centralManager.connectCBPeripheralProtocolCalled, "Should connect peripheral")
    }
    
    //MARK: Connection Failure
    
    func testCentralManagerDidFailToConnect() {
        //Given:
        sut.peripheral = peripheral
        sut.delegate = delegate
        centralManager.state = .poweredOn
        
        var delegateCalled = false
        delegate.delegateAction = { action in
            if case BirdCentral.Action.connectPeripheral(false) = action {
                delegateCalled = true
            }
        }
        
        //When:
        sut.centralManager(centralManager, didFailToConnect: peripheral, error: nil)
        
        //Then:
        XCTAssertNil(sut.peripheral)
        XCTAssertEqual(centralManager.scanForPeripheralsUUIDs, [BirdService.uuid], "Should scan for Bird Service UUID")
        XCTAssertTrue(delegateCalled)
    }
    
    //MARK: Peripheral Connected
    
    func testPeripheralConnected() {
        //Given:
        sut.delegate = delegate
        var delegateCalled = false
        delegate.delegateAction = { action in
            if case BirdCentral.Action.connectPeripheral(true) = action {
                delegateCalled = true
            }
        }
        
        //When:
        sut.centralManager(centralManager, didConnect: peripheral)
        
        //Then:
        XCTAssertTrue(peripheral.delegate === sut, "Should become peripheral's delegate")
        XCTAssertTrue(peripheral.discoverServicesCalled, "Should discover peripherals services")
        XCTAssertTrue(delegateCalled)
    }
    
    //MARK: Peripheral Disconnected
    
    func testPeripheralDisconnected() {
        //Given:
        sut.peripheral = peripheral
        sut.birdService = birdService
        sut.nameCharacteristic = nameCharacteristic
        sut.alphaCharacteristic = alphaCharacteristic
        sut.colorCharacteristic = colorCharacteristic
        sut.delegate = delegate
        centralManager.state = .poweredOn
        
        var delegateCalled = false
        delegate.delegateAction = { action in
            if case BirdCentral.Action.disconnectPeripheral = action {
                delegateCalled = true
            }
        }
        
        //When:
        sut.centralManager(centralManager, didDisconnectPeripheral:peripheral, error: nil)
        
        //Then:
        XCTAssertNil(sut.peripheral, "Should reset peripheral data")
        XCTAssertNil(sut.birdService, "Should reset peripheral data")
        XCTAssertNil(sut.nameCharacteristic, "Should reset peripheral data")
        XCTAssertNil(sut.alphaCharacteristic, "Should reset peripheral data")
        XCTAssertNil(sut.colorCharacteristic, "Should reset peripheral data")
        XCTAssertTrue(delegateCalled)
        XCTAssertEqual(centralManager.scanForPeripheralsUUIDs, [BirdService.uuid], "Should scan for Bird Service UUID")
    }
    
    //MARK: Services Discovery
    
    func testPeripheralDidDiscoverServices() {
        //Given:
        let service = CBMutableService(type: BirdService.uuid , primary: false)
        peripheral.services = [service]
        
        //When:
        sut.peripheral(peripheral, didDiscoverServices: nil)
        
        //Then:
        XCTAssertEqual(peripheral.discoverCharacteristicsArgumentCharacteristics, BirdService.characteristics)
        XCTAssertTrue(peripheral.discoverCharacteristicsArgumentService === service)
    }
    
    func testPeripheralDidDiscoverServicesWithError() {
        //Given:
        let service = CBMutableService(type: BirdService.uuid , primary: false)
        peripheral.services = [service]
        let error = NSError(domain: "something went wrong", code: 1, userInfo: nil)
        
        //When:
        sut.peripheral(peripheral, didDiscoverServices: error)
        
        //Then:
        XCTAssertNil(peripheral.discoverCharacteristicsArgumentCharacteristics)
        XCTAssertNil(peripheral.discoverCharacteristicsArgumentService)
    }
    
    func testPeripheralDidDiscoverCharacteristicsForService() {
        //Given:
        let nameCharacteristic = CBMutableCharacteristic(type: BirdService.nameCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        let colorCharacteristic = CBMutableCharacteristic(type: BirdService.colorCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        let alphaCharacteristic = CBMutableCharacteristic(type: BirdService.alphaCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        birdService.characteristics = [nameCharacteristic, colorCharacteristic, alphaCharacteristic]
        
        //When:
        sut.peripheral(peripheral, didDiscoverCharacteristicsFor:birdService, error: nil)
        
        //Then:
        XCTAssertNotNil(sut.nameCharacteristic, "Should store name characteristic")
        XCTAssertNotNil(sut.colorCharacteristic, "Should store color characteristic")
        XCTAssertNotNil(sut.alphaCharacteristic, "Should store alpha characteristic")
        XCTAssertNotNil(sut.birdService, "Should store service")
        XCTAssertEqual(peripheral.readValueArguments.count, 3, "Should READ values for all 3 characteristics")
        XCTAssertEqual(peripheral.setNotifyValueArguments.count, 3, "Should subscribe for value notificaitons for all 3 characteristics")
    }
    
    func testPeripheralDidDiscoverCharacteristicsForServiceWithError() {
        //Given:
        let nameCharacteristic = CBMutableCharacteristic(type: BirdService.nameCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        let colorCharacteristic = CBMutableCharacteristic(type: BirdService.colorCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        let alphaCharacteristic = CBMutableCharacteristic(type: BirdService.alphaCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        birdService.characteristics = [nameCharacteristic, colorCharacteristic, alphaCharacteristic]
        let error = NSError(domain: "something went wrong", code: 1, userInfo: nil)
        
        //When:
        sut.peripheral(peripheral, didDiscoverCharacteristicsFor:birdService, error: error)
        
        //Then:
        XCTAssertNil(sut.nameCharacteristic, "Should NOT store name characteristic")
        XCTAssertNil(sut.colorCharacteristic, "Should NOT store color characteristic")
        XCTAssertNil(sut.alphaCharacteristic, "Should NOT store alpha characteristic")
        XCTAssertNil(sut.birdService, "Should store service")
        XCTAssertEqual(peripheral.readValueArguments.count, 0, "Should NOT READ any values")
        XCTAssertEqual(peripheral.setNotifyValueArguments.count, 0, "Should NOT subscribe to any value notificaitons")
    }
    
    func testDidUpdateValueForCharacteristicName() {
        //Given:
        let characteristic = CBMutableCharacteristic(type: BirdService.nameCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        sut.delegate = delegate
        var delegateCalled = false
        delegate.delegateAction = { action in
            if case BirdCentral.Action.read(BirdCentral.Value.name(_)) = action {
                delegateCalled = true
            }
        }
        
        //When:
        sut.peripheral(peripheral, didUpdateValueFor: characteristic, error: nil)
        
        //Then:
        XCTAssertTrue(delegateCalled)
    }
    
    func testDidUpdateValueForCharacteristicAlpha() {
        //Given:
        let characteristic = CBMutableCharacteristic(type: BirdService.alphaCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        sut.delegate = delegate
        var delegateCalled = false
        delegate.delegateAction = { action in
            if case BirdCentral.Action.read(BirdCentral.Value.alpha(_)) = action {
                delegateCalled = true
            }
        }
        
        //When:
        sut.peripheral(peripheral, didUpdateValueFor: characteristic, error: nil)
        
        //Then:
        XCTAssertTrue(delegateCalled)
    }
    
    func testDidUpdateValueForCharacteristicColor() {
        //Given:
        let characteristic = CBMutableCharacteristic(type: BirdService.colorCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        sut.delegate = delegate
        var delegateCalled = false
        delegate.delegateAction = { action in
            if case BirdCentral.Action.read(BirdCentral.Value.color(_)) = action {
                delegateCalled = true
            }
        }
        
        //When:
        sut.peripheral(peripheral, didUpdateValueFor: characteristic, error: nil)
        
        //Then:
        XCTAssertTrue(delegateCalled)
    }
    
    func testDidUpdateValueForCharacteristicWithError() {
        //Given:
        let characteristic = CBMutableCharacteristic(type: BirdService.colorCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        sut.delegate = delegate
        var delegateCalled = false
        delegate.delegateAction = { action in
            delegateCalled = true
        }
        let error = NSError(domain: "something went wrong", code: 1, userInfo: nil)
        
        //When:
        sut.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        
        //Then:
        XCTAssertFalse(delegateCalled)
    }
    
    //MARK: Interface Methods

    func testNameWithNoCharacteristicValue() {
        //Given:
        sut.nameCharacteristic = nil
        
        //When:
        let value = sut.name
        
        //Then:
        XCTAssertEqual(value, "Birdy", "Should have a default name")
        
    }
    
    func testAlphaWithNoCharacteristicValue() {
        //Given:
        sut.alphaCharacteristic = nil
        
        //When:
        let value = sut.alpha
        
        //Then:
        XCTAssertEqual(value, 0, "Should have a default alpha")
        
    }
    
    func testColorWithNoCharacteristicValue() {
        //Given:
        sut.colorCharacteristic = nil
        
        //When:
        let value = sut.color
        
        //Then:
        XCTAssertEqual(value, .black, "Should have a default color")
        
    }
    
    func testName() {
        //Given:
        sut.nameCharacteristic = nameCharacteristic
        let name = "Maciej"
        nameCharacteristic.stubbedValue = name

        //When:
        let value = sut.name
        
        //Then:
        XCTAssertEqual(value, name, "Should have a name")
        
    }
    
    func testAlpha() {
        //Given:
        sut.alphaCharacteristic = alphaCharacteristic
        let alpha = "50"
        alphaCharacteristic.stubbedValue = alpha
        
        //When:
        let value = sut.alpha
        
        //Then:
        XCTAssertEqual(value, 0.5, "Should have alpha")
        
    }
    
    func testColor() {
        //Given:
        sut.colorCharacteristic = colorCharacteristic
        let color = "FF00FF"
        colorCharacteristic.stubbedValue = color

        //When:
        let value = sut.color
        
        //Then:
        XCTAssertNotNil(value, "Should have a color")
        XCTAssertNotEqual(value, .black, "Should not be black")

    }
    
    func testScanServicesWithBluetoothPoweredOn() {
        //Given:
        centralManager.state = .poweredOn
        
        //When:
        sut.scanServices()
        
        //Then:
        XCTAssertEqual(centralManager.scanForPeripheralsUUIDs, [BirdService.uuid], "Should scan for Bird Service UUID")
    }
    
    func testScanServicesWithBluetoothPoweredOffOrOtherState() {
        //Given:
        centralManager.state = .poweredOff
        
        //When:
        sut.scanServices()
        
        //Then:
        XCTAssertFalse(centralManager.scanForPeripheralsCalled, "Should not scan for peripherals")
    }
    
    func testReadValues() {
        //Given:
        sut.birdService = birdService
        let characteristic1 = CBMutableCharacteristic(type: CBUUID(), properties: [], value: nil, permissions: .readable)
        let characteristic2 = CBMutableCharacteristic(type: CBUUID(), properties: [], value: nil, permissions: .readable)
        birdService.characteristics = [characteristic1, characteristic2]
        sut.peripheral = peripheral
        
        //When:
        sut.readValues()
        
        //Then:
        XCTAssertEqual(peripheral.readValueArguments.count, 2)
    }
}
