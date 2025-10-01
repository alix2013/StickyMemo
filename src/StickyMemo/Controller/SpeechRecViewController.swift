

//
//  SpeechRecViewController.swift
//  myAudioRecord
//
//  Created by alex on 2018/2/14.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

import Speech

struct AudioSegementFile{
    var fileURL: URL
    var startSeconds:Int64
    var endSeconds:Int64
}

class SpeechRecViewController:UIViewController,SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate{
    
    private var recognitionRequest: SFSpeechURLRecognitionRequest?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var memoView:MemoView? {
        didSet{
            guard let memoView = memoView else { return }
            self.translatedTextView.backgroundColor =  memoView.memo.backgroundImage.tintColor //memoView.textView.backgroundColor   //
            self.translatedTextView.textColor = memoView.textView.textColor
            self.translatedTextView.font = memoView.textView.font
            self.translatedTextView.text = memoView.textView.text
        }
    }
    var startTime:Int64 = 0 {
        didSet{
            self.labelStartTimeValue.text = self.formatedTimeString(TimeInterval(startTime))
        }
    }
    var endTime:Int64 = 0 {
        didSet {
            self.labelEndTimeValue.text = self.formatedTimeString(TimeInterval(endTime))
        }
    }
    
    var timer:Timer = Timer()
    var segmentSeconds: Int = 10
    var audioSegementFileList:[AudioSegementFile] = []
    
    var fileURL:URL? {
        didSet{
            guard let fileURL =  fileURL else { return }
            let asset : AVAsset = AVAsset(url: fileURL)
//            Util.printLog("fileURL duration:\(asset.duration.seconds)")
            let seconds = asset.duration.seconds
//            self.labelEndTimeValue.text = self.formatedTimeString(seconds)
            self.totalDuration = Int64(seconds)
            self.endTime = Int64(seconds)
//            let fileName = fileURL.lastPathComponent
//            exportAsset(asset, fileName: fileName, trimDuration: 20)
        }
    }
    
    var isRuning:Bool = false {
        didSet{
            if isRuning {
                self.startButton.setImage(UIImage(named:"button_speech_stop"), for: .normal)
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: #selector(timerUpdate), userInfo: nil, repeats: true)
                
            }else{
                self.startButton.setImage(UIImage(named:"button_speech_start"), for: .normal)
                self.timer.invalidate()
                
                self.recognitionTask?.cancel()
                self.recognitionTask = nil
                self.recognitionRequest = nil
                self.speechRecognizer = nil
                
//                if let text = self.labelTranscript.text, text != "" {
//                    self.translatedTextView.insertText(text)
//                }
            }
        }
    }
    
    var currentProgressValue:Float = 0
    var totalDuration:Int64 = 0
    
    deinit {
        //todo delete files
        Util.printLog("deinit called")
    
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        self.recognitionRequest = nil
        self.speechRecognizer = nil
        
        //remove files
        if let fileName = self.fileURL?.lastPathComponent {
            self.removeTempM4AFiles(fileName)
        }
//        for url in self.trimFileURLs {
//            self.removeFile(url)
//            Util.printLog("remove url file:\(url)")
//        }
    }
    
    var labelStartTimeValue:UILabel = {
        let v = UILabel()
        v.text = "00:00"
        v.textAlignment = .right
        v.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
        v.adjustsFontSizeToFitWidth = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var labelEndTimeValue:UILabel = {
        let v = UILabel()
        v.text = "00:00"
        v.textAlignment = .right
        v.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
        v.adjustsFontSizeToFitWidth = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
//    var labelStartTimeTitle:UILabel = {
//        let v = UILabel()
//        //todo i18n
//        v.text = "" //Start Time"
//        return v
//    }()
    
//    lazy var sliderStart:UISlider = {
//       let v = UISlider()
//        v.value = 0
//        v.addTarget(self, action: #selector(startSliderValueChanged), for: .valueChanged)
//        v.addTarget(self, action: #selector(startSliderTouchUp), for: .touchUpInside)
//        return v
//    }()
    
    
//    lazy var leftStackView:UIStackView = {
//        let v = UIStackView(arrangedSubviews: [self.labelStartTimeTitle,self.labelStartTimeValue, self.sliderStart])
//        v.axis = .vertical
//        v.distribution = .fillEqually
//
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
    
//    var labelEndTimeTitle:UILabel = {
//        let v = UILabel()
//        //todo i18n
//        v.text = "" //End Time"
//        return v
//    }()
    
    
    
//    lazy var sliderEnd:UISlider = {
//        let v = UISlider()
//        v.value = 1
//        v.addTarget(self, action: #selector(endSliderValueChanged), for: .valueChanged)
//        v.addTarget(self, action: #selector(endSliderTouchUp), for: .touchUpInside)
//        return v
//    }()
    
    
//    lazy var rightStackView:UIStackView = {
//        let v = UIStackView(arrangedSubviews: [self.labelEndTimeTitle,self.labelEndTimeValue, self.sliderEnd])
//        v.axis = .vertical
//        v.distribution = .fillEqually
//
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
    
    lazy var progressView:UIProgressView = {
        let v = UIProgressView(frame:CGRect(x: 0, y: 66, width: self.view.frame.width, height: 2))
        v.progressViewStyle = .bar
        v.backgroundColor = .white

        v.tintColor = .red
        v.progress = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var labelTranscript:UILabel = {
        let v = UILabel(frame:CGRect(x: 0, y: 300, width:  self.view.frame.width, height: 200))
        v.numberOfLines = 0
        //        v.backgroundColor = .red
        v.translatesAutoresizingMaskIntoConstraints = false
        v.adjustsFontSizeToFitWidth = true
//        v.backgroundColor =
        v.textColor = .gray  //UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
        return v
    }()
    
    var translatedTextView: UITextView = {
        let v = UITextView(frame:CGRect(x: 0, y: 150, width: 300, height: 150))
//        v.backgroundColor = UIColor.cyan

        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    //    var colorView: UIView!
    var startButton: UIButton = {
        let v = UIButton(frame:CGRect(x: 10, y: 66, width: 100, height: 100))
//        v.backgroundColor = .blue
//        v.setTitle("Start", for: .normal)
        v.setImage(UIImage(named:"button_speech_start"), for: .normal)
        v.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        v.layer.cornerRadius = 50
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    @objc func timerUpdate(){
//        Util.printLog("timer update")
        let value = self.progressView.progress + 0.01
        if value < self.currentProgressValue {
            self.updateProgressValue(value)
        }
    }
    

    func getStartTime() -> Int64 {
//        let value = self.totalDuration * Double(self.sliderStart.value)
//        return Int64(value)
         return self.startTime
    }
    
    func getEndTime() -> Int64 {
//        let value = self.totalDuration * Double(self.sliderEnd.value)
//        return min(Int64(value) + 1, Int64(self.totalDuration))
        return self.endTime
    }
    
    
    func generateSegmentFileList() -> [AudioSegementFile] {
        
        var fileList:[AudioSegementFile] = []
        guard let fileURL = self.fileURL else {
            return fileList
        }
        let tempDir = FileManager.default.temporaryDirectory
    
        var startTime = getStartTime()
        let endTime = getEndTime()
        
        while startTime < endTime {
            
            let endSec = Int64( min(startTime + Int64(self.segmentSeconds), Int64(endTime)))
            
//            if ( endTime - startTime ) < Int64( 10 ) {
//                endSec = endTime
//            }
            
            let fileName = fileURL.lastPathComponent
            let formatter = NumberFormatter()
            formatter.minimumIntegerDigits = 5
            let formatedNumString = formatter.string(from: NSNumber(value: startTime)) ?? "\(startTime)"
            let outputURL =  tempDir.appendingPathComponent("\(fileName)-\(formatedNumString).m4a")
            
            let segment = AudioSegementFile(fileURL: outputURL, startSeconds: startTime, endSeconds: endSec)
            removeFile(outputURL)
//            startTime = startTime + self.segmentSeconds
            startTime = endSec
//            self.audioSegementFileList.append(segment)
            fileList.append(segment)
        }
        
        return fileList
    }
    
    //recursive process all files
    func exportAllFiles(_ sourceFileURL:URL, segmentFiles:[AudioSegementFile],number: Int, complete:( () -> Void)? ) {
        if number >= segmentFiles.count  {
            complete?()
            return
        }else{
            let segmentFile = segmentFiles[number]
            self.exportFile(sourceFileURL, outfileURL: segmentFile.fileURL, startSecond:segmentFile.startSeconds, endSecond:segmentFile.endSeconds) { error in
                
                self.exportAllFiles(sourceFileURL,segmentFiles:segmentFiles, number: (number + 1),complete:complete)
            }
        }
    }
    
    
    func syncExportAllFiles(_ sourceFileURL:URL, segmentFiles:[AudioSegementFile],number: Int, complete:( () -> Void)? ) {
        
        let group = DispatchGroup()
        for segmentFile in segmentFiles {
            group.enter()
            
            self.exportFile(sourceFileURL, outfileURL: segmentFile.fileURL, startSecond:segmentFile.startSeconds, endSecond:segmentFile.endSeconds) { error in
            group.leave()
            }
        }
        group.notify(queue: .main, execute: { complete?() })
    }
    
    
    
    func exportFile(_ sourceFileURL:URL, outfileURL: URL, startSecond:Int64, endSecond:Int64, complete:((Error?)->Void)?){
        Util.printLog("==========start export file to :\(outfileURL)")
//        guard let fileURL = self.fileURL else {
//            let error = NSError(domain: "fileURLNil", code: -10000, userInfo: nil)
//            complete?(error)
//            return }
        
        let asset = AVAsset(url: sourceFileURL)
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileType.m4a
            exporter.outputURL = outfileURL
            
            let startTime = CMTimeMake(value: startSecond, timescale: 1)
            let stopTime = CMTimeMake(value: endSecond, timescale: 1)
            exporter.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
            
            // do it
            
            exporter.exportAsynchronously(completionHandler: {
//                Util.printLog("export complete \(exporter.status)")
                
                switch exporter.status {
                case  AVAssetExportSession.Status.failed:
                    
                    if let e = exporter.error {
                        Util.printLog("need attention,export failed \(e)")
                        Util.saveAccessLog("exportFile*error",memo:"Error:\(e) -->\(#function)-\(#line)")
                        

                        complete?(e)
                    }
                    
                case AVAssetExportSession.Status.cancelled:
                    Util.printLog("export cancelled \(String(describing: exporter.error))")
                    complete?(exporter.error)
                default:
                    Util.printLog("======export complete:\(outfileURL.path)")
                    complete?(nil)
                }
            })
        } else {
            Util.printLog("need attention,cannot create AVAssetExportSession for asset \(asset)")
            Util.saveAccessLog("exportFile*error",memo:"Error at create AVAssetExportSession  -->\(#function)-\(#line)")
            
            let error = NSError(domain: "AVAssetExportSessionCreateFailed", code: -10000, userInfo: nil)
            complete?(error)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Util.saveAccessLog("SpeechRec",memo:"Access SpeechRec:\(#file)-\(#function)-\(#line)")
        Util.saveAccessLog("SpeechRec",memo:"Access SpeechRec:\(#function)-\(#line)")
        self.view.backgroundColor = .white
        setupNavButtonItems()
        setupViews()
        
        requestPermission()
        
        self.navigationItem.prompt = Appi18n.i18n_speechNeedInternet
        //        self.requestSpeechAuthorization()
    }
    
    func setupNavButtonItems() {
       
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //self.navigationItem.rightBarButtonItem = UIBar
        
        let settingButton = UIButton(type: .system)
        settingButton.setImage(UIImage(named:"button_setting"), for: .normal)
        settingButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        settingButton.addTarget(self, action: #selector(settingButtonTap), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: settingButton)]
        
    }
    
    @objc func settingButtonTap(){
        let vc = SpeechSettingVC()
        vc.totalDuration = self.totalDuration
        vc.startTime = self.startTime
        vc.endTime = self.endTime
        vc.segmentSeconds = self.segmentSeconds
        vc.speechRecViewController = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func setupViews(){
        
        self.view.addSubview(self.startButton)
        self.view.addSubview(self.translatedTextView)
        self.view.addSubview(self.labelTranscript)
        self.view.addSubview(progressView)
        
        self.view.addSubview(self.labelStartTimeValue)
        self.view.addSubview(self.labelEndTimeValue)
        
//        self.view.addSubview(leftStackView)
//        self.view.addSubview(rightStackView)
        [
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 100),
            startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            startButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            
            labelTranscript.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 20),
            labelTranscript.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -20),
            labelTranscript.topAnchor.constraint(equalTo: self.startButton.bottomAnchor, constant: 10),
            labelTranscript.heightAnchor.constraint(equalToConstant: 50),
            
            progressView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -20),
            progressView.topAnchor.constraint(equalTo: self.labelTranscript.bottomAnchor, constant: 0),
            progressView.heightAnchor.constraint(equalToConstant: 1),
            
            translatedTextView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 20),
            translatedTextView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -20),
            translatedTextView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 0),
            translatedTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
            
            labelStartTimeValue.trailingAnchor.constraint(equalTo: startButton.leadingAnchor, constant: -20),
            labelStartTimeValue.centerYAnchor.constraint(equalTo: startButton.centerYAnchor, constant: 0),
            
            
            labelEndTimeValue.leadingAnchor.constraint(equalTo: startButton.trailingAnchor, constant: 20),
            labelEndTimeValue.centerYAnchor.constraint(equalTo: startButton.centerYAnchor, constant: 0),
            
            
//            leftStackView.trailingAnchor.constraint(equalTo: self.startButton.leadingAnchor, constant: -10),
//            leftStackView.topAnchor.constraint(equalTo: self.startButton.topAnchor, constant: 0),
//            leftStackView.bottomAnchor.constraint(equalTo: self.startButton.bottomAnchor, constant: 0),
//            leftStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
//
//            rightStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
//            rightStackView.topAnchor.constraint(equalTo: self.startButton.topAnchor, constant: 0),
//            rightStackView.bottomAnchor.constraint(equalTo: self.startButton.bottomAnchor, constant: 0),
//            rightStackView.leadingAnchor.constraint(equalTo: self.startButton.trailingAnchor, constant: 10),
            
            ].forEach{
                $0.isActive = true
        }
        
    }
    
    func updateProgressValue(_ value:Float){
        DispatchQueue.main.async {
//            UIView.animate(withDuration: 10, animations: {
                self.progressView.progress = value
//            })
        }
    }
    
    func removeTempM4AFiles(_ fileNamePrefix:String){
        let tempDirURL = FileManager.default.temporaryDirectory
        let tempPath = tempDirURL.path
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: "\(tempPath)")
//            Util.printLog("all files in temp: \(fileNames)")
            for fileName in fileNames {
                if (fileName.hasSuffix(".m4a") && fileName.hasPrefix("\(fileNamePrefix)-"))
                {
                    let filePathName = "\(tempPath)/\(fileName)"
                    Util.printLog("======Delete file: \(filePathName)")
                    try FileManager.default.removeItem(atPath: filePathName)
                }
            }
        } catch {
            Util.printLog("Could not clear temp folder: \(error)")
        }
    }
    
    func removeFile(_ fileURL: URL) {
        //if exist, then delete it
        Util.printLog("removeFile called:\(fileURL.path)")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            Util.printLog("file exists, removing \(fileURL.absoluteString)")
            do {
                if try fileURL.checkResourceIsReachable() {
                    Util.printLog("is reachable")
                }
                
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch {
                Util.printLog("Error could not remove \(fileURL)")
                Util.printLog(error.localizedDescription)
            }
        }
    }
    
  
    func recognizeSpeechFile(fileURL: URL,completeHandler:@escaping ((Error? ) -> Void) ) {
        //        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
//        guard let speechRecognizer = SFSpeechRecognizer(), speechRecognizer.isAvailable else {
//            Util.printLog("speechRecognizer is unavailable!")
//            return
//        }
        Util.printLog("=====start recognize file:\(fileURL.lastPathComponent)")
        self.speechRecognizer = SFSpeechRecognizer()
        guard let isTrue = self.speechRecognizer?.isAvailable, isTrue  else {
            Util.printLog("speechRecognizer is unavailable!")
            return
        }
        self.speechRecognizer?.delegate = self
        
        self.recognitionRequest = SFSpeechURLRecognitionRequest(url: fileURL)
        guard let recognitionRequest = self.recognitionRequest else {
            Util.printLog("recognitionRequest is nil")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest)
        { (result, error) in
//            guard let result = result else {
//                if let error = error {
//                    Util.printLog("get error in recognizeSpeechFile:\(error.localizedDescription)")
//                    //                completeHandler()
//                    if let text = self.labelTranscript.text {
//                        self.translatedTextView.insertText(text)
//                    }
//                    completeHandler(error)
//
//                }else {
//                    completeHandler(nil)
//                }
//                return
//            }
//            Util.printLog(result.bestTranscription.formattedString)
//            self.labelTranscript.text = result.bestTranscription.formattedString
//            if result.isFinal {
//                self.translatedTextView.insertText(result.bestTranscription.formattedString)
//                completeHandler(nil)
//                return
//            }
            
            if let error = error {
//                Util.printLog("get error in recognizeSpeechFile:\(error.localizedDescription)")
                Util.printLog("get error in recognizeSpeechFile:\(error)")
                //                completeHandler()
                if let text = self.labelTranscript.text {
                    self.translatedTextView.insertText(text)
//                    self.labelTranscript.text = error.localizedDescription
                    UIUtil.displayToastMessageAtTop(error.localizedDescription,duration: 5, completeHandler: nil)
                    Util.saveAccessLog("SpeechRecg*error",memo:"Error:\(error) --> \(#function)-\(#line)")
                    
                }
                completeHandler(error)
            }else{
                if let result = result {
                    Util.printLog(result.bestTranscription.formattedString)
                    self.labelTranscript.text = result.bestTranscription.formattedString
                    
                    //for every word
//                    var lastString: String = ""
//                    let bestString = result.bestTranscription.formattedString
//                    for segment in result.bestTranscription.segments {
//                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
//                        lastString = bestString.substring(from: indexTo)
//                        print("++++++lastString:\(lastString)")
//                    }
                    
                    if result.isFinal {
                        self.translatedTextView.insertText(result.bestTranscription.formattedString)
                        self.labelTranscript.text = ""
                        completeHandler(nil)
                        return
                    }
                }else{
                    completeHandler(nil)
                }
            }
        }
    }
    
    
    @objc func startButtonTapped(_ sender:UIButton) {
        UIUtil.animateButton(sender)
        guard let fileURL  = self.fileURL else { return }
        
        self.isRuning = !self.isRuning
        
        self.labelTranscript.text = ""
        self.progressView.progress = 0
        
        
        //generate export file list
        self.audioSegementFileList = generateSegmentFileList()
    
//        for v in self.audioSegementFileList {
//            Util.printLog(v)
//        }
//
        let sortedFileList = self.audioSegementFileList.sorted{  return $0.startSeconds < $1.startSeconds }
        Util.printLog("============sorted file list:")
        for v in sortedFileList {
            Util.printLog(v)
        }

//        self.exportAllFiles(fileURL, segmentFiles: sortedFileList, number: 0 ) {
//            Util.printLog("==============export all files finished=========)")
//            //        let urls = self.trimFileURLs.sorted{ return $0.path < $1.path }
//            let urls = sortedFileList.map{ return $0.fileURL }
//            //        self.currentProgressValue = Float(1 / urls.count)
//            self.recognizeAllFiles(urls, number: 0){
//                DispatchQueue.main.async {
//                    Util.printLog("recognizeAllFiles completed!")
//                    self.isRuning = false
//                    self.updateProgressValue(1)
//                }
//            }
//        }
//
        
        self.syncExportAllFiles(fileURL, segmentFiles: sortedFileList, number: 0 ) {
            Util.printLog("==============export all files finished=========)")
            //        let urls = self.trimFileURLs.sorted{ return $0.path < $1.path }
            let urls = sortedFileList.map{ return $0.fileURL }
            //        self.currentProgressValue = Float(1 / urls.count)
            self.recognizeAllFiles(urls, number: 0){
                DispatchQueue.main.async {
                    Util.printLog("=======recognizeAllFiles completed!")
                    self.isRuning = false
                    self.updateProgressValue(1)
                }
            }
        }
        
        
        
    }
    
    func recognizeAllFiles(_ urls:[URL], number: Int, complete:( ()->Void)? ) {
//        self.updateProgressValue( Float(number) / Float(urls.count ) )
        self.currentProgressValue = Float(number + 1) / Float(urls.count )
        if !self.isRuning {
            self.recognitionTask?.cancel()
            
            self.recognitionTask = nil
            self.recognitionRequest = nil
            self.speechRecognizer = nil
        
            complete?()
            return
        }
        
        if number >= urls.count  {
            complete?()
            return
        }else{
            self.recognizeSpeechFile(fileURL: urls[number]) { error in
                self.recognizeAllFiles(urls, number: (number + 1),complete:complete)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    

    func requestPermission(){
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if (authStatus == .authorized) {
                self.speechRecognizer = SFSpeechRecognizer()
                self.speechRecognizer?.delegate = self
                guard let speechRecognizer = self.speechRecognizer else {
                    Util.printLog("Speech recognizer is not available for current locale!")
                    return
                }
                
                // Check the availability. It currently only works on the device
                if (speechRecognizer.isAvailable == false) {
                    Util.printLog("Speech recognizer is not available for this device!")
                    return
                }
//                self.speechRecognizer = speechRecognizer
//                self.speechRecognizer?.delegate = self
            }else{
                Util.printLog("No permission")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.memoView?.textView.text = self.translatedTextView.text
        
        Util.printLog("viewWillDisappear called")
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        self.recognitionRequest = nil
        self.speechRecognizer = nil
    }
    
   
    func formatedTimeString(_ time:TimeInterval) -> String {
        if time >= 3600 {
            let hours = Int(time) / 3600
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }else{
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i:%02i",  minutes, seconds)
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Util.printLog("SpeechRecognizer available: \(available)")
    }
    
    
    // MARK: Speech Recognizer Task Delegate
    
    // Called when the task first detects speech in the source audio
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        Util.printLog("speechRecognitionDidDetectSpeech")
    }
    
    
    // Called for all recognitions, including non-final hypothesis
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        
        Util.printLog("speechRecognitionTask called")
    }
    
    
    // Called only for final recognitions of utterances. No more about the utterance will be reported
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        Util.printLog("speechRecognitionTask ")
    }
    
    
    // Called when the task is no longer accepting new audio but may be finishing final processing
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        Util.printLog("speechRecognitionTaskFinishedReadingAudio called")
    }
    
    
    // Called when the task has been cancelled, either by client app, the user, or the system
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        Util.printLog("speechRecognitionTaskWasCancelled called")
    }
    
    
    //    @objc func endSliderTouchUp(sender:UISlider) {
    //        let value = self.totalDuration * Double(sender.value)
    //
    //        if Double(sender.value) <=  Double(self.sliderStart.value) {
    //            sender.value = 1
    //            self.labelEndTimeValue.text = self.formatedTimeString(self.totalDuration)
    //        }else {
    //            self.labelEndTimeValue.text = self.formatedTimeString(value)
    //        }
    //    }
    
    //    @objc func startSliderTouchUp(sender:UISlider) {
    //        let value = self.totalDuration * Double(sender.value)
    //        if Double(sender.value) >= Double(self.sliderEnd.value) {
    //            sender.value  = 0
    //            self.labelStartTimeValue.text = "00:00"
    //        }else{
    //            self.labelStartTimeValue.text = self.formatedTimeString(value)
    //        }
    //    }
    
    //    @objc func startSliderValueChanged(sender:UISlider){
    //        let value = self.totalDuration * Double(sender.value)
    //        self.labelStartTimeValue.text = self.formatedTimeString(value)
    //    }
    
    //    @objc func endSliderValueChanged(sender:UISlider){
    //        let value = self.totalDuration * Double(sender.value)
    //        self.labelEndTimeValue.text = self.formatedTimeString(value)
    //    }
    
    
    
  
}


