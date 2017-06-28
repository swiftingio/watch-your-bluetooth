import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var name: WKInterfaceLabel!
    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var image: WKInterfaceImage!
    
    let central: BirdCentral = BirdCentral()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        central.delegate = self
    }
    
}

extension InterfaceController: BirdCentralDelegate {
    func central(_ central: BirdCentral, didPerformAction action: BirdCentral.Action) {
        switch action {
        case .read(let value):
            update(value)
        case .connectPeripheral(_):
            label.setText("connected")
        case .disconnectPeripheral:
            label.setText("disconnected")
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
