import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var connection: UILabel!
    @IBOutlet var image: UIImageView!
    
    let central: BirdCentral = BirdCentral.create()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        central.delegate = self
        udpateValues(from: central)
    }
    
    func udpateValues(from central: BirdCentral) {
        image.tintColor = central.color
        image.alpha = central.alpha
        name.text = central.name
    }
}

extension ViewController: BirdCentralDelegate {
    func central(_ central: BirdCentral, didPerformAction action: BirdCentral.Action) {
        DispatchQueue.main.async {
            switch action {
            case .read(let value):
                self.update(value)
            case .connectPeripheral(_):
                self.connection.text = "connected"
            case .disconnectPeripheral:
                self.connection.text = "disconnected"
                self.udpateValues(from: central)
            }
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
