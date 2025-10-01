//
//  AirTransferVC.swift
//  StickyMemo
//
//  Created by alex on 2018/2/22.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class AirTransferCell:UITableViewCell{

    var memo:Memo?{
        didSet{
            guard let memo = memo else { return }
            self.labelDate.attributedText = memo.updateDateAttributedText
            self.labelDate.backgroundColor = memo.backgroundImage.tintColor
            labelContentText.attributedText =  memo.contentAttributedText//memo.briefContentAttributedText//
            labelContentText.backgroundColor = memo.backgroundImage.tintColor
            
            //for selected background color, cell.selectionStyle, checkbox will not selected
            let bgColorView = UIView()
            bgColorView.backgroundColor = memo.backgroundImage.tintColor
            self.selectedBackgroundView = bgColorView
            
//            if memo.body.count > 10 {
//                for constraint in labelContentText.constraints {
//                    if constraint.firstAttribute == .height {
//                        constraint.constant = 300
//                        self.layoutIfNeeded()
//                    }
//                }
//            }
//
        }
    }
    
    lazy var labelDate: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        //        v.backgroundColor = .red
        v.numberOfLines = 0
        return v
    }()
    
    lazy var labelContentText: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        //        v.backgroundColor = .red
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    func setupViews(){

        contentView.addSubview(labelDate)
        contentView.addSubview(labelContentText)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelDate]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelContentText]))

//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[labelDate(20@700)][labelContentText]|", options:[], metrics:nil, views: ["labelContentText":labelContentText,"labelDate":self.labelDate]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[labelDate][labelContentText]|", options:[], metrics:nil, views: ["labelContentText":labelContentText,"labelDate":self.labelDate]))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//  if change struct to class, memoList didSet will not work???
struct ViewModelSelectMemo{
    var isSelected:Bool = false
    var memo:Memo
    init(memo:Memo, isSelected:Bool = false) {
        self.memo = memo
        self.isSelected = isSelected
    }
}

class AirTransferVC:UITableViewController {
    
    var boardViewController:BoardViewController?
    
    var memoList:[ViewModelSelectMemo] = [] {
        didSet{
            //            Util.printLog("*******meoList change, count:\(memoList.count)")
//            Util.printLog("####memoList.count:\(memoList.count)")
            let selected = memoList.filter{ return $0.isSelected}
            if selected.count > 0 && self.isConnected {
                self.transferBarItem.isEnabled = true
                self.navigationItem.title = "\(selected.count)"
            }else{
                self.transferBarItem.isEnabled = false
                self.navigationItem.title = ""
            }
        }
    }
    
    let serviceType = "stickymemo"
    let peerID:MCPeerID =  MCPeerID(displayName: UIDevice.current.name)
    lazy var mcSession:MCSession = {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    var mcAdvertiserAssistant:MCAdvertiserAssistant?
    
    
    var isConnected:Bool = false {
        didSet{
            if isConnected {
                DispatchQueue.main.async {
                    self.buttonConnect.setTitle(Appi18n.i18n_disconnectPeer, for: .normal)
                    self.tableView.setEditing(true, animated: true)

                    self.navigationItem.leftBarButtonItems = [self.selectAllBarItem,self.clearAllBarItem]
                    
                    self.lineConnectedView.isHidden = false
                    self.targetImageView.isHidden = false
                    self.labelTargetName.isHidden = false
                }
                
            }else{
                DispatchQueue.main.async {

                    self.buttonConnect.setTitle(Appi18n.i18n_connectToPeer, for: .normal)
                    self.tableView.setEditing(false, animated: true)

                    self.navigationItem.leftBarButtonItems = []
                    
                    self.lineConnectedView.isHidden = true
                    self.targetImageView.isHidden = true
                    self.labelTargetName.isHidden = true
                    
                    self.navigationItem.title = ""
                    for i in 0 ..< self.memoList.count {
                        self.memoList[i].isSelected = false
                    }
                }
                self.mcSession.disconnect()
            }
        }
    }
    
    var isStart:Bool = false {
        didSet{
            if isStart {
                DispatchQueue.main.async {
                    self.buttonStart.setTitle(Appi18n.i18n_disallowDiscover, for: .normal)
                    self.startAnimateSourceDevice()
                }
                startMC()
            }else{
                DispatchQueue.main.async {
                    self.buttonStart.setTitle(Appi18n.i18n_allowDiscover, for: .normal)
                    self.stopAnimateSourceDevice()
                }
                stopMC()
            }
        }
    }
    
    let lineConnectedView:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .green //UIColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 1) //.green //.green
        v.isHidden = true
        return v
    }()
    
    lazy var buttonStart:UIButton = {
        let v = UIButton()
        //        v.backgroundColor = .blue
        
        v.addTarget(self, action: #selector(buttonStartTap), for: .touchUpInside)
        v.setTitle(Appi18n.i18n_allowDiscover, for: .normal)
        v.translatesAutoresizingMaskIntoConstraints = false
        
        v.setTitleColor(AppDefault.themeColor, for: .normal)

        return v
    }()
    
    lazy var buttonConnect:UIButton = {
        let v = UIButton()
        //        v.backgroundColor = .blue
        v.addTarget(self, action: #selector(buttonConnectTap), for: .touchUpInside)
        v.setTitle(Appi18n.i18n_connectToPeer, for: .normal)
        v.translatesAutoresizingMaskIntoConstraints = false
        
        v.setTitleColor(AppDefault.themeColor, for: .normal)

        return v
    }()
    
    let cellID = "CellID"
    
    lazy var transferBarItem:UIBarButtonItem = {
        let v = UIBarButtonItem(title: Appi18n.i18n_airTransfer, style: .plain, target: self, action: #selector(transferDataTap))
        v.isEnabled = false
        return v
        
    }()
    
//    lazy var selectAllBarItem:UIBarButtonItem = {
//        let v = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectAllTap))
//        v.isEnabled = false
//        return v
//    }()
    
    lazy var selectAllBarItem:UIBarButtonItem = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named:"navbutton_selectall")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.frame = CGRect(x: 0, y: 0, width: 25 , height: 25)
        v.addTarget(self, action: #selector(selectAllTap), for: .touchUpInside)
//        v.isEnabled = false
        let buttonItem =  UIBarButtonItem(customView: v)
        return buttonItem
    }()
    
    lazy var clearAllBarItem:UIBarButtonItem = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named:"navbutton_clearselect")?.withRenderingMode(.alwaysOriginal), for: .normal)
        //        v.setImage(UIImage(named:"navbutton_selectall")?.withRenderingMode(.alwaysOriginal), for: .selected)
        
        v.frame = CGRect(x: 0, y: 0, width: 25 , height: 25)
        v.addTarget(self, action: #selector(clearAllTap), for: .touchUpInside)
//        v.isEnabled = false
        let buttonItem =  UIBarButtonItem(customView: v)
//        buttonItem.isEnabled = false
        return buttonItem
    }()
    
//    lazy var clearAllBarItem:UIBarButtonItem = {
//        let v = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllTap))
//        v.isEnabled = false
//        return v
//    }()
    
    
    //for gesture
    var fullScreenTextViewStartFrame:CGRect = .zero
    var isFullScreenTextViewShowing:Bool = false
    lazy var fullScreenTextView: UITextView = {
        let v = UITextView()
        v.isEditable = false
        //        v.translatesAutoresizingMaskIntoConstraints = false
        v.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        v.showsHorizontalScrollIndicator = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewTap2Guesture))
        tapGesture.numberOfTapsRequired = 2
        
        tapGesture.delegate = self
        v.addGestureRecognizer(tapGesture)
        //        v.gestureRecognizers = [tapGesture]
        return v
    }()
    
    func freshMemoData() {
        
        let memos = MemoService().queryAllUndeletedMemos()
//        self.memoList = memos.flatMap{return ViewModelSelectMemo(memo:$0)}
        self.memoList = memos.compactMap{return ViewModelSelectMemo(memo:$0)}
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        freshMemoData()
             //["A","B","C","D"].map{return ViewModelMemo(isSelected: false, body:$0)}
        self.view.backgroundColor = .white

        self.setupTableView()
        setupViews()
        setupNavBarItems()
        setupGesture()
        
        //save to clooud
        Util.saveAccessLog("AirTransfer",memo:"Access AirTransfer")
        
    }
//    deinit{
//        Util.printLog("AirTransferVC called")
//        self.stopMC()
//        self.mcAdvertiserAssistant = nil
//        self.boardViewController?.freshMemoView()
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if self.isStart {
//            stopAnimateSourceDevice()
//            startAnimateSourceDevice()
//        }
//    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stopMC()
        self.mcAdvertiserAssistant = nil
        self.boardViewController?.freshMemoView()
    }
    
    func startAnimateSourceDevice(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.repeat,.autoreverse,.curveEaseInOut], animations: {
                self.sourceImageView.transform = CGAffineTransform(scaleX: 1.07, y: 1.07)
        }, completion:nil)
    }
    
    func stopAnimateSourceDevice(){
//
//        self.sourceImageView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut,.beginFromCurrentState], animations: {
            self.sourceImageView.transform = CGAffineTransform.identity
        }, completion:nil)
        
    }
    
    func setupNavBarItems() {
        self.navigationItem.prompt = Appi18n.i18n_turnonWifi //"turn on WIFI and bluetooth"
        self.navigationItem.rightBarButtonItems = [self.transferBarItem]
//        self.navigationItem.leftBarButtonItems = [self.selectAllBarItem,self.clearAllBarItem]
    }
    
    @objc func transferDataTap(){
        for v in self.memoList {
            if v.isSelected {
//                Util.printLog("transfer \(v.memo.body)")
                if mcSession.connectedPeers.count > 0, let cdMemo = v.memo.cdMemo { //} let data = v.memo.body.data(using: .utf8) {
                    let jsonMemo = JSONMemo(cdMemo)
                    
                    //        return String(data: jsonData!, encoding: .utf8)!
                    do {
                        ButtonSoundSerive.playAlwaysRandomPiano()
                        let jsonData = try JSONEncoder().encode(jsonMemo)
                        try mcSession.send(jsonData, toPeers: mcSession.connectedPeers, with: .reliable)
                        DispatchQueue.main.async {
                            self.changeDeviceColor(jsonMemo)
                        }
                    }catch{
                        Util.printError("need attention error during send:\(error)")
                    }
                }
//                else{
//                    Util.printLog("*** you are not connected to another device")
//                }
            }
        }
    }
    
    func changeDeviceColor(_ jsonMemo:JSONMemo){
        if let colorHex = jsonMemo.backgroundImage.tintColorHex {
            let color = UIColor(hex: colorHex)
            self.sourceDeviceColorView.backgroundColor = color
            self.targetDeviceColorView.backgroundColor = color
        }
    }
    
    @objc func selectAllTap(_ sender:UIButton){
//        if !DefaultService.isvip(){
//            UIUtil.goPurchaseVIP(self)
//        }else{
            for i in 0 ..< self.memoList.count {
                self.memoList[i].isSelected = true
                self.tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
            }
//        }
    }
    
    @objc func clearAllTap(){
//        if !DefaultService.isvip(){
//            UIUtil.goPurchaseVIP(self)
//        }else{
            for i in 0 ..< self.memoList.count {
                self.memoList[i].isSelected = false
                self.tableView.deselectRow(at:  IndexPath(row: i, section: 0), animated: true)
            }
//        }
    }
    
    
    var labelSourceName:UILabel = {
        let v = UILabel()
        v.font = UIFont.preferredFont(forTextStyle: .footnote)
        v.text = UIDevice.current.name //"MyiPad" //
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var labelTargetName:UILabel = {
        let v = UILabel()
        v.font = UIFont.preferredFont(forTextStyle: .footnote)
        v.text = ""
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var sourceImageView:UIImageView = {
        let v = UIImageView(frame:CGRect(x: 0, y: 0, width: 50, height: 50))
        v.image = UIImage(named:"mobile_big")?.withRenderingMode(.alwaysTemplate)
        v.tintColor = UIColor(red: 192/255, green: 192/266, blue: 192/255, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let sourceDeviceColorView:UIView = {
       let v = UIView()
        v.backgroundColor = UIColor(red: 255/255, green: 158/255, blue: 51/255, alpha: 1)
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var targetImageView:UIImageView = {
        let v = UIImageView(frame:CGRect(x: 0, y: 0, width: 50, height: 50))
        v.image = UIImage(named:"mobile_big")?.withRenderingMode(.alwaysTemplate)
        v.tintColor = UIColor.black
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()
    
    let targetDeviceColorView:UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        v.backgroundColor = UIColor(red: 119/255, green: 231/255, blue: 254/255, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    @objc func buttonStartTap(){
        self.isStart = !self.isStart
        
    }
    
    @objc func buttonConnectTap(){
        if self.isConnected {
            self.mcSession.disconnect()
        }else{
            let mcBrowser = MCBrowserViewController(serviceType: self.serviceType, session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }
        
    }
    
    func startMC(){
        self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: self.serviceType, discoveryInfo: nil, session: self.mcSession)
//        self.mcAdvertiserAssistant?.delegate = self
        self.mcAdvertiserAssistant?.start()
        
    }
    func stopMC(){
        self.mcSession.disconnect()
        self.mcAdvertiserAssistant?.stop()
    }
    
    func setupTableView(){
        self.tableView.register(AirTransferCell.self, forCellReuseIdentifier: cellID)
        self.tableView.tableFooterView = UIView(frame:.zero)
        
        self.tableView.cellLayoutMarginsFollowReadableWidth = false

        let rowHeight = UIScreen.main.bounds.width > 500 ? 200 : 150
        self.tableView.rowHeight = CGFloat(rowHeight)
        //        self.tableView.estimatedRowHeight = 150
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
        //        tableView.setEditing(true, animated: false)
    }
    
    func setupViews(){
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        //        self.tableView.tableHeaderView = headerView
        //        headerView.backgroundColor = .black //AppDefault.themeColor //
        
        self.tableView.tableHeaderView = headerView
        
        let headerBackgroundView:UIImageView = {
            let v = UIImageView()
            v.image = UIImage(named:"airdrop_big")
            return v
        }()
        headerView.insertSubview(headerBackgroundView, at: 0)
        headerBackgroundView.frame = CGRect(x: 10, y: 10, width: headerView.frame.width - 20, height: headerView.frame.height - 20)
        
        headerBackgroundView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        headerView.addSubview(self.buttonStart)
        headerView.addSubview(self.buttonConnect)
        //        headerView.addSubview(self.labelConnected)
        
        headerView.addSubview(self.sourceImageView)
        headerView.addSubview(self.targetImageView)
        
        headerView.addSubview(self.labelSourceName)
        headerView.addSubview(self.labelTargetName)
        
        headerView.addSubview(self.lineConnectedView)
        
        sourceImageView.addSubview(sourceDeviceColorView)
        targetImageView.addSubview(targetDeviceColorView)
        
        [
            buttonStart.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 0),
            buttonStart.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 40),
            
            buttonConnect.topAnchor.constraint(equalTo: buttonStart.bottomAnchor, constant: 2),
            buttonConnect.centerXAnchor.constraint(equalTo: buttonStart.centerXAnchor, constant: 0),
            
            sourceImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            sourceImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: -100),
            sourceImageView.widthAnchor.constraint(equalToConstant: 30),
            sourceImageView.heightAnchor.constraint(equalToConstant: 50),
            
            
            targetImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            targetImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant:100),
            targetImageView.widthAnchor.constraint(equalToConstant: 30),
            targetImageView.heightAnchor.constraint(equalToConstant: 50),
            
            labelSourceName.topAnchor.constraint(equalTo: sourceImageView.bottomAnchor, constant: 5),
            labelSourceName.centerXAnchor.constraint(equalTo: sourceImageView.centerXAnchor, constant: 0),
            
            labelTargetName.topAnchor.constraint(equalTo: targetImageView.bottomAnchor, constant: 5),
            labelTargetName.centerXAnchor.constraint(equalTo: targetImageView.centerXAnchor, constant: 0),
            
            lineConnectedView.heightAnchor.constraint(equalToConstant: 2),
            lineConnectedView.leadingAnchor.constraint(equalTo: sourceImageView.trailingAnchor, constant: 5),
            lineConnectedView.trailingAnchor.constraint(equalTo: targetImageView.leadingAnchor, constant: -5),
            lineConnectedView.centerYAnchor.constraint(equalTo: sourceImageView.centerYAnchor, constant: 0),
            
            
            sourceDeviceColorView.leadingAnchor.constraint(equalTo: sourceImageView.leadingAnchor, constant: 5),
            sourceDeviceColorView.trailingAnchor.constraint(equalTo: sourceImageView.trailingAnchor, constant: -5),
            sourceDeviceColorView.topAnchor.constraint(equalTo: sourceImageView.topAnchor, constant: 6),
//            sourceDeviceColorView.bottomAnchor.constraint(equalTo: sourceImageView.bottomAnchor, constant: -5),
            sourceDeviceColorView.heightAnchor.constraint(equalTo: sourceImageView.heightAnchor, multiplier: 1/3, constant: 0),
            
            targetDeviceColorView.leadingAnchor.constraint(equalTo: targetImageView.leadingAnchor, constant: 5),
            targetDeviceColorView.trailingAnchor.constraint(equalTo: targetImageView.trailingAnchor, constant: -5),
            targetDeviceColorView.topAnchor.constraint(equalTo: targetImageView.topAnchor, constant: 6),

            targetDeviceColorView.heightAnchor.constraint(equalTo: targetImageView.heightAnchor, multiplier: 1/3, constant: 0),
            
            ].forEach{
                $0.isActive = true
        }
    }
    
}

extension AirTransferVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! AirTransferCell
        
        cell.memo = self.memoList[indexPath.row].memo
//        cell.textLabel?.text = self.memoList[indexPath.row].memo.body
        
        cell.isSelected = self.memoList[indexPath.row].isSelected
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Util.printLog("selected row:\(indexPath.row)")
        self.memoList[indexPath.row].isSelected = true
        let vMmemo = self.memoList[indexPath.row]
        self.sourceDeviceColorView.backgroundColor = vMmemo.memo.backgroundImage.tintColor
//        if !DefaultService.isvip(){ //just allow select one row for non-VIP user
//            let filter = self.memoList.filter{ return $0.isSelected}
//            if filter.count == 0 {
//                self.memoList[indexPath.row].isSelected = true
//            }else{
//                self.tableView.deselectRow(at: indexPath, animated: true)
//                UIUtil.goPurchaseVIP(self)
//            }
//        }else{
//            self.memoList[indexPath.row].isSelected = true
//        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        Util.printLog("deselected row:\(indexPath.row)")
        self.memoList[indexPath.row].isSelected = false
    }
}

extension AirTransferVC:MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Swift.Void){
        Util.printLog("didReceiveCertificate called")
        certificateHandler(true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        var connectedStr:String = ""
        Util.printLog("****connect state:\(state.rawValue)")
        switch state {
        case MCSessionState.connected:
            Util.printLog("Connected: \(peerID.displayName)")
            self.isConnected = true
            DispatchQueue.main.async {
                self.labelTargetName.text = peerID.displayName
//                self.lineConnectedView.backgroundColor = UIColor(red: 60/255, green: 79/255, blue: 113/255, alpha: 0.8) //.green
            }
            
        case MCSessionState.connecting:
            Util.printLog("Connecting: \(peerID.displayName)")
//            DispatchQueue.main.async {
//                self.labelTargetName.text = peerID.displayName
//                self.lineConnectedView.backgroundColor = .yellow
//            }
            
        case MCSessionState.notConnected:
            Util.printLog("Disconnected: \(peerID.displayName)")
            self.isConnected = false
            DispatchQueue.main.async {
                self.labelTargetName.text = peerID.displayName
//                self.lineConnectedView.backgroundColor = .red
            }
        @unknown default:
//            <#fatalError#>()
            Util.printLog("Unkown MCSessionState")
        }
//        DispatchQueue.main.async {
//            self.labelConnected.text = connectedStr
//        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

//        OperationQueue.main.addOperation {
        guard let boardViewController = self.boardViewController, let currentDesktop = boardViewController.currentDesktop else {
            Util.printError("NO current boardViewController in airVC")
            return
        }
        do{
            ButtonSoundSerive.playAlwaysRandomPiano()
            let jsonMemo = try JSONDecoder().decode(JSONMemo.self, from: data)
            jsonMemo.insertOrUpdate(currentDesktop)
             DispatchQueue.main.async{
                self.changeDeviceColor(jsonMemo)
                self.freshMemoData()
                self.tableView.reloadData()
            }
//            Util.printLog("******success get jsonMemo:\(jsonMemo.body)")
        }catch{
            Util.printError("need attention error during receive data:\(error)")
        }
//        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //        <#code#>
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

        Util.printLog("didStartReceivingResourceWithName, resouceName:\(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        Util.printLog("didFinishReceivingResourceWithName, resouceName:\(resourceName)")

    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}


