import UIKit

final class CategoryPillView: UIView, ContentResettable {
    private let hStack = StackFactory().make(.init(axis: .horizontal, spacing: 6, alignment: .fill,
                                                   distribution: .fill,
                                                  contentInsets: .init(top: 2, leading: 2, bottom: 2, trailing: 2)))
    private let label = LabelFactory().make(.init( font: .preferredFont(forTextStyle: .caption1), textColor: UIColor.darkGray, numberOfLines: 1, cornerRadius: 8, masksToBounds: true,  textInsets: .init(top: 4, left: 8, bottom: 4, right: 8)))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        resetContent()
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(categories: String ) {
        hStack.isHidden = false
        label.text = categories
    }
    
    func resetContent() {
        label.text = nil
        hStack.isHidden = true
    }
}

extension CategoryPillView: SetupView {
    func setupView() {
        addSubview(hStack)
        label.backgroundColor = UIColor.systemGray5
        setupSubView()
        setupConstraints()
    }
    
    func setupSubView() {
        label.backgroundColor = UIColor.systemGray5
        hStack.addArrangedSubview(label)
    }
    
    func setupConstraints() {
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            hStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }
}
