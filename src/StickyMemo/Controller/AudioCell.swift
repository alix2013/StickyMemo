//
//  AudioCell.swift
//  myAudioRecord
//
//  Created by alex on 2018/2/18.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

class AudioCell:UITableViewCell {
    
    var cdAudio:CDAudio?{
        didSet{
            guard  let cdAudio = cdAudio else {
                return
            }
            self.labelFileName.text = cdAudio.getAudioFileName()
            self.labelComment.text = cdAudio.comment
        }
    }
    
    var labelFileName:UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var labelComment:UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = UIFont.preferredFont(forTextStyle: .footnote) //UIFont.boldSystemFont(ofSize: 18)//UIFont.preferredFont(forTextStyle: .boldSystemFont(ofSize: 18))
        v.textColor = .gray
        v.numberOfLines = 0
        
        return v
    }()
    
    var buttonComment:UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        //        v.setImage(UIImage(named:"button_comment")?.withRenderingMode(.alwaysTemplate), for: .normal)
        v.setImage(UIImage(named:"button_comment"), for: .normal)
        v.tintColor = UIColor(red: 17/255, green: 157/255, blue: 226/255, alpha: 1)
        return v
    }()
    
    
    var buttonPlay:UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        v.setImage(UIImage(named:"button_play_big"), for: .normal)
        return v
    }()
    
    var buttonSpeech:UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        v.setImage(UIImage(named:"button_speechtext_big"), for: .normal)
        return v
    }()
    
    var buttonTrash:UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        v.setImage(UIImage(named:"button_trash_big"), for: .normal)
        return v
    }()
    
    var buttonShare:UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        v.setImage(UIImage(named:"button_share_big"), for: .normal)
        return v
    }()
    
    lazy var stackView:UIStackView = {
        let v = UIStackView(arrangedSubviews: [buttonComment,buttonPlay,buttonSpeech,buttonShare,buttonTrash])
        v.axis = .horizontal
        v.distribution = .fillEqually
        v.spacing = 30
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.contentView.addSubview(labelFileName)
        self.contentView.addSubview(stackView)
        self.contentView.addSubview(self.labelComment)
        [
            labelFileName.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 10),
            labelFileName.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -10),
            labelFileName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            labelFileName.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: labelFileName.bottomAnchor, constant: 0),
            
            labelComment.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 10),
            labelComment.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -10),
            labelComment.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            labelComment.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            ].forEach { $0.isActive = true }
        
    }
}

