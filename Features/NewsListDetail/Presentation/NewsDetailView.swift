import UIKit
import Combine

protocol NewsDetailViewProtocol: AnyObject {
    var openSafariPublisher: AnyPublisher<Void, Never> { get }
    func configure(_ new: New, imageLoader: SingleImageLoadingProtocol)
}

@MainActor
final class NewsDetailView: UIView, NewsDetailViewProtocol {
    
    // MARK: - UI Components
    
    private let metaStack = StackFactory().make(.init(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill))
    private let titleSubtitleView = TitleSubTitleVStack()
    private let imageView = LoadableImageView()
    private let bodyLabel = ExpandableLabelView()
    private let buttonOpenSafari = ButtonFactory().make(ButtonConfig(cornerRadius: 6, contentInsets: NSDirectionalEdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)))
    
    // MARK: - Publisher
    var openSafariPublisher: AnyPublisher<Void, Never> {
        openSafariSubject.eraseToAnyPublisher()
    }
    private let openSafariSubject = PassthroughSubject<Void, Never>()
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(_ new: New, imageLoader: SingleImageLoadingProtocol) {
        titleSubtitleView.configure(title: new.title, subtitle: new.publishedDate)
        bodyLabel.configure(text: new.description)
        
        let imageSize = imageSizeForFullWidth()
        imageView.configure(
            new.imageUrl,
            loader: imageLoader,
            imageSize: imageSize
        )
    }
    
    // MARK: - Actions
    
    @objc private func openSafariTapped() {
        openSafariSubject.send()
    }
}

// MARK: - SetupView

extension NewsDetailView: SetupView {
    func setupView() {
        setupSubView()
        setupConstraints()
    }
    
    func setupSubView() {
        setupButtonOpenSafari()
        [metaStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        [titleSubtitleView, imageView, bodyLabel].forEach {
            metaStack.addArrangedSubview($0)
        }
        metaStack.addArrangedSubview(makeButtonContainer(buttonOpenSafari))
    }
    
    func setupButtonOpenSafari() {
        buttonOpenSafari.setTitle("Перейти к полной новости", for: .normal)
        buttonOpenSafari.addTarget(self, action: #selector(openSafariTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            metaStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            metaStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            metaStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
        ])
    }
    func makeButtonContainer(_ button: UIButton) -> UIView {
        let spacerLeft = UIView()
            let spacerRight = UIView()
        let container = UIStackView(arrangedSubviews: [spacerLeft, button, spacerRight])
        container.axis = .horizontal
        container.alignment = .center
        container.distribution = .equalCentering
        return container
    }
}
