//
//  BottomBarView.swift
//  TransafeRx
//
//  Created by Tachl on 8/28/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import KTCenterFlowLayout

protocol BottomBarViewDelegate{
    func selectedCell(index: Int)
}

class BottomBarView: UIView{
    
    var menuItems = [String]()
    var bottomBarViewDelegate: BottomBarViewDelegate? = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 5.0
        layout.minimumLineSpacing = 5.0
        if UIDevice.current.userInterfaceIdiom == .pad{
            layout.itemSize = CGSize(width: 200, height: 100)
        }else{
            layout.itemSize = CGSize(width: 100, height: 85)
        }
        
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "MenuCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MenuCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setData(type: Int?){
        if type == nil || type == 2{
            menuItems = ["Med New/Change?", "Admission?", "ER Visit?"]
        }else{
            menuItems = ["Med New/Change?", "Discharged?", "ER Visit?"]
        }
    }
    
    func reloadData(){
        collectionView.reloadData()
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "BottomBarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}

// MARK: - UICollectionViewDataSource
extension BottomBarView: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
        
        cell.menuLabel.font = UIFont(name: "Helvetica", size: 18.0)
        cell.menuLabel.text = menuItems[indexPath.row]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension BottomBarView: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        bottomBarViewDelegate?.selectedCell(index: indexPath.row)
    }
}
