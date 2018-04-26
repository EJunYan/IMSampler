////
////  FriendTableViewCell.swift
////  IMSampler
////
////  Created by LongJunYan on 2018/3/27.
////  Copyright © 2018年 onelcat. All rights reserved.
////
//
//import UIKit
//
//import YYText
//
//enum GenderType {
//    case male
//    case female
//    case unknown
//}
//
//enum MessageType {
//    case system
//    case groups
//    case plan
//    case single
//    case activities
//}
//
//struct MessageTableModelCell {
//    var gender: GenderType = .unknown
//    var avatarImage: UIImage?
//    var name: String?
//    var time: Date?
//    var count: Int = 0
//    var type: MessageType?
//}
//
//
//
//
//class FriendTableViewCell: UITableViewCell {
//
//    private lazy var avatarImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.sizeToFit()
//        return imageView
//    }()
//    
//    private lazy var nameLabel: YYLabel = {
//        let label = YYLabel()
//        
//        return label
//    }()
//    
//    private lazy var messageLabel: YYLabel = {
//        let label = YYLabel()
//        
//        return label
//    }()
//    
//    private lazy var timeLabel: YYLabel = {
//        let label = YYLabel()
//        
//        return label
//        
//    }()
//    
//    func viewInit() {
//        
//    }
//    
//    func layoutInit() {
//        
//    }
//    
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        layoutInit()
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        viewInit()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//}
