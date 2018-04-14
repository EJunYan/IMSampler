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

    var stream: XMPPStream?
    var jid: XMPPJID?
    
    // 花名册 - 好友关系
    var rosterStorage: XMPPRosterCoreDataStorage?
    var roster: XMPPRoster?
    // 好友管理
    var rosterArray = [XMPPJID]()
    
    // 这里是聊天界面用的 - 消息聊天消息存储
    var messageArchivingCoreDataStorage: XMPPMessageArchivingCoreDataStorage?
    var xmppMessageArchiving: XMPPMessageArchiving?
    var messageContex: NSManagedObjectContext?
    
    // 聊天室
    var room: XMPPRoom?
    var roomjid: XMPPJID?
    
    // 群聊邀请
    var muc: XMPPMUC?
    
    var isRegister: Bool = false

    let user = "18682435851"
    let pwd = "12345678"
    let domain = "family"
    let resource = "iOS"
    let host = "54.222.203.152"
    
    @IBOutlet weak var userTextField: UITextField!
    
    @IBOutlet weak var chatMessageTextView: UITextView!
    
    @IBOutlet weak var roomTextField: UITextField!
    
    @IBOutlet weak var roomChatTextView: UITextView!
    
    @IBAction func addUserButtonAction(_ sender: Any) {
        guard let user = userTextField.text else {
            return
        }
        addFriend(user: user)
    }
    
    @IBAction func createRoomButtonAction(_ sender: Any) {
        guard let roomid = roomTextField.text else {
            return
        }
        roomCreate(roomid: roomid)
    }
    
    @IBAction func inviteUserInRoomButtonAction(_ sender: Any) {
        guard let user = self.userTextField.text else {
            return
        }
        
        inviteUser(user: user)
    }
    
    @IBAction func sendChatButtonAction(_ sender: Any) {
        guard let user = userTextField.text , let text = chatMessageTextView.text else {
            return
        }
        sendMessage(user: user, data: text)
    }
    
    @IBAction func sendChatRommButtonAction(_ sender: Any) {
    
        
    }
    
    func textXMLString() {
        // MARK: 自定义包
        let message = DDXMLElement(name: "message")
        message.addAttribute(withName: "from", stringValue: jid?.full ?? "")
        message.addAttribute(withName: "to", stringValue: "fr@faa/ios")
        message.addAttribute(withName: "type", stringValue: "get")
        
        
        
        let sub = DDXMLElement(name: "sub")
        sub.addNamespace(withPrefix: "sdasd", stringValue: "1231231")
        sub.stringValue = "我就是实际数据部分"
        message.addChild(sub)
        
        
        
        print(message.xmlString)
        
        do {
            let message = try DDXMLElement.init(xmlString: message.xmlString)
            print(message)
            print(message.xmlString)
        } catch let error {
            debugLog("消息错误")
        }
        
        // 解析
        
        let ty = message.attribute(forName: "type")?.stringValue // "get"
        print(ty)
        
        let s = message.child(at: 0)
        
        let f = message.forName("sub")
        print(f?.xmlString)
        print(f?.xmlString , s?.xmlString, s?.name, s?.stringValue)
        
        

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textXMLString()
//        self.connect()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func mucInit() {
        muc = XMPPMUC.init(dispatchQueue: DispatchQueue.global())
        muc?.activate(stream!)
        muc?.addDelegate(self, delegateQueue: DispatchQueue.global())
        
        
    }
    
    
    func streamInit() {
        
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
        
    }
    
    func rosterInit() {
        // 好友花名册部分
        
        // 初始化花名册
        rosterStorage = XMPPRosterCoreDataStorage.sharedInstance()
        roster = XMPPRoster.init(rosterStorage: rosterStorage!, dispatchQueue: DispatchQueue.global())
        // 添加代理
        roster?.addDelegate(self, delegateQueue: DispatchQueue.global())
        // 好友花名册在通道上激活,相当于授权
        roster?.activate(stream!)
    }
    
    func messageChatInit() {
        // 这里是聊天界面用的
        // 初始化消息归档
        messageArchivingCoreDataStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        
        xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: messageArchivingCoreDataStorage!, dispatchQueue: DispatchQueue.global())
        // 激活
        xmppMessageArchiving?.activate(stream!)
        
        messageContex = messageArchivingCoreDataStorage?.mainThreadManagedObjectContext
    }
    var roomStorage: XMPPRoomCoreDataStorage?
    // MARK: - 创建聊天室
    func roomCreate(roomid: String) {
        let roomdomain = "conference." + domain
        
        guard  let roomStorage = XMPPRoomCoreDataStorage.sharedInstance() else {
            fatalError("房间存储实例 错误")
            
        }
        
        
        self.roomStorage = roomStorage
        roomjid = XMPPJID.init(user: roomid, domain: roomdomain, resource: nil)
        
        room = XMPPRoom.init(roomStorage: roomStorage, jid: roomjid!, dispatchQueue: DispatchQueue.global())
        room?.configureRoom(usingOptions: nil)
        
        room?.addDelegate(self, delegateQueue: DispatchQueue.global())
        room?.activate(stream!)
        
        // 自己需要主动加入
        room?.join(usingNickname: user, history: nil)
        
    }
    
    // 邀请好友进入房间
    func inviteUser(user: String) {
        let fjid = XMPPJID.init(user: user, domain: domain, resource: resource)
        room?.inviteUser(fjid!, withMessage: "邀请你加入会议")
    }
    
    func leaveRoom() {
        room?.deactivate()
    }
    
    func destroyRoom() {
        room?.destroy()
    }
    
    
    // MARK: - 发起链接
    func connect() {
        streamInit()

        rosterInit()
        
        messageChatInit()
        
        mucInit()
    }
    

    //MARK: - 断开链接
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sendOnline() {
    
        // 发送出席消息
        
        let p = XMPPPresence()
        self.stream?.send(p)
        
        // 发送 获取群聊列表
        muc?.discoverServices()
    }
    
    // 发送下限
    func sendOffline() {
        let p = XMPPPresence(type: "unavailabe")
        self.stream?.send(p)
    }

    // MARK: - 发送单个聊天消息
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

extension ViewController: XMPPMUCDelegate {
    // 接受到邀请
    func xmppMUC(_ sender: XMPPMUC, roomJID: XMPPJID, didReceiveInvitation message: XMPPMessage) {
        guard  let roomStorage = XMPPRoomCoreDataStorage.sharedInstance() else {
            fatalError("房间存储实例 错误")
            
        }
        debugPrint("接受到邀请")
        room = XMPPRoom.init(roomStorage: roomStorage, jid: roomJID)
        room?.activate(stream!)
        room?.addDelegate(self, delegateQueue: DispatchQueue.global())
        
        // 表示主动加入到房间 - 相当于 接受邀请 进入房间 - 不做操作
        room?.join(usingNickname: user, history: nil)
        
    }
}

// MARK: - 聊天室部分
// MARK: - XMPPRoomDelegate
extension ViewController: XMPPRoomDelegate {
    
    func xmppRoomDidCreate(_ sender: XMPPRoom) {
        debugPrint("聊天时创建成功")
        // 创建成功后发送配置
    }
    
    func xmppRoom(_ sender: XMPPRoom, didFailToDestroy iqError: XMPPIQ) {
        
    }
    

    
    
    // 配置成功聊天市
    func xmppRoom(_ sender: XMPPRoom, didFetchConfigurationForm configForm: DDXMLElement) {
        
    }
    
    // MARK: - 获取聊天室信息
    func xmppRoomDidJoin(_ sender: XMPPRoom) {
        debugPrint( #function )
        room?.fetchConfigurationForm()
        room?.fetchBanList()
        room?.fetchMembersList()
        room?.fetchModeratorsList()
    }
    
    //MARK: - 如果房间存在，会调用委托
    // 收到禁止名单列表
    func xmppRoom(_ sender: XMPPRoom, didFetchBanList items: [Any]) {
        debugPrint( #function )
    }
    // 收到好友名单列表
    func xmppRoom(_ sender: XMPPRoom, didFetchMembersList items: [Any]) {
        debugPrint( #function )
    }
    // 收到主持人名单列表
    func xmppRoom(_ sender: XMPPRoom, didFetchModeratorsList items: [Any]) {
        debugPrint( #function )
    }
    
    // MARK: 房间不存在
    func xmppRoom(_ sender: XMPPRoom, didNotFetchBanList iqError: XMPPIQ) {
        debugPrint( #function )
    }
    
    func xmppRoom(_ sender: XMPPRoom, didNotFetchMembersList iqError: XMPPIQ) {
        debugPrint( #function )
    }
    
    func xmppRoom(_ sender: XMPPRoom, didNotFetchModeratorsList iqError: XMPPIQ) {
        debugPrint( #function )
    }
    
    // 离开聊天室
    func xmppRoomDidLeave(_ sender: XMPPRoom) {
        debugPrint( #function )
    }
    
    // 销毁聊天室
    func xmppRoomDidDestroy(_ sender: XMPPRoom) {
        debugPrint( #function )
    }
    
    // 新人加入群聊
    func xmppRoom(_ sender: XMPPRoom, occupantDidJoin occupantJID: XMPPJID, with presence: XMPPPresence) {
        debugPrint( #function )
    }
    
    // 有人退出群聊
    func xmppRoom(_ sender: XMPPRoom, occupantDidLeave occupantJID: XMPPJID, with presence: XMPPPresence) {
        debugPrint(#function)
    }
    
    // MARK: - 有人在群里面发言
    func xmppRoom(_ sender: XMPPRoom, didReceive message: XMPPMessage, fromOccupant occupantJID: XMPPJID) {
        debugPrint( #function,"是谁在群聊中说话" )
    }
    
    
}


// MARK: - XMPPRoomStorage
extension ViewController: XMPPRoomStorage {
    
    func configure(withParent aParent: XMPPRoom, queue: DispatchQueue) -> Bool {
        debugPrint( #function )
        return true
    }
    
    func handle(_ presence: XMPPPresence, room: XMPPRoom) {
        debugPrint(presence.xmlString,room.roomJID.full)
        debugPrint( #function )
    }
    
    func handleIncomingMessage(_ message: XMPPMessage, room: XMPPRoom) {
        debugPrint(message.xmlString,room.roomJID.full)
        debugPrint( #function )
    }
    
    func handleOutgoingMessage(_ message: XMPPMessage, room: XMPPRoom) {
        debugPrint(message.xmlString,room.roomJID.full)
        debugPrint( #function )
    }
    
    func handleDidLeave(_ room: XMPPRoom) {
        debugPrint(room.roomJID.full)
        debugPrint( #function )
    }
    
    
}
// MARK: - XMPPStreamDelegate
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
        debugPrint("接收message", message.xmlString)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        debugPrint("接收presence", presence.xmlString)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        debugPrint("接收iq", iq.xmlString)
        return true
    }
    
//    func xmppStream(_ sender: XMPPStream, willSend message: XMPPMessage) -> XMPPMessage? {
//
//        debugPrint(message.xmlString, " --- ", message.stringValue)
//        return message
//    }
    
}

// MARK: - XMPPRosterDelegate
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
        
        debugPrint("获取好友进行中",item.xmlString)
        
        let sub = item.attribute(forName: "subscription")?.stringValue
        // 互相订阅才是好友
        if sub != "both" {
            return
        }
        
        let jidString = item.attribute(forName: "jid")?.stringValue
        debugPrint(jidString)
        let jid = XMPPJID.init(string: jidString!, resource: resource)
        debugPrint("好友", jid)
        if rosterArray.contains(jid!) {
            return
        }
        
        self.rosterArray.append(jid!)
        
    }
    
    
    // MARK: - 接收到好友请求
    func xmppRoster(_ sender: XMPPRoster, didReceivePresenceSubscriptionRequest presence: XMPPPresence) {
        debugPrint("接收到好友请求")
        
        // - 拒绝
//        self.roster?.rejectPresenceSubscriptionRequest(from: presence.from!)
        
        // - 接受
        self.roster?.acceptPresenceSubscriptionRequest(from: presence.from!, andAddToRoster: true)
        
    }
    
}


