//
//  FriendViewController.swift
//  IMSampler
//
//  Created by LongJunYan on 2018/3/27.
//  Copyright © 2018年 onelcat. All rights reserved.
//

import UIKit

class FriendViewController: UIViewController {
    
    var dataSource: [String] = ["helo","you ", "are ", "Name"]
    
    private var reuseIdentifier = "cell"
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        return tableView
    }()
    
    func viewInit() {
        self.view.addSubview(tableView)
        self.title = "好友"
        
        let vc = self.revealViewController()
       
        vc?.panGestureRecognizer()
        vc?.tapGestureRecognizer()

        
        let left  = UIBarButtonItem.init(title: "菜单", style: UIBarButtonItemStyle.plain, target: vc, action: #selector(vc?.rightRevealToggle(_:)))
        self.navigationItem.rightBarButtonItem = left
    }
    
    @objc func leftAction() {
        
    }
    
    func layoutInit() {
        
    }
    
    func commonInit() {
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
        
        commonInit()
    }
    
    
    
}

extension FriendViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.contentView.showNumberBadge(withValue: 99)
        cell.contentView.badgeCenterOffset = CGPoint.init(x: -30, y: 40)
        cell.contentView.badgeRadius = 5.0
        return cell
    }
    
}

extension FriendViewController: UITableViewDelegate {
    
}
