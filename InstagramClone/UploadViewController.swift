//
//  UploadViewController.swift
//  InstagramClone
//
//  Created by Abdullah Ayan on 26.01.2022.
//

import UIKit
import Firebase
import CoreMedia

class UploadViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    
    
    @objc func chooseImage(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    @IBAction func uploadClicked(_ sender: Any) {
        let uuid = UUID().uuidString
        let storage = Storage.storage()
        let storageReferance = storage.reference()
        let mediaFolder = storageReferance.child("media")
        
        
        //Storage
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                }else{
                    imageReferance.downloadURL { url, error in
                        if error == nil {
                            
                            
                            let imageUrl = url?.absoluteString
                            
                            
                            //Database
                            
                            let firestoreDatabase = Firestore.firestore()
                            var firestoreReference : DocumentReference? = nil
                            let firestorePost = ["imageUrl": imageUrl!, "postedBy": Auth.auth().currentUser!.email!,"postComment":self.commentText.text!,"date":FieldValue.serverTimestamp(),"likes":0] as [String : Any]
                
                            
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost) { error in
                                if error != nil {
                                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                                }
                                else {
                                    self.imageView.image = UIImage(systemName: "photo.artframe")
                                    self.commentText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                }
                            }
                            
                            
                            
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    func makeAlert(titleInput:String,messageInput:String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
}
