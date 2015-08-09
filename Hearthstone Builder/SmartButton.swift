import UIKit

class SmartButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    }
}
