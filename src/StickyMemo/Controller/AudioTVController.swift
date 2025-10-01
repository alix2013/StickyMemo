//
//  myAudioTVController.swift
//  myAudioRecord
//
//  Created by alex on 2018/2/8.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit
import AVFoundation

class AudioTVController:UITableViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    
    var recordingSession : AVAudioSession! // = AVAudioSession()
    var audioRecorder    :AVAudioRecorder! // = AVAudioRecorder()
    var audioPlayer:    AVAudioPlayer! // = AVAudioPlayer()
    
    var audioPlayerLaunch:AudioPlayerLaunch?
    
    let cellID = "CellID"
    var settings :[String : Int] = {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        return settings
    }()
    
    var memoView:MemoView?
    var cdMemo:CDMemo? {
        didSet{
            guard let cdMemo = cdMemo else { return }
            if let audios = cdMemo.audios,let cdAudios = Array(audios) as? [CDAudio]{
                let sortedList = cdAudios.sorted{
                    if let a = $0.createAt, let b = $1.createAt {
                        return a > b
                    }else{
                        return true
                    }
                }
                self.cdAudioList = sortedList
                
                for cdAudio in sortedList {
                    if !cdAudio.writeContentToFile() {
                        Util.printLog("need attention, write contentToFile failed")
                        Util.saveAccessLog("writeContentTofile*error",memo:"Error at audio writeContentTofile -->\(#function)-\(#line)")
                    }
//                    self.tableView.reloadData()
                }
            }
        }
    }

    var cdAudioList:[CDAudio]?{
        didSet{
            guard let _ = cdAudioList else {
                return
            }
            self.tableView.reloadData()
//            for cdAudio in cdAudioList {
//                if !cdAudio.writeContentToFile() {
//                    Util.printLog("need attention, write contentToFile failed")
//                }
//                self.tableView.reloadData()
//            }
        }
    }
    
    lazy var audioPlayerView:AudioPlayerView = {
        let v = AudioPlayerView(frame:CGRect(x: 0, y: 250, width: self.view.frame.width, height: 100))
        return v
    }()
    
    //for show time
    var timer  = Timer()
    var durationSeconds:Int = 0
    
    
    
    var startRecordTime:Date = Date()
    
    var isPause:Bool = false {
        didSet{
            if isPause {
              self.buttonPause.setImage(UIImage(named:"button_resume")?.withRenderingMode(.alwaysTemplate), for: .normal)
                
            }else{
              self.buttonPause.setImage(UIImage(named:"button_pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }
    
    var isRecording:Bool = false {
        didSet{
            if isRecording {
                self.buttonPause.isHidden = false
                startRecordTime = Date()
//                Util.printLog("startRecordTime set :\(startRecordTime)")
//                self.timer.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: #selector(timerUpdate), userInfo: nil, repeats: true)
            }else{
                self.buttonPause.isHidden = true
                do {
                    let data = try Data(contentsOf: self.audioFileURL)
                    if let cdMemo = self.cdMemo {
                        let cdAudio = AudioService().createCDAudio(cdMemo,createAt:startRecordTime, content: data, comment: "")
                        //                    self.cdAudioList?.append(cdAudio)
                        self.cdAudioList?.insert(cdAudio, at: 0)
                    }
                    
                    self.labelDuration.text = ""
                }
                catch let error as NSError {
                    Util.printLog("need attention save audio to db failed: \(error)")
                    Util.saveAccessLog("saveAudioToDB*error",memo:"Error:\(error)-->\(#function)-\(#line)")
                }
            }
        }
    }
    
    lazy var audioFileURL:URL = {
        //        let audioFilename = getDocumentDirectory().appendingPathComponent("recording.m4a")
        let audioFilename = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
        return audioFilename
    }()
    
    var labelDuration:UILabel = {
        let v = UILabel()
        v.textColor = .white
        v.textAlignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var buttonRecord:UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 100, height: 100))
//        v.setTitle("Record", for: .normal)
        v.setImage(UIImage(named:"button_record"), for: .normal)
        v.layer.cornerRadius = 50
        v.clipsToBounds = true
        v.addTarget(self, action: #selector(buttonRecordTap), for: .touchUpInside)
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
//        v.layer.borderColor = UIColor.white.cgColor
//        v.layer.borderWidth = 0
        return v
    }()
    
    lazy var buttonPause:UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 50, height: 50))
//        v.setTitle("Pause", for: .normal)
        v.setImage(UIImage(named:"button_pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
        v.tintColor = .white
        v.layer.cornerRadius = 25
        v.clipsToBounds = true
        v.addTarget(self, action: #selector(buttonPauseTap), for: .touchUpInside)
        v.backgroundColor = .blue
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()
    
    
    lazy var headerContainerView:UIView = {
       let v = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        v.backgroundColor = .black
        return v
    }()
    
    
    func setupTableView(){
        self.view.backgroundColor = .white
        self.tableView.register(AudioCell.self, forCellReuseIdentifier: cellID)
        self.tableView.tableFooterView = UIView(frame:.zero)
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension
    
    }
    
    func requestAudioPermission(){
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)),mode: AVAudioSession.Mode.default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission({ (allowed) in
                DispatchQueue.main.async {
                    if allowed {
                        Util.printLog("Allow")
                    } else {
                        Util.printLog("Dont Allow")
                    }
                }
            })
        } catch {
            Util.printLog("need attention,failed at recordingSession setCategory record!")
            Util.saveAccessLog("RecordingSession*error",memo:"Error:RecordingSession active -->\(#function)-\(#line)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavButtonItems()
        setupViews()
        setupTableView()
        requestAudioPermission()
    }
    
    func setupNavButtonItems() {
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDesktop) )
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeViewController) )
    }
    
    @objc func closeViewController(){
//        self.dismiss(animated: true)
        
        if let memoView = self.memoView {
            memoView.setAudioCount()
        }
        ButtonSoundSerive.buttonSoundSoso.play()
        dismiss(animated: true, completion:{self.memoView?.restoreButtonLocation()})
        
    }
    
    func setupViews(){
        self.tableView.tableHeaderView = self.headerContainerView
        self.headerContainerView.addSubview(self.buttonRecord)
        
        [
            buttonRecord.widthAnchor.constraint(equalToConstant: 100),
            buttonRecord.heightAnchor.constraint(equalToConstant: 100),
            buttonRecord.centerXAnchor.constraint(equalTo: headerContainerView.centerXAnchor, constant: 0),
            buttonRecord.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor, constant: 0),
            ].forEach{ $0.isActive = true}
        
        self.headerContainerView.addSubview(buttonPause)
        [
            buttonPause.widthAnchor.constraint(equalTo: buttonRecord.widthAnchor, multiplier: 0.5),
            buttonPause.heightAnchor.constraint(equalTo: buttonRecord.heightAnchor, multiplier: 0.5),
            buttonPause.centerXAnchor.constraint(equalTo: headerContainerView.centerXAnchor, constant: -80),
            buttonPause.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor, constant: 0),
            ].forEach{ $0.isActive = true}
        
    
        self.headerContainerView.addSubview(labelDuration)
        
        [
            labelDuration.widthAnchor.constraint(equalTo: headerContainerView.widthAnchor, multiplier: 1),
            labelDuration.heightAnchor.constraint(equalToConstant: 50),
            labelDuration.topAnchor.constraint(equalTo: buttonRecord.bottomAnchor, constant: 10),
            
            ].forEach{ $0.isActive = true}
        
    }
    
//    func getDocumentDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
////        return FileManager.default.temporaryDirectory
//    }
//
    func formatedTimeString(_ time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    @objc func timerUpdate(){
//        Util.printLog("timerUpdate")
//        let interval = Date().timeIntervalSince(self.startRecordTime)
        if self.isRecording && !self.isPause {
            durationSeconds += 1
            Util.printLog(formatedTimeString(TimeInterval(self.durationSeconds)))
            self.labelDuration.text = formatedTimeString(TimeInterval(self.durationSeconds))
        }
        
    }
    
    func startRecording() {
        self.isRecording = true
        let audioSession = AVAudioSession.sharedInstance()

        let url = self.audioFileURL
        do {
            audioRecorder = try AVAudioRecorder(url: url,settings: settings)
            audioRecorder.delegate = self
//            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
        } catch {
            finishRecording(success: false)
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
            
        } catch {
            
            Util.printLog("startRecording,error:\(error) ")
        }
    }
    
    
    func finishRecording(success: Bool) {
        
        audioRecorder.stop()
        if success {
//            Util.printLog(success)
//            Util.printLog("========url.last===:\(url.)")
//            let theFileName = (url as NSString).lastPathComponent
//            self.dataList.append(theFileName)
        } else {
            Util.printLog("finishRecording error.")
        }
//        audioRecorder = nil
        
        self.timer.invalidate()
        self.durationSeconds = 0
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Util.printLog("audioRecorderDidFinishRecording called,successFlag:\(flag)")
        if !flag {
            finishRecording(success: false)
        }
        else{
             finishRecording(success: true)
        }
        self.isRecording = false
    }
    
    @objc  func buttonPauseTap(_ sender: UIButton) {
        UIUtil.animateButton(sender)
        self.isPause = !self.isPause
        if self.audioRecorder.isRecording {
            
            self.audioRecorder.pause()
//            sender.setTitle("Resume", for: .normal)
        }else{
            self.audioRecorder.record()
        }
        
    }
        
    
    @objc  func buttonRecordTap(_ sender: UIButton) {
        UIUtil.animateButton(sender)
        if !self.isRecording {
//            self.buttonRecord.setTitle("Stop", for: UIControlState.normal)
            self.buttonRecord.setImage(UIImage(named:"button_stop"), for: .normal)
            self.startRecording()
        } else {
//            self.buttonRecord.setTitle("Record", for: UIControlState.normal)
            self.buttonRecord.setImage(UIImage(named:"button_record"), for: .normal)
            self.finishRecording(success: true)
        }
    }

//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        Util.printLog("willTransition called")
//        if let keyWindow = UIApplication.shared.keyWindow {
//            keyWindow.layoutIfNeeded()
//        }
//    }
}

extension AudioTVController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cdAudioList = self.cdAudioList else{
            return 0
        }
        return cdAudioList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! AudioCell
        guard let cdAudioList = self.cdAudioList else{
            return cell
        }
        
        let cdAudio = cdAudioList[indexPath.row]
        cell.cdAudio = cdAudio
        
        cell.buttonPlay.addTarget(self, action: #selector(buttonPlayTap), for: .touchUpInside)
        cell.buttonShare.addTarget(self, action: #selector(buttonShareTap), for: .touchUpInside)
        cell.buttonTrash.addTarget(self, action: #selector(buttonTrashTap), for: .touchUpInside)
        
        cell.buttonSpeech.addTarget(self, action: #selector(buttonSpeechTap), for: .touchUpInside)
        cell.buttonComment.addTarget(self, action: #selector(buttonCommentTap), for: .touchUpInside)
        
        
//        cell.textLabel?.text =  cdAudio.getAudioFileName() //audio.displayName

        return cell
    }
    

    func getParentCell(_ sender: UIView ) -> UITableViewCell? {
        var parentView = sender.superview
        while !( parentView is UITableViewCell ) {
            // first parent is UITableViewCellContentView
            parentView = parentView?.superview
        }
        return parentView as? UITableViewCell
    }
    
    func getParentCellIndexPath(_ sender:UIView) -> IndexPath? {
        if let cell = self.getParentCell(sender) {
            return self.tableView.indexPath(for: cell)
        }
        return nil
    }
    
    @objc func buttonCommentTap(_ sender:UIButton) {
        UIUtil.animateButton(sender)
        guard let cdAudioList = self.cdAudioList else { return }
        if let indexPath = self.getParentCellIndexPath(sender), let cell = self.getParentCell(sender) {
            //            Util.printLog(indexPath.row)
            let cdAudio = cdAudioList[indexPath.row]
            let comment = cdAudio.comment ?? ""
            
            let alert = UIAlertController(title: Appi18n.i18n_audioComment, message: nil, preferredStyle: .alert)
            alert.addTextField { (tf) in
                tf.placeholder = Appi18n.i18n_audioComment
                if comment != "" {
                    tf.text = comment
                }
            }
            
            let okAction = UIAlertAction(title: Appi18n.i18n_ok, style: .default) { (_) in
                guard let inputText = alert.textFields?.first?.text
                    else { return }
//                cdAudio.comment = inputText
//                DBManager.saveContext()
                AudioService().saveComment(cdAudio,comment:inputText)
                if let cell = cell as? AudioCell {
                    cell.cdAudio = cdAudio
                }
                self.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
                //
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func buttonSpeechTap(_ sender:UIButton) {
        UIUtil.animateButton(sender)
        guard let cdAudioList = self.cdAudioList else { return }
        if let indexPath = self.getParentCellIndexPath(sender) {
            let cdAudio = cdAudioList[indexPath.row]
            guard let  soundURL = cdAudio.getAudioFileURL() else{ //,let displayName = cdAudio.getAudioFileName() else {
                return
            }
            let vc = SpeechRecViewController()
            vc.fileURL = soundURL
            vc.memoView = self.memoView
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    @objc func buttonPlayTap(_ sender:UIButton){
        UIUtil.animateButton(sender)
        guard let cdAudioList = self.cdAudioList else { return }
        if let indexPath = self.getParentCellIndexPath(sender), let cell = self.getParentCell(sender) {
            let cdAudio = cdAudioList[indexPath.row]
            guard let  soundURL = cdAudio.getAudioFileURL(),let displayName = cdAudio.getAudioFileName() else {
                return
            }
            let audioFile = AudioFile(url: soundURL, displayName: displayName)
            
//            audioPlayerLaunch = AudioPlayerLaunch(audioFile: audioFile)
//            //                audioPlayerLaunch?.show(locationY: cellFrame.minY)
//            audioPlayerLaunch?.show(locationY: 0)
            
            if let keyWindow = UIApplication.shared.keyWindow {
                let cellFrame = keyWindow.convert(cell.frame,from: cell.superview)
                audioPlayerLaunch = AudioPlayerLaunch(audioFile: audioFile)
                audioPlayerLaunch?.show(locationY: cellFrame.minY)

            }

        }
    }
    
    func deleteItem(at indexPath:IndexPath){
        guard let _ = self.cdAudioList else { return }
        if let cdAudio = self.cdAudioList?[indexPath.row] {
            let alert = UIAlertController(title: Appi18n.i18n_delete, message: Appi18n.i18n_confirmDelete, preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: Appi18n.i18n_ok, style: .destructive, handler: { action in
                //
                cdAudio.deleteFile()
                self.tableView.beginUpdates()
                self.cdAudioList?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .right)
                self.tableView.endUpdates()
                AudioService().deleteCDAudio(cdAudio)
            })
            
            let cancelAction = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel, handler: { action in
                
            })
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion:nil)
            
            
            
        }
    }
    @objc func buttonTrashTap(_ sender:UIButton){
        UIUtil.animateButton(sender)
        if let indexPath =  self.getParentCellIndexPath(sender) {
            self.deleteItem(at: indexPath)
        }
    }
    
    @objc func buttonShareTap(_ sender:UIButton){
        UIUtil.animateButton(sender)
        guard let _ = self.cdAudioList, let indexPath = self.getParentCellIndexPath(sender),let cdAudio = self.cdAudioList?[indexPath.row], let cell = self.getParentCell(sender) else { return }
        

        let shareObjects = cdAudio.getObjectsForShare()
        let activityViewController = UIActivityViewController(activityItems: shareObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = cell // so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceRect = cell.bounds
        activityViewController.popoverPresentationController?.permittedArrowDirections = []
        
        self.present(activityViewController, animated: true, completion: nil)
    
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteItem(at: indexPath)
            
        }
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cdAudioList = self.cdAudioList  else{
//            return
//        }
//
//        let cdAudio = cdAudioList[indexPath.row]
//
//        guard let  soundURL = cdAudio.getAudioFileURL(),let displayName = cdAudio.getAudioFileName() else {
//            return
//        }
//
//        let audioFile = AudioFile(url: soundURL, displayName: displayName)
//
////        audioPlayerLaunch = AudioPlayerLaunch(audioFile: audioFile)
////        audioPlayerLaunch?.show(locationY: 200)
//
//        if let cell = tableView.cellForRow(at: indexPath) {
//            if let keyWindow = UIApplication.shared.keyWindow {
//                let cellFrame = keyWindow.convert(cell.frame,from: cell.superview)
//                audioPlayerLaunch = AudioPlayerLaunch(audioFile: audioFile)
//                audioPlayerLaunch?.show(locationY: cellFrame.minY)
//            }
//
//        }
//
//    }
//
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
