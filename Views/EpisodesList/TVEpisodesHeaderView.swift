//
//  TVEpisodesHeaderView.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-10.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import UIKit

class TVEpisodesHeaderView: UICollectionReusableView {
    
    static let identifier = "TVEpisodesHeaderView"
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var count: Int {
        didSet {
            countLabel.text = String(count)
        }
    }
    
    override init(frame: CGRect) {
        count = 0
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        count = 0
        super.init(coder: aDecoder)
    }
    
    private func commonInit() {
        count = 0
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    
}
