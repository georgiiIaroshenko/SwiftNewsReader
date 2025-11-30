import UIKit

struct ButtonConfig {
    var contentMode: UIView.ContentMode
    var clipsToBounds: Bool
    var cornerRadius: CGFloat?
    var backgroundColor: UIColor?
    var tintColor: UIColor?
    var contentInsets: NSDirectionalEdgeInsets?
    
    init(contentMode: UIView.ContentMode = .scaleAspectFill,
         clipsToBounds: Bool = true,
         cornerRadius: CGFloat? = nil,
         backgroundColor: UIColor? = nil,
         tintColor: UIColor? = nil,
         contentInsets: NSDirectionalEdgeInsets? = nil) {
        self.contentMode = contentMode
        self.clipsToBounds = clipsToBounds
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.contentInsets = contentInsets
    }
}

final class ButtonFactory {
    @discardableResult
    func make(_ config: ButtonConfig = .init()) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        
        if let bg = config.backgroundColor {
            configuration.baseBackgroundColor = bg
        }
        if let tint = config.tintColor {
            configuration.baseForegroundColor = tint
        }
        
        if let insets = config.contentInsets {
            configuration.contentInsets = insets
        }
        
        if let radius = config.cornerRadius {
            configuration.cornerStyle = .fixed
            configuration.background.cornerRadius = radius
        }
        
        let button = UIButton(configuration: configuration)
        button.contentMode = config.contentMode
        button.clipsToBounds = config.clipsToBounds
        
        return button
    }
}

