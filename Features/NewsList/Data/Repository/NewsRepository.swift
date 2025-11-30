import Foundation

// MARK: - NewsRepositoryProtocol

protocol NewsRepositoryProtocol: AnyObject {
    func getNewsPage(page: Int, pageSize: Int) async throws -> News
}

// MARK: - NewsRepository

final class NewsRepository<Cache: CacheProtocol>: NewsRepositoryProtocol where Cache.Value == Data {
    
    // MARK: - Properties
    
    let fileManager: PrefixedFileExchangeProtocol
    private let cache: Cache
    let loader: NewsDTOLoaderProtocol
    
    // MARK: - Init
    
    init(fileManager: PrefixedFileExchangeProtocol, cache: Cache, loader: NewsDTOLoaderProtocol) {
        self.fileManager = fileManager
        self.cache = cache
        self.loader = loader
    }

    // MARK: - NewsRepositoryProtocol
    
    func getNewsPage(page: Int, pageSize: Int) async throws -> News {
        let key = NewsPageKey(key: String(page), pageSize: pageSize)

        if let cached = cache.get(key) {
            let dto = try decode(cached)
            return News(dto)
        }

        if let data = await fileManager.read(filename: "news_\(page)_\(pageSize)") {
            cache.set(data, for: key)
            let dto = try decode(data)
            return News(dto)
        }

        let data = try await loader.loadData(page: page, pageSize: pageSize)
        try await fileManager.write(data, filename: "news_\(page)_\(pageSize)")
        cache.set(data, for: key)

        let dto = try decode(data)
        return News(dto)
    }
    
    // MARK: - Private Methods
    
    private func decode(_ data: Data) throws -> NewsDTO {
        let dto = try JSONDecoder().decode(NewsDTO.self, from: data)
        return dto
    }
    
    private func encode(_ news: News) throws -> Data {
        return try JSONEncoder().encode(news)
    }
}

// MARK: - NewsRepositoryError

enum NewsRepositoryError: Error {
    case errorGetNextPageNews
}

