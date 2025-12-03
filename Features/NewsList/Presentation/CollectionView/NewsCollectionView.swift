import UIKit
import Combine

protocol NewsCollectionViewInput: AnyObject {
    func replaceAll(with sections: [NewsSectionModel], animated: Bool)
    func updateLayout()
    func setFooterLoading(_ isLoading: Bool)
}

protocol NewsCollectionViewOutput: AnyObject {
    var bottomPullPublisher: AnyPublisher<Void, Never> { get }
    var selectionPublisher: AnyPublisher<NewsItem, Never> { get }
}

protocol NewsCollectionViewProtocol: NewsCollectionViewInput, NewsCollectionViewOutput {}

@MainActor
final class NewsCollectionView: UIView, NewsCollectionViewProtocol {
    
    private enum Constants {
        static let pullToRefreshThreshold: CGFloat = 100
        static let pullToRefreshTrigger: CGFloat = 100
    }
    
    private let collectionView: UICollectionView
    private let cellConfigurators: [ NewsCellConfiguratorProtocol ]
    private let imageLoader: SingleImageLoadingProtocol
    
    private var isFooterLoading = false
    private var isFooterPulling = false
    
    private let bottomPullSubject = PassthroughSubject<Void, Never>()
    private let selectionSubject = PassthroughSubject<NewsItem, Never>()
    
    var bottomPullPublisher: AnyPublisher<Void, Never> {
        bottomPullSubject.eraseToAnyPublisher()
    }
    var selectionPublisher: AnyPublisher<NewsItem, Never> {
        selectionSubject.eraseToAnyPublisher()
    }
    
    private let layoutProvider: NewsLayoutProvidingProtocol
    private let footerRegistration = UICollectionView.SupplementaryRegistration<LoadingFooterView>(
        elementKind: LoadingFooterView.elementKind
    ){_,_,_ in }
    
    private lazy var dataSource = makeDataSource()
    
    typealias Item = NewsItem
    typealias Section = NewsSection
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    
    init(layoutProvider: NewsLayoutProvidingProtocol, imageLoader: SingleImageLoadingProtocol) {
        self.layoutProvider = layoutProvider
        collectionView = CollectionViewFactory().make(layoutProvider: layoutProvider)
        self.imageLoader = imageLoader
        self.cellConfigurators = [ 
            MainNewsCellConfigurator(imageLoader: imageLoader, layoutProvider: layoutProvider) 
        ]
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(" NewsCollectionView - deinited ")
    }
    func updateLayout() {
        collectionView.setCollectionViewLayout(
            layoutProvider.makeLayout(),
            animated: false
        )
    }
    
    func replaceAll(with sections: [NewsSectionModel], animated: Bool = false) {
        var snapshot = Snapshot()
        
        for sectionModel in sections {
            snapshot.appendSections([sectionModel.section])
            snapshot.appendItems(sectionModel.items, toSection: sectionModel.section)
        }
        
        applySnapshot(snapshot, animated: animated)
    }
    
    func setFooterLoading(_ isLoading: Bool) {
        isFooterLoading = isLoading
        collectionView.visibleSupplementaryViews(ofKind: LoadingFooterView.elementKind).forEach {
            ( $0 as? LoadingFooterView )?
                .setLoading(self.isFooterPulling || self.isFooterLoading)
        }
    }
}

extension NewsCollectionView: SetupView {
    func setupView() {
        setupSubView()
        setupConstraints()
    }
    
    func setupSubView() {
        addSubview(collectionView)
        collectionView.delegate = self
    }
    
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        fillToParent(collectionView)
    }
}

extension NewsCollectionView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isFooterLoading else { return }
        let pullDistance = calculatePullDistance(from: scrollView)
        let pullingNow = pullDistance > Constants.pullToRefreshThreshold
        
        guard pullingNow != isFooterPulling else { return }
        
        isFooterPulling = pullingNow
        
        collectionView.visibleSupplementaryViews(ofKind: LoadingFooterView.elementKind).forEach {
            ( $0 as? LoadingFooterView )?
                .setLoading(self.isFooterPulling || self.isFooterLoading)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !isFooterLoading else { return }

        let pullDistance = calculatePullDistance(from: scrollView)
        let trigger: CGFloat = Constants.pullToRefreshTrigger
        
        if pullDistance > trigger {
            bottomPullSubject.send(())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        selectionSubject.send(item)
    }
}

private extension NewsCollectionView {
    func applySnapshot(_ snapshot: Snapshot, animated: Bool) {
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func makeDataSource() -> DataSource {
        let ds = DataSource(collectionView: collectionView) { [weak self] cv, indexPath, item in
                guard let self else { return UICollectionViewCell() }

                guard let configurator = self.cellConfigurators.first(where: {
                    $0.canHandle(item, at: indexPath)
                }) else {
                    return UICollectionViewCell()
                }

                return configurator.dequeueAndConfigure(
                    in: cv,
                    indexPath: indexPath,
                    item: item
                )
            }
        
        ds.supplementaryViewProvider = { [weak self] cv, kind, indexPath in
                guard let self else { return nil }

                switch kind {
                case LoadingFooterView.elementKind:
                    let lastSectionIndex = cv.numberOfSections - 1
                    guard indexPath.section == lastSectionIndex else { return nil }
                    
                    let footer = cv.dequeueConfiguredReusableSupplementary(
                        using: self.footerRegistration,
                        for: indexPath
                    )
                    footer.setLoading(isFooterPulling || isFooterLoading)
                    return footer
                default:
                    return nil
                }
            }
            return ds
    }
    
    func calculatePullDistance(from scrollView: UIScrollView) -> CGFloat {
        let offsetY = scrollView.contentOffset.y
        let visibleHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        return offsetY + visibleHeight - contentHeight
    }
}
