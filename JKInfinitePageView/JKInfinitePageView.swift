//
//  JKInfinitePageView.swift
//  JKInfinitePageView-Sample
//
//  Created by Joe on 2017/3/13.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

private let reuseIdentifier = "InfinitePageCell"

public enum JKInfinitePageViewScrollDirection: Int{
    
    case vertical
    
    case horizontal
}

class JKInfinitePageCell: UICollectionViewCell {
    var pageView: UIView?{
        didSet{
            if let view = pageView{
                for subview in subviews{
                    subview.removeFromSuperview()
                }
                view.frame = bounds
                addSubview(view)
            }
        }
    }
    
}

class JKInfinitePageView: UIView {
    
    var dataSource: JKInfinitePageViewDataSource?

    fileprivate var collectionView: UICollectionView!
    fileprivate var currentIndexPath: IndexPath = IndexPath(item: Int(Int16.max/2), section: 0)
    fileprivate var willDisplayIndexPath: IndexPath!
    fileprivate var currentView: UIView?
    
    open var scrollDirection: JKInfinitePageViewScrollDirection = .horizontal{
        didSet{
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.scrollDirection = scrollDirection == .horizontal ? .horizontal: .vertical
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = scrollDirection == .horizontal ? .horizontal: .vertical
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        addSubview(collectionView)
        
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(JKInfinitePageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        collectionView.setContentOffset(CGPoint(x: CGFloat(currentIndexPath.item) * bounds.width, y: 0), animated: false)
    }
    
    public func setView(_ view: UIView){
        currentView = view
        collectionView.reloadData()
    }
}

extension JKInfinitePageView: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
}

extension JKInfinitePageView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let view = currentView{
            let cell = cell as! JKInfinitePageCell
            if indexPath.item > currentIndexPath.item{
                cell.pageView = dataSource?.infinitePageView(self, viewAfter: view)
            }else if indexPath.item < currentIndexPath.item{
                cell.pageView = dataSource?.infinitePageView(self, viewBefore: view)
            }else{
                cell.pageView = view
            }
            willDisplayIndexPath = indexPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if willDisplayIndexPath.item > indexPath.item{ // 往右翻
            currentIndexPath = willDisplayIndexPath
            currentView = (collectionView.cellForItem(at: currentIndexPath) as! JKInfinitePageCell).pageView
        }else if willDisplayIndexPath.item < indexPath.item{ // 往左翻
            currentIndexPath = willDisplayIndexPath
            currentView = (collectionView.cellForItem(at: currentIndexPath) as! JKInfinitePageCell).pageView
        }else{ // 沒翻
            
        }
    }
}

extension JKInfinitePageView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(Int16.max)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JKInfinitePageCell
        
        return cell
    }
}

protocol JKInfinitePageViewDataSource {
    
    func infinitePageView(_ infinitePageView: JKInfinitePageView, viewBefore view: UIView) -> UIView
    
    func infinitePageView(_ infinitePageView: JKInfinitePageView, viewAfter view: UIView) -> UIView
    
}
