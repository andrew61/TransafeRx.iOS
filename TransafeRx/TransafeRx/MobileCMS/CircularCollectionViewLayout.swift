//
//  CircularCollectionViewLayout.swift
//  MobileCMS
//
//  Created by Jonathan on 2/26/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

class CircularCollectionViewLayout: UICollectionViewLayout {
    
    let itemSize = CGSize(width: 250, height: 320)
    
    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItems(inSection: 0) > 0 ?
            -CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * anglePerItem : 0
    }
    
    var angle: CGFloat {
        return angleAtExtreme * collectionView!.contentOffset.x / (collectionViewContentSize.width - collectionView!.bounds.width)
    }
    
    var radius: CGFloat = 500 {
        didSet {
            invalidateLayout()
        }
    }
    
    var anglePerItem: CGFloat {
        return atan(itemSize.width / radius)
    }
    
    var attributesList = [RoundedCollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize : CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItems(inSection: 0)) * itemSize.width,
                      height: collectionView!.bounds.height)
    }
    
    override class var layoutAttributesClass : AnyClass {
        return RoundedCollectionViewLayoutAttributes.self
    }
    
    override func prepare() {
        super.prepare()
        
        let centerX = collectionView!.contentOffset.x + (collectionView!.bounds.width / 2.0)
        let anchorPointY = ((itemSize.height / 2.0) + radius) / itemSize.height
        //1
        let theta = atan2(collectionView!.bounds.width / 2.0,
                          radius + (itemSize.height / 2.0) - (collectionView!.bounds.height / 2.0))
        //2
        var startIndex = 0
        var endIndex = collectionView!.numberOfItems(inSection: 0) - 1
        //3
        if (angle < -theta) {
            startIndex = Int(floor((-theta - angle) / anglePerItem))
        }
        //4
        endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem)))
        //5
        if (endIndex < startIndex) {
            endIndex = 0
            startIndex = 0
        }
        attributesList = (0..<collectionView!.numberOfItems(inSection: 0)).map { (i)
            -> RoundedCollectionViewLayoutAttributes in
            // 1
            let attributes = RoundedCollectionViewLayoutAttributes(forCellWith: IndexPath(item: i,
                                                                                          section: 0))
            attributes.size = self.itemSize
            // 2
            attributes.center = CGPoint(x: centerX, y: self.collectionView!.bounds.midY)
            // 3
            attributes.angle = self.angle + (self.anglePerItem * CGFloat(i))
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
            
            return attributes
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) ->
        [UICollectionViewLayoutAttributes]? {
            return attributesList
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes? {
            return attributesList [(indexPath as NSIndexPath).row]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

class RoundedCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    var angle: CGFloat = 0 {
        didSet {
            //zIndex = Int(angle*1000000)
            transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    override func copy(with zone: NSZone?) -> Any {
        let copiedAttributes: RoundedCollectionViewLayoutAttributes = super.copy(with: zone) as! RoundedCollectionViewLayoutAttributes
        copiedAttributes.anchorPoint = self.anchorPoint
        copiedAttributes.angle = self.angle
        return copiedAttributes
    }
}
