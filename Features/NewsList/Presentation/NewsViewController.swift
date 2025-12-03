import UIKit
import Combine

// MARK: - NewsViewController

@MainActor
final class NewsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let collectionView: NewsCollectionViewProtocol & UIView
    private let model: NewsViewModelProtocol
    private var bag = Set<AnyCancellable>()
    private let layoutProvider: NewsLayoutProvidingProtocol
    private let animationView = LoadingAnimationView()
    
    // MARK: - Init
    
    init(model: NewsViewModelProtocol, layoutProvider: NewsLayoutProvidingProtocol) {
        self.model = model
        self.layoutProvider = layoutProvider
        self.collectionView = NewsCollectionView(layoutProvider: layoutProvider, imageLoader: model.imageService)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.updateLayout()
        })
    }
    
    override func viewDidLoad() {
        setupView()
        setupBindingsModel()
        setupBindingsCollectionView()
    }
}

// MARK: - SetupView

@MainActor
extension NewsViewController: SetupView {
    
    func setupView() {
        setupSubView()
        setupConstraints()
        animationView.startAnimation()

        Task { [weak self] in
            do {
                try await self?.model.getNews()
            } catch let error {
                self?.animationView.stopAnimation()
                print("❌ [NewsViewController] Failed to load first page: \(error.localizedDescription)")
            }
        }
    }
    
    func setupSubView() {
        view.addSubview(collectionView)
        view.addSubview(animationView)
        view.bringSubviewToFront(animationView)
    }
    
    func setupConstraints() {
        [animationView, collectionView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        fillToParentSafeAreaLayoutGuide(view, collectionView)
        fillToParent(animationView)
    }
    
    func setupBindingsModel() {
        model.news
            .sink { [weak self] models in
                self?.collectionView.replaceAll(with: models, animated: true)
                if !models.isEmpty {
                    self?.animationView.stopAnimation()
                }
            }
            .store(in: &bag)
    }
    
    func setupBindingsCollectionView() {
        collectionView.bottomPullPublisher
            .sink { [weak self] in self?.handleBottomPull() }
            .store(in: &bag)
        collectionView.selectionPublisher
            .sink { [weak self] news in
                self?.model.didSelect(item: news)
            }
            .store(in: &bag)
    }
}

// MARK: - Private Methods

private extension NewsViewController {
    
    func handleBottomPull() {
        collectionView.setFooterLoading(true)
        
        Task {
            do {
                try await model.getNextPageNews()
            } catch let error {
                print("❌ [NewsViewController] Failed to load next page: \(error.localizedDescription)")
            }
            collectionView.setFooterLoading(false)
        }
    }
}
