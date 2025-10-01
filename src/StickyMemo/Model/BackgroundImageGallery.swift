//
//  BackgroundImageGallery.swift
//  StickyMemo
//
//  Created by alex on 2017/11/28.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

/*
class BackgroundImageGallery {
    
    /*
     huang2: 255,255,139    FFFF8B
     lan1: 119,231,254        BFE7FE
     zi1: 194,162,216        C2A2D8
     lv1: 127,228,144        7FE490
     lan2: 37,227,222        25E3DE
     ceng1: 255,158,51        FF9E33
     hui        234,225,214        EAE1D6
     */
    
    static let imageDict: Dictionary<String,[BackgroundImageTemplate]> = [

        "bg_bubble_left_1":[
            BackgroundImageTemplate(name: "bg_bubble_left_1", tintColorHex: "FFFF8B", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_left_2", tintColorHex: "BFE7FE", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_left_3", tintColorHex: "C2A2D8", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_left_4", tintColorHex: "7FE490", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_left_5", tintColorHex: "25E3DE", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_left_6", tintColorHex: "FF9E33", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_left_7", tintColorHex: "EAE1D6", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            
        ],
        
        "bg_bubble_right_2":[
            BackgroundImageTemplate(name: "bg_bubble_right_2", tintColorHex: "BFE7FE", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_right_3", tintColorHex: "C2A2D8", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_right_4", tintColorHex: "7FE490", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_right_5", tintColorHex: "25E3DE", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_right_6", tintColorHex: "FF9E33", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_right_7", tintColorHex: "EAE1D6", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            BackgroundImageTemplate(name: "bg_bubble_right_1", tintColorHex: "FFFF8B", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
            
        ],
        
        "bg_rect_misscorner_3":[
            BackgroundImageTemplate(name: "bg_rect_misscorner_3", tintColorHex: "C2A2D8", edgeTop: 10, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_4", tintColorHex: "7FE490", edgeTop: 10, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_5", tintColorHex: "25E3DE", edgeTop: 10, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_6", tintColorHex: "FF9E33", edgeTop: 10, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_7", tintColorHex: "EAE1D6", edgeTop: 10, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_1", tintColorHex: "FFFF8B", edgeTop: 10, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_2", tintColorHex: "BFE7FE", edgeTop: 10, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            
        ],
        
        "bg_rect_misscorner_clip_4":[
            BackgroundImageTemplate(name: "bg_rect_misscorner_clip_4", tintColorHex: "7FE490", edgeTop: 35, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_clip_5", tintColorHex: "25E3DE", edgeTop: 35, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_clip_6", tintColorHex: "FF9E33", edgeTop: 35, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_clip_7", tintColorHex: "EAE1D6", edgeTop: 35, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_clip_1", tintColorHex: "FFFF8B", edgeTop: 35, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_clip_2", tintColorHex: "BFE7FE", edgeTop: 35, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_misscorner_clip_3", tintColorHex: "C2A2D8", edgeTop: 35, edgeLeft: 10, edgeBottom: 30, edgeRight: 30),
            
        ],
        
        "bg_rect_lefthole_5":[
            BackgroundImageTemplate(name: "bg_rect_lefthole_5", tintColorHex: "25E3DE", edgeTop: 10, edgeLeft: 20, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_lefthole_6", tintColorHex: "FF9E33", edgeTop: 10, edgeLeft: 20, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_lefthole_7", tintColorHex: "EAE1D6", edgeTop: 10, edgeLeft: 20, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_lefthole_1", tintColorHex: "FFFF8B", edgeTop: 10, edgeLeft: 20, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_lefthole_2", tintColorHex: "BFE7FE", edgeTop: 10, edgeLeft: 20, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_lefthole_3", tintColorHex: "C2A2D8", edgeTop: 10, edgeLeft: 20, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_lefthole_4", tintColorHex: "7FE490", edgeTop: 10, edgeLeft: 20, edgeBottom: 10, edgeRight: 10),
        ],
        
        "bg_lost_6":[
            BackgroundImageTemplate(name: "bg_lost_6", tintColorHex: "FF9E33", edgeTop: 50, edgeLeft: 50, edgeBottom: 50, edgeRight: 50),
            BackgroundImageTemplate(name: "bg_lost_7", tintColorHex: "EAE1D6", edgeTop: 50, edgeLeft: 50, edgeBottom: 50, edgeRight: 50),
            BackgroundImageTemplate(name: "bg_lost_1", tintColorHex: "FFFF8B", edgeTop: 50, edgeLeft: 50, edgeBottom: 50, edgeRight: 50),
            BackgroundImageTemplate(name: "bg_lost_2", tintColorHex: "BFE7FE", edgeTop: 50, edgeLeft: 50, edgeBottom: 50, edgeRight: 50),
            BackgroundImageTemplate(name: "bg_lost_3", tintColorHex: "C2A2D8", edgeTop: 50, edgeLeft: 50, edgeBottom: 50, edgeRight: 50),
            BackgroundImageTemplate(name: "bg_lost_4", tintColorHex: "7FE490", edgeTop: 50, edgeLeft: 50, edgeBottom: 50, edgeRight: 50),
            BackgroundImageTemplate(name: "bg_lost_5", tintColorHex: "25E3DE", edgeTop: 50, edgeLeft: 50, edgeBottom: 50, edgeRight: 50),
        ],
        
        "bg_rect_pin_7":[
            BackgroundImageTemplate(name: "bg_rect_pin_7", tintColorHex: "EAE1D6", edgeTop: 30, edgeLeft: 10, edgeBottom: 10, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_pin_1", tintColorHex: "FFFF8B", edgeTop: 30, edgeLeft: 10, edgeBottom: 10, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_pin_2", tintColorHex: "BFE7FE", edgeTop: 30, edgeLeft: 10, edgeBottom: 10, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_pin_3", tintColorHex: "C2A2D8", edgeTop: 30, edgeLeft: 10, edgeBottom: 10, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_pin_4", tintColorHex: "7FE490", edgeTop: 30, edgeLeft: 10, edgeBottom: 10, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_pin_5", tintColorHex: "25E3DE", edgeTop: 30, edgeLeft: 10, edgeBottom: 10, edgeRight: 30),
            BackgroundImageTemplate(name: "bg_rect_pin_6", tintColorHex: "FF9E33", edgeTop: 30, edgeLeft: 10, edgeBottom: 10, edgeRight: 30),
        ],
        
        "bg_round_1":[
            BackgroundImageTemplate(name: "bg_round_1", tintColorHex: "FFFF8B", edgeTop: 15, edgeLeft: 15, edgeBottom: 15, edgeRight: 15),
            BackgroundImageTemplate(name: "bg_round_2", tintColorHex: "BFE7FE", edgeTop: 15, edgeLeft: 15, edgeBottom: 15, edgeRight: 15),
            BackgroundImageTemplate(name: "bg_round_3", tintColorHex: "C2A2D8", edgeTop: 15, edgeLeft: 15, edgeBottom: 15, edgeRight: 15),
            BackgroundImageTemplate(name: "bg_round_4", tintColorHex: "7FE490", edgeTop: 15, edgeLeft: 15, edgeBottom: 15, edgeRight: 15),
            BackgroundImageTemplate(name: "bg_round_5", tintColorHex: "25E3DE", edgeTop: 15, edgeLeft: 15, edgeBottom: 15, edgeRight: 15),
            BackgroundImageTemplate(name: "bg_round_6", tintColorHex: "FF9E33", edgeTop: 15, edgeLeft: 15, edgeBottom: 15, edgeRight: 15),
            BackgroundImageTemplate(name: "bg_round_7", tintColorHex: "EAE1D6", edgeTop: 15, edgeLeft: 15, edgeBottom: 15, edgeRight: 15),
        ],
        
        
        "bg_rect_2":[
            BackgroundImageTemplate(name: "bg_rect_2", tintColorHex: "BFE7FE", edgeTop: 10, edgeLeft: 10, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_3", tintColorHex: "C2A2D8", edgeTop: 10, edgeLeft: 10, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_4", tintColorHex: "7FE490", edgeTop: 10, edgeLeft: 10, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_5", tintColorHex: "25E3DE", edgeTop: 10, edgeLeft: 10, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_6", tintColorHex: "FF9E33", edgeTop: 10, edgeLeft: 10, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_7", tintColorHex: "EAE1D6", edgeTop: 10, edgeLeft: 10, edgeBottom: 10, edgeRight: 10),
            BackgroundImageTemplate(name: "bg_rect_1", tintColorHex: "FFFF8B", edgeTop: 10, edgeLeft: 10, edgeBottom: 10, edgeRight: 10),
            ],
            
        ]
    
    
    static let memoColorList:[MemoColor] = [
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.red),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.orange),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.yellow),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.green),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.blue),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.black),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.white),
        
        
        ]
    
    static func getBackgroundImageTemplatesByCatalog(_ template:BackgroundImageTemplate) -> [BackgroundImageTemplate]? {
        
        return BackgroundImageGallery.getBackgroundImageTemplatesByCatalog(template.name)
    }
    
    static func getBackgroundImageTemplatesByCatalog(_ catalog:String) -> [BackgroundImageTemplate]? {
        return imageDict[catalog]
    }

    //    static func getBackgroundImageTemplateCatalogs() -> [BackgroundImageTemplate] {
//
//        let imageList:[BackgroundImageTemplate] = [
//            BackgroundImageTemplate(name: "bg_bubble_left_1", tintColorHex: "", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
//
//            BackgroundImageTemplate(name: "bg_bubble_right_2", tintColorHex: "", edgeTop: 22, edgeLeft: 26, edgeBottom: 22, edgeRight: 26),
//
//            BackgroundImageTemplate(name: "bg_rect_misscorner_3", tintColorHex: "", edgeTop: 0, edgeLeft: 0, edgeBottom: 20, edgeRight: 20),
//
//            BackgroundImageTemplate(name: "bg_rect_misscorner_clip_4", tintColorHex: "", edgeTop: 35, edgeLeft: 0, edgeBottom: 20, edgeRight: 20),
//
//            BackgroundImageTemplate(name: "bg_rect_lefthole_5", tintColorHex: "", edgeTop: 0, edgeLeft: 20, edgeBottom: 0, edgeRight: 0),
//
//            BackgroundImageTemplate(name: "bg_lost_6", tintColorHex: "", edgeTop: 50, edgeLeft: 50, edgeBottom: 50, edgeRight: 50),
//
//            BackgroundImageTemplate(name: "bg_rect_pin_7", tintColorHex: "", edgeTop: 30, edgeLeft: 0, edgeBottom: 0, edgeRight: 30),
//
//            BackgroundImageTemplate(name: "bg_round_1", tintColorHex: "", edgeTop: 10, edgeLeft: 10, edgeBottom: 10, edgeRight: 10),
//
//            BackgroundImageTemplate(name: "bg_rect_2", tintColorHex: "", edgeTop: 0, edgeLeft: 0, edgeBottom: 0, edgeRight: 0),
//
//            //            BackgroundImageTemplate(name: "bg_rect_tophole_1", tintColorHex: "", edgeTop: 18, edgeLeft: 0, edgeBottom: 0, edgeRight: 0),
//
//
//        ]
//
//        return imageList
////        return BKImageTemplateService().getBackgroundImageCatalogs()
//
//    }
    
    
//    class func getBackgroundImage(_ backgroundTemplate: BackgroundImageTemplate) -> BackgroundImage {
//        let b = BackgroundImage(name: backgroundTemplate.name, tintColorHex: backgroundTemplate.tintColorHex, edgeTop: backgroundTemplate.edgeTop, edgeLeft: backgroundTemplate.edgeLeft, edgeBottom: backgroundTemplate.edgeBottom, edgeRight: backgroundTemplate.edgeRight)
//        
//        return b
//    }
 
//    class func getUIImage(_ background: BackgroundImage ) -> UIImage? {
//        let imgName = background.name
//        var ret: UIImage?
//        
//        //        resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
//        if let image = UIImage(named: imgName) {
//            ret = image.resizableImage(withCapInsets: UIEdgeInsets(top: background.edgeTop, left: background.edgeLeft, bottom: background.edgeBottom, right: background.edgeRight))
//        }else{
//            return nil
//        }
//        return ret
//    }
    
    
    class func getMemoColors() -> [MemoColor] {
        return memoColorList
        
    }
}
*/



