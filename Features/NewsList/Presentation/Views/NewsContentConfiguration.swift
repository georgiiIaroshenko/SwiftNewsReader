import UIKit

struct NewsContentConfiguration: UIContentConfiguration, Equatable {
    let content: NewsCellModel
    let imageLoader: SingleImageLoadingProtocol
    let imageSize: CGSize
    
    func makeContentView() -> UIView & UIContentView {
        MainNewsCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> NewsContentConfiguration {
        self
    }
    
    static func == (lhs: NewsContentConfiguration, rhs: NewsContentConfiguration) -> Bool {
        lhs.content.new.id == rhs.content.new.id &&
        lhs.imageSize == rhs.imageSize
    }
}
