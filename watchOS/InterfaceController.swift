import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var name: WKInterfaceLabel!
    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var image: WKInterfaceImage!
    
    let central: BirdCentral = BirdCentral.create()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        central.delegate = self
    }
    
    override func willActivate() {
        if (central.isConnected) {
            label.setText("connected")
            central.readValues()
        } else {
            label.setText("disconnected")
            central.scanServices()
        }
        image.setHidden(!central.isConnected)
    }
    
    func udpateValues(from central: BirdCentral) {
        image.setTintColor(central.color)
        image.setAlpha(central.alpha)
        name.setText(central.name)
    }
    
}

extension InterfaceController: BirdCentralDelegate {
    func central(_ central: BirdCentral, didPerformAction action: BirdCentral.Action) {
        DispatchQueue.main.async {
            switch action {
            case .read(let value):
                self.update(value)
            case .connectPeripheral(_):
                self.label.setText("connected")
            case .disconnectPeripheral:
                self.label.setText("disconnected")
                self.udpateValues(from: central)
            }
        }
    }
    
    private func update(_ value: BirdCentral.Value) {
        switch value {
        case .alpha(let extracted):
            print("alpha", extracted)
            image.setAlpha(extracted)
        case .name(let extracted):
            print("name", extracted)
            name.setText(extracted)
        case .color(let extracted):
            print("color", extracted)
            image.setTintColor(extracted)
        }
    }
}
