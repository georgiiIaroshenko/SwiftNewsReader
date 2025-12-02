# 📰 AutoNews

> Elegant iOS news reader built with modern Swift architecture

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![UIKit](https://img.shields.io/badge/UIKit-Programmatic-green.svg)](https://developer.apple.com/documentation/uikit)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM--C-purple.svg)](https://en.wikipedia.org/wiki/Model–view–viewmodel)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

<p align="center">
  <img src="Assets/hero-banner.png" alt="AutoNews Hero" width="100%">
</p>

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🏛 **Clean Architecture** | MVVM-C with Coordinators for scalable navigation |
| ⚡️ **Swift Concurrency** | Full async/await with structured concurrency |
| 🖼 **Smart Image Caching** | Three-tier caching: Memory → Disk → Network |
| 📱 **Universal App** | Adaptive layouts for iPhone & iPad |
| ♾ **Infinite Scroll** | Seamless pagination with prefetching |
| 🚀 **Zero Dependencies** | 100% native implementation |

---

## 📸 Screenshots

<p align="center">
  <img src="Assets/Screenshots/iphone-list.png" width="200" alt="News List iPhone">
  <img src="Assets/Screenshots/iphone-detail.png" width="200" alt="News Detail iPhone">
  <img src="Assets/Screenshots/ipad-list.png" width="300" alt="News List iPad">
</p>

---

## 🎬 Demo

<p align="center">
  <img src="Assets/Demo/scroll-demo.gif" width="300" alt="Infinite Scroll Demo">
  <img src="Assets/Demo/navigation-demo.gif" width="300" alt="Navigation Demo">
</p>

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │    Views     │◄───│  ViewModel   │◄───│ Coordinator  │       │
│  │  (UIKit)     │    │  (Combine)   │    │ (Navigation) │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
└─────────────────────────────┬───────────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────────┐
│                          Domain                                  │
│  ┌──────────────┐    ┌──────────────┐                           │
│  │    Models    │    │   Services   │                           │
│  │  (Entities)  │    │   (Actors)   │                           │
│  └──────────────┘    └──────────────┘                           │
└─────────────────────────────┬───────────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────────┐
│                           Data                                   │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │  Repository  │    │    Cache     │    │   Network    │       │
│  │  (Protocol)  │    │ (Memory/Disk)│    │   (Client)   │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

#### 🔄 Coordinator Pattern
Navigation logic is completely decoupled from ViewControllers, enabling:
- Deep linking support
- Easy A/B testing of flows  
- Simplified unit testing

#### 🎭 Actor-based Services
`ImageService` and file operations use Swift Actors for thread-safe concurrent access:

```swift
actor ImageService {
    private let cache: AnyCache<ImageCacheKey, UIImage>
    private let inflight: InflightTable<URL, UIImage>
    
    func loadImage(from url: URL, targetSize: CGSize) async throws -> UIImage
}
```

#### 📦 Three-Tier Image Caching

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Memory    │ ──► │    Disk     │ ──► │   Network   │
│   (NSCache) │     │ (FileManager)│     │  (URLSession)│
└─────────────┘     └─────────────┘     └─────────────┘
      ▲                                        │
      └────────────────────────────────────────┘
                    Cache on success
```

#### 🛡 Inflight Request Deduplication
Prevents redundant network calls when the same resource is requested multiple times:

```swift
final class InflightTable<Key: Hashable, Value: Sendable>: @unchecked Sendable {
    func value(for key: Key, create: () async throws -> Value) async throws -> Value
}
```

---

## 📁 Project Structure

```
AutoNews/
├── 📁 Application/           # App lifecycle & entry point
├── 📁 Presentation/
│   ├── 📁 Screens/
│   │   ├── 📁 NewsList/      # News feed with infinite scroll
│   │   └── 📁 NewsDetail/    # Full article view
│   └── 📁 Common/            # Reusable UI components
├── 📁 Domain/                # Business models
├── 📁 Data/
│   ├── 📁 Repositories/      # Data access abstraction
│   ├── 📁 Network/           # API layer & DTOs
│   └── 📁 Storage/           # Caching infrastructure
├── 📁 Core/
│   ├── 📁 Services/          # Business logic (Actors)
│   ├── 📁 Network/           # HTTP client
│   └── 📁 Navigation/        # Coordinators & Router
├── 📁 DI/                    # Dependency injection
└── 📁 Common/                # Extensions & utilities
```

---

## 🔧 Technical Highlights

### Compositional Layout

Adaptive grid that responds to device size and orientation:

```swift
// iPhone: 1 column
// iPad Portrait: 2 columns  
// iPad Landscape: 3 columns

func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0 / columnsCount),
        heightDimension: .estimated(300)
    )
    // ...
}
```

### Content Configuration API

Modern cell configuration replacing `cellForItemAt`:

```swift
struct NewsContentConfiguration: UIContentConfiguration {
    var title: String?
    var imageURL: URL?
    var publishDate: Date?
    
    func makeContentView() -> UIView & UIContentView {
        NewsContentView(configuration: self)
    }
}
```

### Combine + async/await Bridge

Seamless integration of reactive UI with structured concurrency:

```swift
class NewsViewModel {
    @Published private(set) var state: ViewState = .idle
    
    func loadNews() {
        Task { [weak self] in
            self?.state = .loading
            let news = try await newsService.fetchNews(page: currentPage)
            self?.state = .loaded(news)
        }
    }
}
```

---

## 🚀 Getting Started

### Requirements

- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+


## 📊 Performance

| Metric | Value |
|--------|-------|
| Cold Launch | < 1s |
| Image Load (cached) | < 50ms |
| Memory (idle) | ~45 MB |
| Scroll FPS | 60 fps |

### Optimizations Applied

- ✅ Image downsampling before display
- ✅ Prefetching with `UICollectionViewDataSourcePrefetching`
- ✅ Request deduplication via `InflightTable`
- ✅ Lazy cell registration
- ✅ Diffable data source for efficient updates


## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Your Name**

- GitHub: [@EgorIaroshenko](https://github.com/georgiiIaroshenko)
- LinkedIn: [Egor-iaroshenko](www.linkedin.com/in/georgii-iaroshenko)
- Telegram: [@IaroshEgor](https://t.me/@iaroshGeor)

---

<p align="center">
  <sub>Built with ❤️ and Swift</sub>
</p>
