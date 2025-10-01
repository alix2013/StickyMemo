//
//  QuickstartViewController.swift
//  StickyMemo
//
//  Created by alex on 2018/1/19.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

class QuickstartPage {
    var description:String
    var imageName: String
    
    init(description: String, imageName:String) {
        self.description = description
        self.imageName = imageName
    }
}

class QuickstartPageCell: UICollectionViewCell {
    
    var page: QuickstartPage? {
        didSet {
            //            print(page?.imageName)

            guard let page = page else { return }

            imageView.image = UIImage(named: page.imageName)

//            let attributedText = NSMutableAttributedString(string: page.description, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23)]) //UIFont.boldSystemFont(ofSize: 23)])

            let attributedText = NSMutableAttributedString(string: page.description, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]) //UIFont.boldSystemFont(ofSize: 23)])
//            attributedText.append(NSAttributedString(string: "\n\n\n\(unwrappedPage.bodyText)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: UIColor.gray]))

            descriptionTextView.attributedText = attributedText
            descriptionTextView.textAlignment = .center
        }
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        
//        let attributedText = NSMutableAttributedString(string: "Join us today in our fun and games!", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)])
//
//        attributedText.append(NSAttributedString(string: "\n\n\nAre you ready for loads and loads of fun? Don't wait any longer! We hope to see you in our stores soon.", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: UIColor.gray]))
//
//        textView.attributedText = attributedText
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = AppDefault.themeColor
//        textView.backgroundColor = .black
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = AppDefault.themeColor
        setupLayout()
    }
    
    private func setupLayout() {
        let topImageContainerView = UIView()
//        topImageContainerView.backgroundColor = UIColor.black //.withAlphaComponent(0.5)
        addSubview(topImageContainerView)
        topImageContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        topImageContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        topImageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topImageContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        topImageContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6).isActive = true
        
        topImageContainerView.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: topImageContainerView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: topImageContainerView.centerYAnchor).isActive = true
        let width = max( 200, self.frame.width / 2 )
        let height = width
        imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
//        imageView.heightAnchor.constraint(equalTo: topImageContainerView.heightAnchor, multiplier: 0.5).isActive = true
    
        
        addSubview(descriptionTextView)
        descriptionTextView.topAnchor.constraint(equalTo: topImageContainerView.bottomAnchor).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class QuickstartViewController:UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    let pages:[QuickstartPage]  = [
        QuickstartPage(description:Appi18n.i18n_quickstartMain,imageName:"quickstart_main"),
        QuickstartPage(description:Appi18n.i18n_quickstartGesture,imageName:"quickstart_gesture"),
        QuickstartPage(description:Appi18n.i18n_quickstartDelete,imageName:"quickstart_delete"),
        QuickstartPage(description:Appi18n.i18n_quickstartEdit,imageName:"quickstart_edit"),
        QuickstartPage(description:Appi18n.i18n_quickstartTable,imageName:"quickstart_table"),
        QuickstartPage(description:Appi18n.i18n_quickstartSpeech,imageName:"quickstart_speech"),
        QuickstartPage(description:Appi18n.i18n_quickstartAirTransfer,imageName:"quickstart_airtransfer")
    ]
    
    let cellId:String = "cellid"
    
    lazy var  buttonClose:UIButton = {
       let v = UIButton()
//        v.setTitle("X", for: .normal)
        v.setImage(UIImage(named:"button_close"), for: .normal)
        v.addTarget(self, action: #selector(buttonCloseTap), for: .touchUpInside)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
//        button.setTitle("<-", for: .normal)
        button.setImage(UIImage(named:"button_pre"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(handlePrev), for: .touchUpInside)
        return button
    }()
    
    @objc private func handlePrev() {
        let nextIndex = max(pageControl.currentPage - 1, 0)
        let indexPath = IndexPath(item: nextIndex, section: 0)
        pageControl.currentPage = nextIndex
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
//        button.setTitle("->", for: .normal)
        button.setImage(UIImage(named:"button_next"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    @objc private func handleNext() {
        let nextIndex = min(pageControl.currentPage + 1, pages.count - 1)
        let indexPath = IndexPath(item: nextIndex, section: 0)
        pageControl.currentPage = nextIndex
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = pages.count
        pc.currentPageIndicatorTintColor = .red
        pc.pageIndicatorTintColor = .gray//UIColor(red: 249/255, green: 207/255, blue: 224/255, alpha: 1)
        return pc
    }()
    
    fileprivate func setupBottomControls() {
        let bottomControlsStackView = UIStackView(arrangedSubviews: [previousButton, pageControl, nextButton])
        bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomControlsStackView.distribution = .fillEqually
        
        view.addSubview(bottomControlsStackView)
        
        NSLayoutConstraint.activate([
            bottomControlsStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            bottomControlsStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            bottomControlsStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            bottomControlsStackView.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let x = targetContentOffset.pointee.x
        
        pageControl.currentPage = Int(x / view.frame.width)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCloseButton()
        setupBottomControls()
    }
    
    func setupViews(){
        collectionView?.backgroundColor = .white
        collectionView?.register(QuickstartPageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
    }
    
    func setupCloseButton(){
        
        self.view.addSubview(self.buttonClose)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(40)]-30-|", options: [], metrics:nil, views: ["v0":buttonClose]))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[v0(40)]", options: [], metrics:nil, views: ["v0":buttonClose]))
        
        
        
//        buttonClose.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        buttonClose.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//
        
    }
    
    @objc func buttonCloseTap() {
        DefaultService.saveFirstStartStatus()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! QuickstartPageCell

        let page = pages[indexPath.item]
        cell.page = page
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        self.collectionView?.reloadData()
        self.collectionView?.collectionViewLayout.invalidateLayout()
        let indexPath = IndexPath(item: self.pageControl.currentPage, section: 0)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
}
