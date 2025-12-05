import UIKit

enum LayoutProviderFactory {
    static func make(for idiom: UIUserInterfaceIdiom) -> NewsLayoutProvidingProtocol {
        switch idiom {
        case .pad:  NewsIpadLayoutProvider()
        default:    NewsIphoneLayoutProvider()
        }
    }
}
