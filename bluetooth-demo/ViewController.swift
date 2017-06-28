import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var connection: UILabel!
    @IBOutlet var image: UIImageView!
    
    let central: BirdCentral = BirdCentral()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        central.delegate = self
    }
}

extension ViewController: BirdCentralDelegate {
    func central(_ central: BirdCentral, didPerformAction action: BirdCentral.Action) {
        switch action {
        case .read(let value):
            update(value)
        case .connectPeripheral(_):
            connection.text = "connected"
        case .disconnectPeripheral:
            connection.text = "disconnected"
        }
    }
    
    private func update(_ value: BirdCentral.Value) {
        switch value {
        case .alpha(let extracted):
            print("alpha", extracted)
            image.alpha = extracted
        case .name(let extracted):
            print("name", extracted)
            name.text = extracted
        case .color(let extracted):
            print("color", extracted)
            image.tintColor = extracted
        }
    }
}
