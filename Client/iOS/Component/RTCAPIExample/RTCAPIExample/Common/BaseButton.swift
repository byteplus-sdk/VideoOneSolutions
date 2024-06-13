import UIKit

class BaseButton: UIButton {

    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor(red: 22/255, green: 100/255, blue: 255/255, alpha: 1.0)
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
