import UIKit

// MARK: - Factory Protocols

protocol NewsListFactoryProtocol: AnyObject {
    func makeNewsList(router: NewsRoutingProtocol) -> UIViewController
}

protocol NewsDetailFactoryProtocol: AnyObject {
    func makeNewsDetail(_ new: New, router: NewsDetailRoutingProtocol) -> UIViewController
}

protocol AppFactoryProtocol: NewsListFactoryProtocol, NewsDetailFactoryProtocol {}

// MARK: - AppFactory

final class AppFactory: AppFactoryProtocol {
    
    // MARK: - Properties
    
    private let layoutProvider: NewsLayoutProvidingProtocol
    private let imageService: ImageServiceProtocol
    private let newsService: NewsServiceProtocol
    
    // MARK: - Init
    
    init(idiom: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom) {
        // File managers
        layoutProvider = LayoutProviderFactory.make(for: idiom)
        let fileManager = RootFileExchange()
        let imageFileManager = ImageFileExchange(exchange: fileManager)
        let newsFileManager = NewsFileExchange(exchange: fileManager)
        
        // Caches
        let imageCache = AnyCache<CachedImage>(limit: CacheLimit())
        let newsCache = AnyCache<CachedData>(limit: CacheLimit())
        let imageDownsampler = ImageDownsampler()
        
        // Network
        let urlSession = URLSessionFactory().makeImageURLSession()
        let networkClient = NetworkClient(urlSession: urlSession)
        let loader = DataLoader(client: networkClient)
        let imageLoader = ImageLoader(loader: loader)
        let newsLoader = NewsDTOLoader(loader: loader)
        let newsRepository = NewsRepository(fileManager: newsFileManager, cache: newsCache, loader: newsLoader)
        
        // Services
        self.imageService = ImageService(
            fileManager: imageFileManager,
            nsCache: imageCache,
            downsampler: imageDownsampler,
            loader: imageLoader
        )
        
        self.newsService = NewsService(repository: newsRepository)
    }
    
    // MARK: - NewsListFactoryProtocol
    
    func makeNewsList(router: NewsRoutingProtocol) -> UIViewController {
        let vm = NewsViewModel(
            newsService: newsService,
            imageService: imageService,
            router: router
        )
        let vc = NewsViewController(model: vm, layoutProvider: layoutProvider)
        return vc
    }
    
    // MARK: - NewsDetailFactoryProtocol
    
    func makeNewsDetail(_ new: New, router: NewsDetailRoutingProtocol) -> UIViewController {
        let vm = NewsDetailViewModel(new, imageService: imageService, router: router)
        let vc = NewsDetailViewController(model: vm)
        return vc
    }
}
