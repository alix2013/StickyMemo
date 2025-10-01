//
//  MemoViewSwipeExtension.swift
//  StickyMemo
//
//  Created by alex on 2018/1/22.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

extension MemoView:UIGestureRecognizerDelegate{
    
    //UITextView set delegate, so it can trigger with other outofbox gesture of UITextView,shouldRecognizeSimultaneouslyWith
    
//    lazy var textView: UITextView = {
//        let v = UITextView()
//        v.backgroundColor = .clear
//        //for swip gesture
//        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeHandler(_:)))
//        leftSwipeGesture.direction = .left
//        leftSwipeGesture.delegate = self
//        v.addGestureRecognizer(leftSwipeGesture)
//
//        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeHandler(_:)))
//        rightSwipeGesture.direction = .right
//        rightSwipeGesture.delegate = self
//        v.addGestureRecognizer(rightSwipeGesture)
//
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
    
    //for textView delegate UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //if swipe success, cancel pan(move)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Do not begin the pan until the swipe fails.
        //        if gestureRecognizer == self.swipeGesture &&
        //            otherGestureRecognizer == self.panGesture {
        //            return true
        //        }
        //        return false
        if self.isEditable && otherGestureRecognizer == self.panGesture {
            Util.printLog("===cancel pan gesture==== ")
            //            Util.printLog(type(of:gestureRecognizer))
            return true
        }
        return false
    }
    
    @objc func leftSwipeHandler(_ sender: UISwipeGestureRecognizer) {
        Util.printLog("leftSwipeTap called")
        if !self.isEditable {
            return
        }
        
        self.endEditing( true)
        //get location
        let point = sender.location(in: self.textView)
        let index = self.textView.layoutManager.characterIndex(for: point, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        //        print(index)
        if let text = self.textView.text {
            //            print("textView text:\(text)")
            self.textView.text = self.getListItemFormatedText(text, index: index,isRightSwipe: false)
            
        }
        
    }
    
    @objc func rightSwipeHandler(_ sender: UISwipeGestureRecognizer) {
        Util.printLog("right swipeTap called")
        if !self.isEditable {
            return
        }
        self.endEditing( true)
        //get location
        let point = sender.location(in: self.textView)
        let index = self.textView.layoutManager.characterIndex(for: point, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if let text = self.textView.text {
            self.textView.text = self.getListItemFormatedText(text, index: index)
            
        }
    }
    
    func getListItemFormatedText(_ text:String, index:Int, isRightSwipe:Bool = true) -> String {
        //如果index == 0 or index == 1, text == "", 直接插入key到第一个位置,如果text != "",第一个字符位置替换或者插入key
        // 测试看index好像不是数组下标位置，如果swipe在没有字的位置，index总是定位到下一行的第一个字符， 需要-1
        
        //1. split text by index locaton to 2 parts, part1 + part2,
        //if part1 privious char is "\n" current char is "\n" for swipe at 空行： part1[0--priviousindex]+firstkey+part2
        // if part1 privious char is \n, current char != \n, for swipe at 行首: part1[0--privousindex]+firstkey+part2
        
        //if part1 privous char != \n, current char= \n, for swipe at 行尾, text[0...privindex] get lastLine first char(insert or replace) + text[index...]
        // else, for swipe at 行中, 同上
        //2. part1 seperate by \n as array, for part1 last line, if first char is not key char, insert a new key to before first char
        //else replace the key char with key char list next char
        
        var newText:String = ""
        
        Util.printLog("swipe index:\(index)")
        
        if index == 0 || index == 1  { //for first line 多增加一个对位置1的处理
            if text == "" { //if current text is empty
                newText = self.getReplacedKeyString(currentKey: "", isRightSwipe: isRightSwipe)
                return newText
            }else { //get next key + current text
                newText = self.getReplacedKeyString(currentKey: text.mySubstring(fromIndex: 0, toIndex: 0), isRightSwipe: isRightSwipe)
                let otherStr = text.mySubstring(fromIndex: 1, toIndex: text.count - 1)
                
                return "\(newText)\(otherStr)"
            }
        }
        
        Util.printLog("*****swipe index:\(index)")
        Util.printLog("*******swipe char:\(text.mySubstring(fromIndex: index, toIndex: index))")
        let currentIndex = index - 1
        
        if currentIndex > 0 && currentIndex < text.count {
            
            //spit text = part1String  + currentIndexChar + part2String
            let part1String = text.mySubstring(fromIndex: 0, toIndex: currentIndex - 1)
            var part2String = text.mySubstring(fromIndex: currentIndex + 1, toIndex: text.count - 1)
            let currentIndexChar = text.mySubstring(fromIndex: currentIndex, toIndex: currentIndex)
            
            //check previous char for empty line,避免最后一行是空行
            let previousChar = text.mySubstring(fromIndex: (currentIndex - 1), toIndex: (currentIndex - 1))
            if previousChar == "\n" { //处理空行或者swipe at 行首
                Util.printLog("**********process line first or empty line")
                Util.printLog("***********index char:\(currentIndexChar)")
                let replacedKeys = self.getReplacedKeyString(currentKey: currentIndexChar, isRightSwipe: isRightSwipe)
                return "\(part1String)\(replacedKeys)\(part2String)"
            }else { //处理swipe at 行尾或者行中
                part2String = "\(currentIndexChar)\(part2String)"
                
                //找到最后一行的第一个字符
                //convert to  string array
                var part1Array = part1String.components(separatedBy: "\n")
                if part1Array.count == 0 { //可能没有这种情况
                    return text
                }
                
                let lastLineLocation = part1Array.count - 1
                let lastLine = part1Array[lastLineLocation]
                if lastLine.count == 0 {
                    //如果swipe在一个空行，index的上一个位置仍然是\n，此时lastline count == 0,前面已经处理了
                    Util.printLog("=====last line is empty===")
                    return text
                }
                
                let firstKeyChar =  lastLine.mySubstring(fromIndex: 0, toIndex: 0) //String(lastLine[lastLine.startIndex])
                Util.printLog("*********LastLine firstKey char:\(firstKeyChar)")
                //取lastline第一个字符如果是key,就替换，否则insert key char
                let replacedKeyString = self.getReplacedKeyString(currentKey: firstKeyChar, isRightSwipe: isRightSwipe)  //self.insertOrReplaceKey(oldKey: String(firstKeyChar),isRightSwipe: isRightSwipe)
                let dropFirstCharLeftLine = lastLine.mySubstring(fromIndex: 1, toIndex: lastLine.count - 1)
                let newLastLine = "\(replacedKeyString)\(dropFirstCharLeftLine)"
                
                // compose replaced part1String and part2String
                var newPart1String = ""
                for (i,line ) in part1Array.enumerated() {
                    if i  ==  lastLineLocation { //par1Array.count - 1 { //ignore last line
                        break
                    }
                    newPart1String = "\(newPart1String)\(line)\n"
                }
                
                newPart1String = "\(newPart1String)\(newLastLine)" //add replaced lastline
                newText = "\(newPart1String)\(part2String)"   //add part2
                return newText
            }
        }
        
        return text
    }
    
    //返回替换的key或者新增加的key+currentKey
    func getReplacedKeyString(currentKey:String,isRightSwipe:Bool) -> String {
        //if currentKey in key list，get next or previous key,  return replacedKey
        //if currentKey is not in keylist, return first key or last key + currentKey according to swipe direction
        var newKey = currentKey
        let todoListKey = ShortcutkeyService.getShortcutKeyList()
        //swift4 is let index = todoListKey.index(of: currentKey) 
        if let index = todoListKey.firstIndex(of: currentKey) { //find current key,replace it
            let nextFactor = isRightSwipe ? 1 : -1
            let nextIndex = index + nextFactor
            if nextIndex >= todoListKey.count || nextIndex < 0  { //如果下一个或者上一个key已经到头了，返回"
                self.buttonSoundDing.play()
                newKey = ""
            }else{
                ButtonSoundSerive.playPiano(nextIndex)
                newKey = "\(todoListKey[nextIndex])"
            }
        }else{ //not found currentKey, return first or last key
            //        if currentKey == "" ||
            if isRightSwipe {
                ButtonSoundSerive.playPianoFirst()
                if let firstKey = todoListKey.first {
                    newKey = "\(firstKey)\(currentKey)"
                } // if todoList key is empty, return ""
            }else{
                ButtonSoundSerive.playPianoLast()
                if let lastKey = todoListKey.last {
                    newKey = "\(lastKey)\(currentKey)"
                }else{ // no last, todoListKey currentKey
                }
            }
        }
        return newKey
    }
    
    
    
    //    func getListItemFormatedText(_ text:String, index:Int, isRightSwipe:Bool = true) -> String {
    //        //1. split text by index locaton to 2 parts, part1 + part2
    //        //2. part1 seperate by \n as array, for part1 last line, if first char is not key char, insert a new key to before first char
    //        //else replace the key char with key char list next char
    //
    //        var newText:String = ""
    //        Util.printLog("*****swipe index:\(index)")
    //        if index > 0 && index < text.count {
    //            // index位置是text 下标(from 0)
    //            var part1EndIndex = text.index(text.startIndex, offsetBy: index )
    //            var part2BeginIndex = text.index(text.startIndex, offsetBy: index + 1 )
    //
    //            //如果swipe在line空白处， index位置是\n, 往前挪一个位置
    //            if text[part1EndIndex] == "\n" {
    //                Util.printLog("=====swipe at empty location=====")
    //                part1EndIndex = text.index(text.startIndex, offsetBy: index - 1 )
    //                part2BeginIndex = text.index(text.startIndex, offsetBy: index  )
    //            }
    //
    //            Util.printLog("***********index char:\(text[part1EndIndex])")
    //
    //            let part1String = text[...part1EndIndex]
    //            let part2String =  text[part2BeginIndex...]
    //            //convert to  string array
    //            var part1Array = part1String.components(separatedBy: "\n")
    //            //            print("by n count:\(par1tArray.count)")
    //            if part1Array.count == 0 { //可能没有这种情况
    //                return text
    //            }
    //
    //            let lastLineLocation = part1Array.count - 1
    //            let lastLine = part1Array[lastLineLocation]
    //
    //            if lastLine.count == 0 {
    //                //如果swipe在一个空行，index的上一个位置仍然是\n，此时lastline count == 0
    //                Util.printLog("=====last line is empty===")
    //                return text
    //            }
    //
    //
    //            let firstKeyChar = String(lastLine[lastLine.startIndex])
    //            //                print("fist key char:\(firstKeyChar)")
    //            //取lastline第一个字符如果是key,就替换，否则insert key char
    //            let replaceKeyChar = self.insertOrReplaceKey(oldKey: String(firstKeyChar),isRightSwipe: isRightSwipe)
    //            //                let replaceKeyChar:String = "$"
    //
    //            let keyNextIndex = lastLine.index(after: lastLine.startIndex)
    //            let dropFirstCharLeftLine = lastLine[keyNextIndex...]
    //            let newLastLine = "\(replaceKeyChar)\(dropFirstCharLeftLine)"
    //
    //            // componse replaced part1String and part2String
    //            var newPart1String = ""
    //            for (index,line ) in part1Array.enumerated() {
    //                if index  >=  lastLineLocation { //par1Array.count - 1 { //ignore last line
    //                    break
    //                }
    //                newPart1String = "\(newPart1String)\(line)\n"
    //            }
    //
    //            newPart1String = "\(newPart1String)\(newLastLine)" //add replaced lastline
    //            newText = "\(newPart1String)\(part2String)"   //add part2
    //
    //        } else {
    //            newText = text
    //        }
    //        return newText
    //    }
    //
    //    func insertOrReplaceKey(oldKey:String,isRightSwipe: Bool = true) -> String {
    //
    //        var newKey = oldKey
    //        let todoListKey = ShortcutkeyService.getShortcutKeyList()
    //
    //        if let index = todoListKey.index(of: oldKey) { // key in list, get next key, if next key is outside of list, return ""
    //            let nextFactor = isRightSwipe ? 1 : -1
    //            let nextIndex = index + nextFactor
    //            if nextIndex >= todoListKey.count || nextIndex < 0  {
    //                self.buttonSoundDing.play()
    //                newKey = ""
    //            }else{
    ////                let soundIndex = nextIndex % self.pianoButtonSoundList.count
    ////                self.pianoButtonSoundList[soundIndex].play()
    //                ButtonSoundSerive.playPiano(nextIndex)
    //                newKey = todoListKey[nextIndex]
    //            }
    //        }else{ //if not found, return (first/last key + oldkey)
    //            if isRightSwipe {
    ////                if let firstSound = self.pianoButtonSoundList.first {
    ////                    firstSound.play()
    ////                }
    //                ButtonSoundSerive.playPianoFirst()
    //                if let firstKey = todoListKey.first {
    //                    newKey = "\(firstKey)\(oldKey)"
    //                }else{ // if todoListKey is empty, return oldKey
    //                    newKey = "\(oldKey)"
    //                }
    //            }else{
    ////                if let lastSound = self.pianoButtonSoundList.last {
    ////                    lastSound.play()
    ////                }
    //                ButtonSoundSerive.playPianoLast()
    //                if let lastKey = todoListKey.last {
    //                    newKey = "\(lastKey)\(oldKey)"
    //                }else{ // no last, todoListKey is empty
    //                    newKey = "\(oldKey)"
    //                }
    //            }
    //        }
    //        return newKey
    //    }
    
    
}
