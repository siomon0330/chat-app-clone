//
//  ChatViewController.swift
//  liChat
//
//  Created by Simon on 2/4/19.
//  Copyright © 2019 Simon. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IQAudioRecorderViewControllerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var chatRoomId:String!
    var memberIds: [String]!
    var membersToPush:[String]!
    var titleName : String!
    var isGroup:Bool?
    var group:NSDictionary?
    var withUsers:[FUser] = []
    
    var newChatListener : ListenerRegistration?
    var typingListener : ListenerRegistration?
    var updatedChatListener : ListenerRegistration?
    
    
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var typingCounter = 0
    
    var messages:[JSQMessage] = []
    var objectMessages:[NSDictionary] = []
    var loadedMessages:[NSDictionary] = []
    var allPictureMessages:[String] = []
    
    var initialLoadComplete = false
    
    var jsqAvatarDictionary:NSMutableDictionary?
    var avatarImageDictionary:NSMutableDictionary?
    var showAvatars = true
    var firstLoad: Bool?
    
    
    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    
    //MARK: Custom header
    let leftBarButtonView:UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
       return view
    }()
    
    let avatarButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return button
    }()
    
    let titleLabel:UILabel = {
        let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        return title
    }()
    
    let subTitleLabel:UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subTitle.textAlignment = .left
        subTitle.font = UIFont(name: subTitle.font.fontName, size: 10)
        return subTitle
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        clearRecentCouter(chatRoomId: chatRoomId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCouter(chatRoomId: chatRoomId)
    }
    
//     //fix for iphoneX
//    override func viewDidLayoutSubviews() {
//        perform(Selector(("jsq_updateCollectionViewInsets")))
//    }
//     //end of iphoneX fix

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTypingObserver()
        
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(delete))
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named:"Back"), style:.plain, target: self, action: #selector(self.backAction))
        
        
        if isGroup!{
            getCurrentGroup(withId: chatRoomId)
        }
        
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        jsqAvatarDictionary = [:]
        
        
        setCustomTitle()
        
        loadMessages()

        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        
//        
//       
//        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
//        constraint.priority = UILayoutPriority(rawValue:1000)
//        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
        
        
        //custom send button
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named:"mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
        
       
    }
    
    
    //MARK: JSQMessage DataSource FUnctions
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let data = messages[indexPath.row]
        
        //set text color
        if data.senderId == FUser.currentId(){
            cell.textView?.textColor = .white
        }else{
            cell.textView?.textColor = .black
        }
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId(){
            return outgoingBubble
        }else{
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0{
            let message = messages[indexPath.row]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }else{
            return nil
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0{
           return kJSQMessagesCollectionViewCellLabelHeightDefault
        }else{
            return 0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = objectMessages[indexPath.row]
        let status:NSAttributedString!
        let attributedStringColor = [NSAttributedStringKey.foregroundColor : UIColor.darkGray]
        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
            status = NSAttributedString(string: statusText, attributes: attributedStringColor)
        default:
            status = NSAttributedString(string: "🐶")
        }
        
        if indexPath.row == messages.count - 1 {
            return status
        }else{
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentId(){
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }else{
            return 0.0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        var avatar:JSQMessageAvatarImageDataSource
        if let testAvatar = jsqAvatarDictionary!.object(forKey: message.senderId){
            avatar = testAvatar as! JSQMessageAvatarImageDataSource
        }else{
            avatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"avatarPlaceholder"), diameter: 70)
        }
        
        return avatar
    }
    
    
    //MARK: JSQMessages Delegate Functions
    override func didPressAccessoryButton(_ sender: UIButton!) {
       
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            camera.PresentMultyCamera(target: self, canEdit: false)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            camera.PresentPhotoLibrary(target: self, canEdit: false)
            
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            camera.PresentVideoLibrary(target: self, canEdit: false)
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            if self.haveAccessToUserLocation(){
                self.sendMessage(text: nil, date: Date(), picture: nil, location: kLOCATION, video: nil, audio: nil)
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
           
        }
        
        takePhotoOrVideo.setValue(UIImage(named:"camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named:"picture"), forKey: "image")
        shareVideo.setValue(UIImage(named:"video"), forKey: "image")
        shareLocation.setValue(UIImage(named:"location"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        
        //for ipad not to crash
        if (UI_USER_INTERFACE_IDIOM() == .pad){
            if let currentPopoverpresentationController = optionMenu.popoverPresentationController{
                currentPopoverpresentationController.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverpresentationController.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                currentPopoverpresentationController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        }else{
             self.present(optionMenu, animated: true, completion: nil)
        }
        
       
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        if text != ""{
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSend: false)
        }else{
           
            let audioVC = AudioViewController(delegate_: self)
            audioVC.presentAudioRecorder(target: self)
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let messageDictionary = objectMessages[indexPath.row]
        let messageType = messageDictionary[kTYPE] as! String
        switch messageType {
        case kPICTURE:
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQPhotoMediaItem
            let photos = IDMPhoto.photos(withImages: [mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            self.present(browser!, animated: true, completion: nil)
            
        case kLOCATION:
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQLocationMediaItem
            let mapView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            mapView.location = mediaItem.location
            self.navigationController?.pushViewController(mapView, animated: true)
            
        case kVIDEO:
            
            let message = messages[indexPath.row]
            let mediaItem = message.media as! VideoMessage
            let player = AVPlayer(url: mediaItem.fileURL! as URL)
            let moviePlayer = AVPlayerViewController()
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, mode: AVAudioSessionModeDefault, options: .defaultToSpeaker)
            moviePlayer.player = player
            self.present(moviePlayer, animated: true){
                moviePlayer.player!.play()
            }
            
        default:
            print("unknown type")
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        let senderId = messages[indexPath.row].senderId
        var selectedUser : FUser?
        if senderId == FUser.currentId(){
            selectedUser = FUser.currentUser()
        }else{
            for user in withUsers{
                if user.objectId == senderId{
                    selectedUser = user
                }
            }
        }
        
        presentUserProfile(forUser: selectedUser!)
    }
    //for multimedia messages delete option
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        
        super.collectionView(collectionView, shouldShowMenuForItemAt: indexPath)
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if messages[indexPath.row].isMediaMessage{
            if action.description == "delete:"{
                return true
            }else{
                return false
            }
        }else{
            if action.description == "delete:" || action.description == "copy:"{
                return true
            }else{
                return false
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        let messageId = objectMessages[indexPath.row][kMESSAGEID] as! String
        objectMessages.remove(at: indexPath.row)
        messages.remove(at: indexPath.row)
        
        //delete message from firebase
        OutgoingMessages.deleteMessage(withId: messageId, chatRoomId: chatRoomId)
        
    }
    
    
    //MARK: send messages
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?){
        
        var outgoingMessage : OutgoingMessages?
        let currentUser = FUser.currentUser()!
        
        //text message
        if let text = text{
            outgoingMessage = OutgoingMessages(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        //picture message
        if let pic = picture{
            uploadImage(image: pic, chatRoomId: chatRoomId, view: self.navigationController!.view, completion: { (imageLink) in
                if imageLink != nil{
                    let text = "[\(kPICTURE)]"
                    outgoingMessage = OutgoingMessages(message: text, pictureLink: imageLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                }
            })
            return
        }
        
        
        //send video
        if let video = video{
            let videoData = NSData(contentsOfFile: video.path!)
            let thumbNail = videoThumbNail(video: video)
            let dataThumbNail = UIImageJPEGRepresentation(thumbNail, 0.3)
            uploadVideo(video: videoData!, chatRoomId: chatRoomId, view: self.navigationController!.view, completion: { (videoLink) in
                if videoLink != nil{
                    let text = "[\(kVIDEO)]"
                    outgoingMessage = OutgoingMessages.init(message: text, video: videoLink!, thumbNail: dataThumbNail! as NSData, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kVIDEO)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                }
            })
            return
            
        }
        
        
        
        //send audio
        if let audioPath = audio{
            uploadAudio(audioPath: audioPath, chatRoomId: chatRoomId, view: self.navigationController!.view, completion: { (audioLink) in
                if audioLink != nil{
                    let text = "[\(kAUDIO)]"
                    outgoingMessage = OutgoingMessages(message: text, audio: audioLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kAUDIO)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage!.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                }
            })
            
            return
        }
        
        //send location
        if location != nil{
            let lat:NSNumber = NSNumber(value: appDelegate.coordinates!.latitude)
            let long:NSNumber = NSNumber(value: appDelegate.coordinates!.longitude)
            
            let text = "[\(kLOCATION)]"
            outgoingMessage = OutgoingMessages(message: text, latitude: lat, longitude: long, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kLOCATION)
            
        }
        
 
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomId: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
    }
    
    //MARK: LoadMessages
    func loadMessages(){
        
        //to update message status
        updatedChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else{
                return
            }
            
            if !snapshot.isEmpty{
                
                //for diff in snapshot.documentChanges
                
                snapshot.documentChanges.forEach({ (diff) in
                    if diff.type == .modified{
                        //update local message
                        self.updateMessage(messageDictionary: diff.document.data() as NSDictionary)
                    }
                })
            }
        })
        
        
        
        //get last 11 messages
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else{
                //initial loading is done
                self.listenForNewChats()
                self.initialLoadComplete = true
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key:kDATE, ascending: true)]) as! [NSDictionary]
            
            //remove bad message
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
    
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadComplete = true
            
            //print("we have \(self.messages.count) messages")
            //get picture messages
            self.getPictureMessage()
            
            self.getOldmessagesInBackground()
            
            self.listenForNewChats()
        }
    }
    
    func listenForNewChats(){
        var lastMessagesDate = "0"
        if loadedMessages.count > 0{
            lastMessagesDate = loadedMessages.last![kDATE] as! String
        }
        
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan: lastMessagesDate).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else{
                return
            }
            
            if !snapshot.isEmpty{
                for diff in snapshot.documentChanges{
                    if diff.type == .added{
                        let item = diff.document.data() as NSDictionary
                        if let type = item[kTYPE]{
                            if self.legitTypes.contains(type as! String){
                                
                                //for picture
                                if type as! String == kPICTURE{
                                    self.addNewPictureMessageLink(link: item[kPICTURE] as! String)
                                }
                                
                                if self.insertInitialLoadMessages(messageDictionary: item){
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                
                                self.finishSendingMessage()
                            }
                        }
                    }
                }
            }
        })
        
    }
    
    
    
    func getOldmessagesInBackground(){
        if loadedMessages.count > 10{
            let firstMessageDate = loadedMessages.first![kDATE] as! String
            reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments(completion: { (snapshot, error) in
                guard let snapshot = snapshot else{
                    return
                }
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key:kDATE, ascending:true)]) as! [NSDictionary]
                self.loadedMessages = self.removeBadMessages(allMessages: sorted) + self.loadedMessages
                
                //get the pic messages
                self.getPictureMessage()
                
                self.maxMessageNumber = self.loadedMessages.count - self.loadedMessagesCount - 1
                self.minMessageNumber = self.maxMessageNumber - kNUMBEROFMESSAGES
                
            })
        }
    }
    
    
    
    //MARK: Insert messages
    func insertMessages(){
        maxMessageNumber = loadedMessages.count - loadedMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0{
            minMessageNumber = 0
        }
        
        for i in minMessageNumber..<maxMessageNumber{
            let messageDictionary = loadedMessages[i]
            insertInitialLoadMessages(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
            
        }
        
        self.showLoadEarlierMessagesHeader = loadedMessagesCount != loadedMessages.count
        
    }
    
    func insertInitialLoadMessages(messageDictionary: NSDictionary) -> Bool{
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView)
        //check if incoming
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId(){
            
            OutgoingMessages.updateMessage(withId: messageDictionary[kMESSAGEID] as! String, chatRoomId: chatRoomId, memberIds: membersToPush)
        }
        
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        if message != nil{
            objectMessages.append(messageDictionary)
            messages.append(message!)
            
        }
        
        return isIncoming(messageDictionary: messageDictionary)
        
        
    }
    
    func updateMessage(messageDictionary: NSDictionary){
        for index in 0..<objectMessages.count{
            let temp = objectMessages[index]
            
            if messageDictionary[kMESSAGEID] as! String == temp[kMESSAGEID] as! String{
                objectMessages[index] == messageDictionary
                self.collectionView!.reloadData()
            }
        }
    }
    
    //MARK: LoadMoreMessages
    func loadMoreMessages(maxNumber: Int, minNumber: Int){
        if loadOld{
            maxMessageNumber = minNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
            
        }
        
        if minMessageNumber < 0{
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed(){
            let messageDictionary = loadedMessages[i]
            insertNewMessage(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
            
        }
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
        
    }
    
    func insertNewMessage(messageDictionary: NSDictionary){
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
        
    }
    
    
    //MARK: IBActions
    @objc func backAction(){
        
        clearRecentCouter(chatRoomId: chatRoomId)
        self.navigationController?.popViewController(animated: true)
        removeListeners()
        
    }
    
     @objc func infoButtonPressed(){
        
        let mediaVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mediaView") as! PicturesCollectionViewController
        mediaVC.allImageLinks = allPictureMessages
        self.navigationController?.pushViewController(mediaVC, animated: true)
        
    }
    
    @objc func showGroup(){
        
        let groupVC = UIStoryboard.init(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "groupView") as! GroupViewController
        
        groupVC.group = group!
        self.navigationController?.pushViewController(groupVC, animated: true)
    }
    
    @objc func showUserProfile(){
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        profileVC.user = withUsers.first!
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    func presentUserProfile(forUser: FUser){
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        profileVC.user = forUser
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    //MARK:Typing indicator
    func createTypingObserver(){
        typingListener = reference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else{
                return
            }
            if snapshot.exists{
                for data in snapshot.data()!{
                    if data.key != FUser.currentId(){
                        let typing = data.value as! Bool
                        self.showTypingIndicator = typing
                        if typing{
                            self.scrollToBottom(animated: true)
                        }
                    }
                }
            }else{
                reference(.Typing).document(self.chatRoomId).setData([FUser.currentId(): false])
            }
        })
    }
    
    func typingCounterStart(){
        typingCounter += 1
        typingCounterSave(typing: true)
        self.perform(#selector(self.typingCounterStop), with: nil, afterDelay: 2.0)
        
    }
    
    @objc func typingCounterStop(){
        typingCounter -= 1
        if typingCounter == 0{
            typingCounterSave(typing: false)
        }
    }
    
    func typingCounterSave(typing: Bool){
        reference(.Typing).document(chatRoomId).updateData([FUser.currentId(): typing])
    }
    
    //MARK: UITextView Delegate
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        typingCounterStart()
        return true
    }
    
    
    //MARK: CustomSendButton
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != ""{
            updateSendButton(isSend: true)
        }else{
            updateSendButton(isSend: false)
        }
    }
    
    func updateSendButton(isSend: Bool){
        if isSend{
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named:"send"), for: .normal)
        }else{
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named:"mic"), for: .normal)
        }
    }
    
    //MARK: IQAudioDelegate
    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        controller.dismiss(animated: true, completion: nil)
        self.sendMessage(text: nil, date: Date(), picture: nil, location: nil, video: nil, audio: filePath)
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Update UI
    func setCustomTitle(){
        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        let infoButton = UIBarButtonItem(image: UIImage(named:"info"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.infoButtonPressed))
        self.navigationItem.rightBarButtonItem = infoButton
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        if isGroup!{
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        }else{
            avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
        }
        
        getUsersFromFirestore(withIds: memberIds) { (withUsers) in
            self.withUsers = withUsers
            
            self.getAvatarImages()
            
            if !self.isGroup!{
                self.setUIForSingleChat()
                
            }
        }
        
        
        
    }
    
    func setUIForSingleChat(){
        let withUser = withUsers.first!
        imageFromData(pictureData: withUser.avatar) { (image) in
            if image != nil{
                avatarButton.setImage(image!.circleMasked, for: .normal)
            }
        }
        titleLabel.text = withUser.fullname
        if withUser.isOnline{
            subTitleLabel.text = "Online"
        }else{
            subTitleLabel.text = "Offline"
        }
        
        avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
    }
    
    
    func setUIForGroupChat(){
        imageFromData(pictureData: group![kAVATAR] as! String) { (image) in
            if image != nil{
                avatarButton.setImage(image!.circleMasked, for: .normal)
            }
        }
        titleLabel.text = titleName
        subTitleLabel.text = ""
    }
    
    
    //UIImagePickerController delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let video = info[UIImagePickerControllerMediaURL]  as? NSURL
        let picture = info[UIImagePickerControllerOriginalImage] as? UIImage
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:Get Avatars
    func getAvatarImages(){
        if showAvatars{
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
            
            //get Current user avatar
            avatarImageFrom(fUser: FUser.currentUser()!)
            
            for user in withUsers{
                avatarImageFrom(fUser: user)
            }
            
        }
    }
    
    func avatarImageFrom(fUser: FUser){
        if fUser.avatar != ""{
            
            dataImageFromString(pictureString: fUser.avatar, withBlock: { (imageData) in
                if imageData == nil{
                    return
                }
                
                if self.avatarImageDictionary != nil{
                    //update avatar if we have it
                    self.avatarImageDictionary!.removeObject(forKey: fUser.objectId)
                    self.avatarImageDictionary!.setObject(imageData, forKey: fUser.objectId as NSCopying)
                }else{
                    self.avatarImageDictionary = [fUser.objectId : imageData!]
                }
                
                //create jsq avatars
                self.createJSQAvatars(avatarDictionary: self.avatarImageDictionary)
            })
        }
    }
    
    func createJSQAvatars(avatarDictionary: NSMutableDictionary?){
        let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"avatarPlaceholder"), diameter: 70)
        if avatarDictionary != nil{
            for userId in memberIds{
                if let avatarImageData = avatarDictionary![userId]{
                    let jsqAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: avatarImageData as! Data), diameter: 70)
                    self.jsqAvatarDictionary!.setValue(jsqAvatar, forKey: userId)
                }else{
                    self.jsqAvatarDictionary!.setValue(defaultAvatar, forKey: userId)
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    //MARK: Location Access
    func haveAccessToUserLocation() -> Bool{
        if appDelegate.locationManager != nil {
            return true
        }else{
            
            ProgressHUD.showError("Please give access to location in Setting.")
            return false
        }
    }
    
    
    
    //MARK: helper functions
    
    func addNewPictureMessageLink(link:String){
        allPictureMessages.append(link)
        
    }
    
    func getPictureMessage(){
        allPictureMessages = []
        for message in loadedMessages{
            if message[kTYPE] as! String == kPICTURE{
                allPictureMessages.append(message[kPICTURE] as! String)
            }
        }
    }
    
    func readTimeFrom(dateString: String) -> String{
        let date = dateFormatter().date(from: dateString)
        let currentDateFormat = dateFormatter()
        currentDateFormat.dateFormat = "HH:mm"
        return currentDateFormat.string(from: date!)
    }
    
    
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        var tempMessages = allMessages
        for message in tempMessages{
            if message[kTYPE] != nil{
                if !self.legitTypes.contains(message[kTYPE] as! String){
                    //remove the message
                    tempMessages.remove(at: tempMessages.index(of: message)!)
                }
            }else{
                 //remove the message
                tempMessages.remove(at: tempMessages.index(of: message)!)
            }
        }
        
        return tempMessages
    }
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool{
        
        if FUser.currentId() == messageDictionary[kSENDERID] as! String{
            return false
        }
        return true
    }
    
    func removeListeners(){
        if typingListener != nil{
            typingListener!.remove()
        }
        
        if newChatListener != nil{
            newChatListener!.remove()
        }
        
        if updatedChatListener != nil{
            updatedChatListener!.remove()
        }
    }
    
    func getCurrentGroup(withId: String){
        reference(.Group).document(withId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else{
                return
            }
            
            if snapshot.exists{
                self.group = snapshot.data() as! NSDictionary
                self.setUIForGroupChat()
                self.subTitleLabel.text =  "\((self.group![kMEMBERS] as! [String]).count)"
                
            }
        }
    }

  
}


//fix for iphoneX
extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else { return }
        if #available(iOS 11.0, *) {
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(anchor, multiplier: 1.0).isActive = true
           
        }
    }
}
