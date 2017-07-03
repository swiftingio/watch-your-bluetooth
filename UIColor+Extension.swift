import UIKit

extension UIColor {
    
    convenience init?(hex hexString: String, alpha: Float = 1)  {
        
        guard let hex = Int(hexString, radix: 16) else { return nil }
        
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255.0,
                  green: CGFloat((hex >> 08) & 0xff) / 255.0,
                  blue: CGFloat((hex >> 00) & 0xff) / 255.0,
                  alpha: CGFloat(alpha))
        
    }
    
}
