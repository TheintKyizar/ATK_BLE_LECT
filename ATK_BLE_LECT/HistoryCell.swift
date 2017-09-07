//
//  HistoryCell.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/6/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    let className:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let subject:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupContainerView()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupContainerView(){
        let containerView = UIView()
        contentView.addSubview(containerView)
        
        contentView.addConstraintsWithFormat("H:|[v0]|",views: containerView)
        contentView.addConstraintsWithFormat("V:[v0(30)]", views: containerView)
        contentView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(className)
        containerView.addSubview(subject)
        
        containerView.addConstraintsWithFormat("H:|-20-[v0]", views: className)
        containerView.addConstraintsWithFormat("H:[v0]-20-|", views: subject)
        containerView.addConstraintsWithFormat("V:|-5-[v0]", views: className)
        containerView.addConstraintsWithFormat("V:|-5-[v0]", views: subject)
    }

}
