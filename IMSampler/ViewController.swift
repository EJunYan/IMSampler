//
//  ViewController.swift
//  IMSampler
//
//  Created by LongJunYan on 2018/3/21.
//  Copyright © 2018年 onelcat. All rights reserved.
//

import UIKit
import XMPPFrameworkSwift

class ViewController: UIViewController {

    var button: UIButton?
    var userTextField: UITextField?
    
    var stream: XMPPStream?
    
    var jid: XMPPJID?
    
    // 花名册
    var rosterStorage: XMPPRosterCoreDataStorage?
    var roster: XMPPRoster?
    
    // 这里是聊天界面用的
    var messageArchivingCoreDataStorage: XMPPMessageArchivingCoreDataStorage?
    
    var xmppMessageArchiving: XMPPMessageArchiving?
    
    
    var messageContex: NSManagedObjectContext?
    
    var rosterArray = [XMPPJID]()
    
    let user = "18682435851"
    let pwd = "12345678"
    let domain = "family"
    let resource = "iOS"
    let host = "54.222.203.152"
    
    var isRegister: Bool = false
    
    var textView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        userTextField = UITextField()
        userTextField?.borderStyle = .roundedRect
        let w = self.view.frame.width * 0.8
        userTextField?.frame = CGRect.init(x: 0, y: 30, width: w, height: 30)
        userTextField?.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        self.view.addSubview(userTextField!)
        
        textView = UITextView()
        textView?.font = UIFont.systemFont(ofSize: 14)
        textView?.textColor = #colorLiteral(red: 0.999904573, green: 1, blue: 0.999872148, alpha: 1)
        textView?.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        textView?.frame = CGRect.init(x: 0, y: 88, width: self.view.frame.width, height: 200)
        self.view.addSubview(textView!)
        
        
        button = UIButton()
        button?.backgroundColor = #colorLiteral(red: 1, green: 0.3820377273, blue: 0.4906897393, alpha: 1)
        button?.frame.size = CGSize(width: 100, height: 50)
        button?.addTarget(self, action: #selector(self.buttonAc), for: UIControlEvents.touchUpInside)
        button?.center = self.view.center
        self.view.addSubview(button!)
        
        self.connect()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: - 发起链接
    func connect() {
        jid = XMPPJID.init(user: user, domain: domain, resource: resource)
        
        self.stream = XMPPStream.init()
        self.stream?.myJID = jid
        
        stream?.hostName = host
        stream?.addDelegate(self, delegateQueue: DispatchQueue.global())
        
        do {
            try stream?.connect(withTimeout: 600)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        // 好友花名册部分
        
        // 初始化花名册
        rosterStorage = XMPPRosterCoreDataStorage.sharedInstance()
        roster = XMPPRoster.init(rosterStorage: rosterStorage!, dispatchQueue: DispatchQueue.global())
        // 添加代理
        roster?.addDelegate(self, delegateQueue: DispatchQueue.global())
        // 好友花名册在通道上激活,相当于授权
        roster?.activate(stream!)
        
        // 这里是聊天界面用的
        // 初始化消息归档
        messageArchivingCoreDataStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        
        xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: messageArchivingCoreDataStorage!, dispatchQueue: DispatchQueue.global())
        // 激活
        xmppMessageArchiving?.activate(stream!)
        
        messageContex = messageArchivingCoreDataStorage?.mainThreadManagedObjectContext
    }
    
    // 断开链接
    func disConnet() {
        if self.stream != nil {
            if self.stream?.isConnected == true {
                sendOffline()
                self.stream?.disconnect()
            }
        }

    }

    // 注册
    func register() {
    
        do {
            try stream?.register(withPassword: pwd)
        } catch let error {
            debugPrint("注册系统错误",error.localizedDescription)
        }
        
    }
    // MARK: - 登录
    func login() {
        do {
            try self.stream?.authenticate(withPassword: self.pwd)
        } catch let error {
            debugPrint("验证错误", error.localizedDescription)
        }
    }
    
    @objc func buttonAc() {
        
        guard let user = self.userTextField?.text else {
            return
        }
        
        if let text = self.textView?.text {
            self.sendMessage(user: user, data: text)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 发送出席消息
    func sendOnline() {
        let p = XMPPPresence()
        self.stream?.send(p)
    }
    
    // 发送下限
    func sendOffline() {
        let p = XMPPPresence(type: "unavailabe")
        self.stream?.send(p)
    }

    func sendMessage(user: String, data: Any) {
        
        guard self.stream?.isAuthenticated == true else {
            return
        }
        
        let friendJID = XMPPJID.init(user: user, domain: domain, resource: resource)
        let message = XMPPMessage.init(type: "chat", to: friendJID)
        if let text = data as? String {
            message.addBody(text)
            self.stream?.send(message)
        }
        
    }
    
    // MARK: - 添加好友
    func addFriend(user: String) {
        let fjid = XMPPJID.init(user: user, domain: domain, resource: resource)
        
        // 第一种
//        roster?.subscribePresence(toUser: fjid!)
        
        roster?.addUser(fjid!, withNickname: user)
    }
    
    // MARK: - 删除好友
    func deleteFriend(user: String) {
        let fjid = XMPPJID.init(user: user, domain: domain, resource: resource)
        // 第一种
//        roster?.unsubscribePresence(fromUser: fjid!)
        
        roster?.removeUser(fjid!)
    }
    
    
    //MARK: - 读取消息
    func reloadMessage(user: String) {
        
        // 取消息
        guard let context = self.messageContex else {
            return
        }
        
        // 创建请求对象
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // 创建实体描述,用于描述(指定)所查询的实体
        let entity = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: context)
        fetchRequest.entity = entity
        
        // 所有的消息都存储在这个实体里,需要取出与当前好友的聊天记录,使用谓词(查询条件)的方式进行限定
        // 查询条件 自己的jid.bare 和好友的jid.bare
        let predicate = NSPredicate.init(format: "streamBareJidStr == %@ AND bareJidStr == %@", (jid?.bare)!, user)
        
        fetchRequest.predicate = predicate
        
        // 排序,根据时间进行排序
        let sortDescriptor = NSSortDescriptor.init(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // 执行查询请求
        do {
            let resultArray = try context.execute(fetchRequest)
            debugPrint(resultArray.copy())
        } catch let error {
            debugPrint("获取历史消息错误",error.localizedDescription)
        }
        
    }
    
}

extension ViewController: XMPPStreamDelegate {
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        // MARK: - 链接超时
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        // MARK: - 链接服务器成功 后 进行 密码验证 或者是注册
        
        do {
            
            if self.isRegister {
                // MARK: - 注册
                try self.stream?.register(withPassword: pwd)
            }
            else {
                // MARK: - 登录
                try self.stream?.authenticate(withPassword: self.pwd)
            }
        } catch let error {
            debugPrint("验证错误", error.localizedDescription)
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        // MARK: - 登陆失败
        debugPrint(error.description)
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        //MARK: -  表示当前账号登陆成功 发送出席消息
        debugPrint("登陆成功")
        sendOnline()
    }
    
    func xmppStream(_ sender: XMPPStream, didNotRegister error: DDXMLElement) {
        // MARK: - 注册失败
    }
    
    func xmppStreamDidRegister(_ sender: XMPPStream) {
        // MARK: - 注册成功
    }
    
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        debugPrint("发送消息错误 失败",error.localizedDescription)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        debugPrint("接收消息", message.stringValue)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        debugPrint("接收到出息消息",presence.stringValue)
    }
    
    func xmppStream(_ sender: XMPPStream, willSend message: XMPPMessage) -> XMPPMessage? {
        debugPrint(message.stringValue)
        return message
    }
}

extension ViewController: XMPPRosterDelegate {
    
    func xmppRosterDidBeginPopulating(_ sender: XMPPRoster, withVersion version: String) {
        debugPrint("开始获取好友")
    }
    
    func xmppRosterDidEndPopulating(_ sender: XMPPRoster) {
        debugPrint("停止获取好友")
    }
    
    func xmppRoster(_ sender: XMPPRoster, didReceiveRosterItem item: DDXMLElement) {
        // 获取一个好友走一次这个方法
        
        // none:互相没有订阅
        // to:你订阅了别人,他同意了,但是他并没有订阅你
        // from:你被他订阅了,但你没有订阅他
        // both:互粉
        // remove:删除好友
        
        debugPrint("获取好友进行中")
        
        let sub = item.attribute(forName: "subscription")?.stringValue
        if sub == "both" {
            return
        }
        
        let jidString = item.attribute(forName: "jid")?.stringValue
        let jid = XMPPJID.init(string: jidString!, resource: resource)
        
        if rosterArray.contains(jid!) {
            return
        }
        
        self.rosterArray.append(jid!)
        
    }
    
    
    // MARK: - 接收到好友请求
    func xmppRoster(_ sender: XMPPRoster, didReceivePresenceSubscriptionRequest presence: XMPPPresence) {
        debugPrint("接收到好友请求")
        
        // - 拒绝
        self.roster?.rejectPresenceSubscriptionRequest(from: presence.from!)
        
        // - 接受
        self.roster?.acceptPresenceSubscriptionRequest(from: presence.from!, andAddToRoster: true)
        
    }
    
}

