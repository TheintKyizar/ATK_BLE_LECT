//
//  LessonCell.swift
//  Attandance Taking System
//
//  Created by KyawLin on 5/21/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit

class TimetableCell: UITableViewCell {
    
    var lesson:Lesson?{
        didSet{
            subjectLabel.text = (lesson?.subject)! + " " + (lesson?.catalog)!
            start_time.text = displayTime.display(time: (lesson?.start_time)!)
            end_time.text = displayTime.display(time: (lesson?.end_time)!)
            venue.text = lesson?.venueName
            classNumber.text = lesson?.class_section
            arrivingtimeLabel.isHidden = true
            iconView.isHidden = true
        }
    }
    
    /*let lessonPhoto: UIImageView = {
     
     let imageView = UIImageView()
     imageView.contentMode = .scaleAspectFit
     
     imageView.image = UIImage(named: "yoo2")
     
     imageView.layer.cornerRadius = 34
     imageView.layer.masksToBounds = true
     return imageView
     }()*/
    
    /*let dividerLineView:UIView = {
     let view = UIView()
     view.backgroundColor = UIColor(red: 0.0, green: 0.36, blue: 0.16, alpha: 0.5)
     return view
     }()*/
    
    let subjectLabel:UILabel = {
        let label = UILabel()
        label.text = "ABC"
        label.textColor = UIColor(red: 0.1, green: 0.31, blue: 0.17, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let classNumber:UILabel = {
        let label = UILabel()
        label.text = "T2J2"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let start_time:UILabel = {
        let label = UILabel()
        label.text = "starttime"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let end_time:UILabel = {
        let label = UILabel()
        label.text = "endtime"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let venue:UILabel = {
        let label = UILabel()
        label.text = "venue"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let arrivingtimeLabel:UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let iconView:UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.sizeThatFits(CGSize(width: 50, height: 50))
        return imageView
    }()
    
    /*let statusImage: UIImageView = {
     let imageView = UIImageView()
     imageView.contentMode = .scaleAspectFill
     imageView.layer.cornerRadius = 10
     imageView.layer.masksToBounds = true
     return imageView
     }()*/
    
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
        contentView.addConstraintsWithFormat("V:[v0(90)]", views: containerView)
        contentView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(venue)
        containerView.addSubview(subjectLabel)
        containerView.addSubview(start_time)
        containerView.addSubview(end_time)
        containerView.addSubview(classNumber)
        containerView.addSubview(arrivingtimeLabel)
        containerView.addSubview(iconView)
        
        containerView.addConstraintsWithFormat("H:|-20-[v0]-15-[v1]", views: start_time,subjectLabel)
        containerView.addConstraintsWithFormat("H:|-20-[v0]-20-[v1]", views: end_time,classNumber)
        containerView.addConstraintsWithFormat("H:[v0]-20-|", views: venue)
        containerView.addConstraintsWithFormat("H:[v0]-15-[v1]-20-|", views: arrivingtimeLabel,iconView)
        containerView.addConstraintsWithFormat("V:|-15-[v0]-15-[v1]", views: start_time,end_time)
        containerView.addConstraintsWithFormat("V:|-15-[v0]-15-[v1]", views: subjectLabel,classNumber)
        containerView.addConstraintsWithFormat("V:[v0]-25-|", views: venue)
        containerView.addConstraintsWithFormat("V:[v0]-25-|", views: arrivingtimeLabel)
        containerView.addConstraintsWithFormat("V:[v0]-25-|", views: iconView)
    }
    
}

extension UIView{
    
    func addConstraintsWithFormat(_ format: String, views: UIView...){
        
        var viewsDictionary = [String: UIView]()
        for(index,view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
