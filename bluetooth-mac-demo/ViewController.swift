import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var alphaSlider: NSSlider?
    @IBOutlet weak var segmentedControl: NSSegmentedControl?
    @IBOutlet weak var textField: NSTextField?
    
    let colors = ["FF0000", "00FF00", "0000FF", "FEF935", "03FCFE", "FF4CFC", "A97946", "FFFFFF"]
    let peripheral = MyPeripheral()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral.startAdvertising()
        textField?.delegate = self
    }
    
    @IBAction func alphaSliderValueChanged(_ sender: NSSlider) {
        let value = sender.integerValue
        print(value)
        peripheral.setAlpha(value)
    }
    
    @IBAction func colorValueChanged(_ sender: NSSegmentedControl) {
        let value = colors[sender.indexOfSelectedItem]
        peripheral.setColor(value)
    }
}

extension ViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ notification: Notification) {
        guard let field = notification.object as? NSTextField else { return }
        peripheral.setName(field.stringValue)
    }
}
