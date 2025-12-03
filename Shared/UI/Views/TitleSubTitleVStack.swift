import UIKit
protocol ConfigureTitleSubTitleVStackProtocol: AnyObject {
    func configure(title: String, subtitle: String)
}

protocol TitleSubTitleVStackProtocol: ConfigureTitleSubTitleVStackProtocol, ContentResettable {}

final class TitleSubTitleVStack: UIView, TitleSubTitleVStackProtocol {
    private let vStack = StackFactory().make(.init(axis: .vertical, spacing: 6))
    private let titleLabel = LabelFactory().make(.init(
        font: .preferredFont(forTextStyle: .headline),
        textColor: UIColor.darkText,
        numberOfLines: 1,
    ))
    
    private let subtitleLabel = LabelFactory().make(.init(
        font: .preferredFont(forTextStyle: .subheadline),
        textColor: UIColor.secondaryLabel,
        numberOfLines: 1,
    ))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        resetContent()
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    func resetContent() {
        [titleLabel, subtitleLabel].forEach { $0.text = nil }
    }
}

extension TitleSubTitleVStack: SetupView {
    func setupView() {
        setupSubView()
        setupConstraints()
    }
    
    func setupSubView() {
        addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        [titleLabel, subtitleLabel].forEach { vStack.addArrangedSubview($0) }
    }
    
    func setupConstraints() {
        fillToParentSafeAreaLayoutGuide(self, vStack)
    }
}
