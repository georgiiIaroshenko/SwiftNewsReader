import UIKit
import Combine

final class ExpandableLabelView: UIView, ContentResettable {
    private let label = LabelFactory().make(.init(textColor: UIColor.label , numberOfLines: 0, isUserInteractionEnabled: true))
    
    private let expansionSubject = PassthroughSubject<Bool, Never>()
    var expansion: AnyPublisher<Bool, Never> { expansionSubject.eraseToAnyPublisher() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        resetContent()
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(text: String?) {
        label.text = text
    }
    
    func resetContent() {
        label.text = nil
        expansionSubject.send(false)
    }
}

extension ExpandableLabelView: SetupView {
    func setupView() {
        setupSubView()
        setupConstraints()
    }
    
    func setupSubView() {
        addSubview(label)
    }
    
    func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        fillToParent(label)
    }
}
