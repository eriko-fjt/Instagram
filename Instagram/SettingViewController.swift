//
//  SettingViewController.swift
//  Instagram
//
//  Created by 藤田恵梨子 on 2020/09/27.
//  Copyright © 2020 eriko.fujita. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import CLImageEditor
import FirebaseUI

class SettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    //hachi@techacademy.jp
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    var profileImage = UIImage(systemName: "person.fill")
    var defaultImage = UIImage(systemName: "person.fill")
    
    // 表示名変更ボタンをタップした時に呼ばれるメソッド
    @IBAction func handleChangeButton(_ sender: Any) {
        if let displayName = displayNameTextField.text {
            
            // 表示名が入力されていない時はHUDを出して何もしない
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "表示名を入力してください")
                return
            }
            
            // 表示名を設定する
            let user = Auth.auth().currentUser
            
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges {error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    
                    print("DEBUT_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    
                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                }
            }
        }
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    
    
    // ログアウトボタンを押した時に呼ばれるメソッド
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
        
        // ログイン画面から戻ってきた時のためにホーム画面(index = 0)を選択している状態にしておく
        tabBarController?.selectedIndex = 0
    }
    
    
    // --- プロフィール写真の設定ここから ---
    
    @IBAction func handleProfilePhotoButton(_ sender: Any) {
        
        // ライブラリをひ指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    // 写真を選択した時に呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[.originalImage] != nil {
            // 選択した画像を取得
            let image = info[.originalImage] as! UIImage
            
            // CLImageEditorライブラリで加工(imageを渡して、加工画面を起動）
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            editor.modalPresentationStyle = .fullScreen
            picker.present(editor, animated: true, completion: nil)
            
        }
    }
    
    // imagePickerがキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //ImageSelectViewController画面を閉じてタブ（設定）画面に戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // CLImageEditorで加工が終わった時に呼ばれる
    // FireStoreのユーザ情報更新と、ImageViewへの写真の表示
    // Auth.auth().currentUserに登録できるphotoURLは、URLでないといけないらしい（Storageのpathは不可）ので、createProfileChangeRequest()使えない。
    func imageEditor(_ editor: CLImageEditor, didFinishEditingWith image: UIImage!) {
        
        SVProgressHUD.show()
        //profileImage = image!
        
        if let user = Auth.auth().currentUser?.displayName {
            
            let imageData = image.jpegData(compressionQuality: 0.5)  // 選択された写真をJPEGに変換・圧縮したデータ
            //let photoURL = ここに、写真へのパスを作る？
            let photoRef = Storage.storage().reference().child(Const.ProfilePhotoPath).child(user + ".jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            
            //if profilePhotoImageView.image = defaultImage
                
                photoRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                    if error != nil {   // 投稿処理をキャンセルし、先頭画面（設定画面）に戻る
                        print("DEBUG_PRING: プロフィール写真アップロード失敗   \(error!)")
                        SVProgressHUD.showError(withStatus: "プロフィール写真の登録に失敗しました。")
                        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                }
              
               /*
              // デフォルト写真以外が入っているときは、メタデータの更新
                photoRef.updateMetadata(metadata) { metadata, error in
                    if let error = error {
                        print("DEGBUG_PRINT: プロフィール写真の更新に失敗しました。　 error: \(error)")
                        SVProgressHUD.showError(withStatus: "プロフィール写真の更新に失敗しました。")
                        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                }
              */
            
            
            
            profilePhotoImageView.image = image
            SVProgressHUD.showSuccess(withStatus: "プロフィール写真を登録しました")
            SVProgressHUD.dismiss()
            
            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
            
        }
        
    
    }
    
    // CLImageEditorで編集がキャンセルされた時に呼ばれる
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        // 加工画面を閉じてタブ（設定）画面に戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // --- プロフィール写真の設定ここまで --
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 表示名を取得してTextFieldに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameTextField.text = user.displayName
            
            let photoRef = Storage.storage().reference().child(Const.ProfilePhotoPath).child(user.displayName! + ".jpg")
            profilePhotoImageView.sd_setImage(with:photoRef)
            
        }
    }
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePhotoImageView.image = profileImage
        // プロフィール写真に枠線をつける
        profilePhotoImageView.layer.borderColor = UIColor.gray.cgColor
        profilePhotoImageView.layer.borderWidth = 0.5
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
