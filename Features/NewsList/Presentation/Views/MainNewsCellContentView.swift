import UIKit

final class MainNewsCellContentView: UIView, UIContentView {
    private let titleSubtitleView = TitleSubTitleVStack()
    private let imageView = LoadableImageView()
    private let bodyLabel = ExpandableLabelView()
    private let categoryPill = CategoryPillView()
    private let metaStack = StackFactory().make(.init(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill))
    
    var configuration: UIContentConfiguration {
        didSet { 
            guard let oldConfig = oldValue as? NewsContentConfiguration,
                  let newConfig = configuration as? NewsContentConfiguration,
                  oldConfig != newConfig else {
                return
            }
            apply(configuration)
        }
    }
    
    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupView()
        apply(configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    private func configure(with content: NewsCellModel, loader: SingleImageLoadingProtocol, imageSize: CGSize) {
        titleSubtitleView.configure(title: content.new.title, subtitle: content.new.publishedDate)
        imageView.configure(
            content.new.imageUrl, 
            loader: loader,
            imageSize: imageSize
        )
        bodyLabel.configure(text: content.new.description)
        categoryPill.configure(categories: content.new.categoryType)
    }
    
    private func apply(_ configuration: UIContentConfiguration) {
        guard let cfg = configuration as? NewsContentConfiguration else { return }
        configure(with: cfg.content, loader: cfg.imageLoader, imageSize: cfg.imageSize)
    }
}

extension MainNewsCellContentView: SetupView {
    func setupView() {
        layer.cornerRadius = 12
        setupSubView()
        setupConstraints()
    }
    
    func setupSubView() {
        addSubview(metaStack)
        [titleSubtitleView, imageView, bodyLabel, categoryPill].forEach { metaStack.addArrangedSubview($0) }
    }
    
    func setupConstraints() {
        metaStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            metaStack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            metaStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            metaStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            metaStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
    }
}
