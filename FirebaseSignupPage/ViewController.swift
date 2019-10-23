//
//  ViewController.swift
//  FirebaseSignupPage
//
//  Created by Mohamed on 10/22/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController {

    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var usernameTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    let userdefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleProfileImageDesign()
        imageProfile.isUserInteractionEnabled = true
        imageProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedImage)))
        
    }
    
    func handleProfileImageDesign(){
        
        imageProfile.layer.masksToBounds = true
        imageProfile.layer.cornerRadius = imageProfile.frame.height / 2
        imageProfile.clipsToBounds = true
        imageProfile.layer.borderWidth = 1
    }

    @IBAction func btn_signup(_ sender: UIButton) {
        
        SignupTapped()
        
        
    }
    
    @objc func tappedImage(){
        
        
        let profileImage = UIImagePickerController()
        
        profileImage.sourceType = .photoLibrary
        profileImage.allowsEditing = true
        profileImage.delegate = self
        present(profileImage, animated: true, completion: nil)
        
    }
    

    
    
}

extension ViewController : UIImagePickerControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            
            imageProfile.image = editedImage
            
            let imageData = editedImage.pngData()
            
            self.userdefault.set(imageData, forKey: "data")
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension ViewController : UINavigationControllerDelegate{
    
    
}

extension ViewController {
    
    func SignupTapped(){
            
        
        Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) { (user, error) in
            
            
            if error == nil && user != nil {
                
                self.uploadImageProfile(image: self.imageProfile.image!) { (url) in
                    
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL = url
                    changeRequest?.commitChanges(completion: { (error) in
                        
                        if error == nil {
                            
                            print("user created successfully")
                            
                            self.savePhoto(profileImageURL: url!)
                            
                        }else{
                            
                            print("user not created")
                        }
                    })
                    
                }
                
            }
            
        }
        
        
        
    }
    
    func uploadImageProfile(image: UIImage , completion: @escaping ((_ url: URL?)->())){
        
        let storagerefernce = Storage.storage().reference().child("userProfile")
        
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storagerefernce.putData(imageData, metadata: metaData) { (metadata, error) in
            
            if error == nil {
                
                
                UIAlertController(title: "Alert", message: "Succes Upload", preferredStyle: .alert).addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                storagerefernce.downloadURL { (url, error) in
                    
                    completion(url?.absoluteURL)
                }
                
            }else {
                
                completion(nil)
                print("error:Fail")
            }
            
        }
        
    }
    
    func savePhoto(profileImageURL:URL){
        
        
    }
    
    
    
}
