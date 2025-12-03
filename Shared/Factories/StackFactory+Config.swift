import UIKit

struct StackConfig {
    var axis: NSLayoutConstraint.Axis
    var spacing: CGFloat
    var alignment: UIStackView.Alignment
    var distribution: UIStackView.Distribution
    var contentInsets: NSDirectionalEdgeInsets
    var isLayoutMarginsRelativeArrangement: Bool
    var margins: NSDirectionalEdgeInsets? = nil
    
    init(axis: NSLayoutConstraint.Axis = .vertical,
         spacing: CGFloat = 8,
         alignment: UIStackView.Alignment = .fill,
         distribution: UIStackView.Distribution = .fill,
         contentInsets: NSDirectionalEdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
         isLayoutMarginsRelativeArrangement: Bool = true) {
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        self.contentInsets = contentInsets
        self.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
    }
}


final class StackFactory {
    @discardableResult
    func make(_ config: StackConfig) -> UIStackView {
        let stack = UIStackView()
        stack.axis = config.axis
        stack.spacing = config.spacing
        stack.alignment = config.alignment
        stack.distribution = config.distribution
        stack.isLayoutMarginsRelativeArrangement = config.isLayoutMarginsRelativeArrangement
        stack.directionalLayoutMargins = config.contentInsets
        if let margins = config.margins {
            stack.isLayoutMarginsRelativeArrangement = true
            stack.directionalLayoutMargins = margins
        }
        
        return stack
    }
}
