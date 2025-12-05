import UIKit

protocol NewsLayoutProvidingProtocol: AnyObject {
    var portretСolumns: Int { get }
    var landscapeColumns: Int { get }
    func columns(for environment: NSCollectionLayoutEnvironment) -> Int
    
    func makeLayout() -> UICollectionViewCompositionalLayout
    func imageSize(for containerWidth: CGFloat, trait: UITraitCollection) -> CGSize
}

extension NewsLayoutProvidingProtocol {
    func columns(for environment: NSCollectionLayoutEnvironment) -> Int {
            let size = environment.container.effectiveContentSize
            let isLandscape = size.width > size.height
            return isLandscape ? landscapeColumns : portretСolumns
        }
    
    func imageSize(
            for containerWidth: CGFloat,
            trait: UITraitCollection
        ) -> CGSize {
            let horizontalInsets: CGFloat = 0
            let width = containerWidth - horizontalInsets

            let aspect: CGFloat = 9.0 / 16.0
            let height = width * aspect

            return CGSize(width: width, height: height)
        }
    
    func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] _, environment in
            guard let self else { return nil }
            let trait = environment.traitCollection
            let isLandscape = trait.verticalSizeClass == .compact
            
            let columnCount = self.columns(for: environment)

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(330)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(330)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: columnCount
            )
            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 6,
                leading: 6,
                bottom: 6,
                trailing: 6
            )
            section.interGroupSpacing = 10
            
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60)
            )
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: LoadingFooterView.elementKind,
                alignment: .bottom
            )
            
            section.boundarySupplementaryItems = [footer]
            
            return section
        }
    }
}
