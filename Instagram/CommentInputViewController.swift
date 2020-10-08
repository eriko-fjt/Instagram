//
//  CommentInputViewController.swift
//  Instagram
//
//  Created by 藤田恵梨子 on 2020/10/02.
//  Copyright © 2020 eriko.fujita. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentInputViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    // post投稿者の表示名を表示するラベル
    @IBOutlet weak var displayNameLabel: UILabel!
    
    // 投稿のキャプションを表示するラベル
    @IBOutlet weak var captionLabel: UILabel!
    
    // コメント表示用のテーブル
    @IBOutlet weak var commentTableView: UITableView!
    
    // コメント入力用
    @IBOutlet weak var commentInputTextView: UITextView!
    
    // この↓、コメントデータの辞書が詰まったcommentsOfPostData配列の中身は、HomeViewControllerから渡してもらったもので、
    // タップしたセルの投稿のコメント配列が代入されている commentsOfPostData = postData.comments
    // commentsOfPostData の中身は、[commentDic1, commentDic2, commentDic3, ...]になっている。commentDicに、コメント１件分のデータが詰まっている。
    var commentsOfPostData: [[String: Any]]!
    var postData: PostData!   // リスナー登録により、postDataだけでは、更新データ入らず、古い。idだけ貰えば良くなりそう。
    var postId: String!
    
    
    
    // HomeViewControllerから渡された投稿の、コメントのインスタンスを入れる配列 viewWillAppearの中でインスタンスを生成し、この配列に入れる
    var commentArray: [CommentData] = []
    
    // コメントにリスナーを設定してみる おそらく、これでコメント画面遷移後に、誰かがコメント投稿しても反映される。
    var commentListener: ListenerRegistration!
    
    // コメント投稿ボタンを押して、コメント全件表示画面に遷移した際に渡すための値　　不要？
    var commentsOfPostDataForCommentView: [[String: Any]]!
    var postDataForCommentView: PostData!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentInputTextView.delegate = self
        
        // 投稿者のキャプションのラベルには、枠線を入れる
        captionLabel.layer.borderWidth = 0.5
        captionLabel.layer.borderColor = UIColor.gray.cgColor
        captionLabel.backgroundColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.5)
        captionLabel.layer.cornerRadius = 5.0
        captionLabel.clipsToBounds = true
        
        // 投稿者の表示名と、キャプションをセット
        self.displayNameLabel.text = "\(postData.name!)"
        self.captionLabel.text = "\(postData.caption!)"

        
        // カスタムセルの登録
        let nib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        commentTableView.register(nib, forCellReuseIdentifier: "CommentCell")
        
        
        // commentInputTextViewの枠の設定
        commentInputTextView.layer.borderColor = UIColor.gray.cgColor
        commentInputTextView.layer.borderWidth = 2.0
        commentInputTextView.layer.cornerRadius = 20.0
        commentInputTextView.layer.masksToBounds = true
    }
    
    
    
    // 画面表示のたびに呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 入力用のTextViewにカーソルが入っているように設定
        self.commentInputTextView.becomeFirstResponder()
        
        
        // 該当する投稿のコメントが追加されるたびに検知してくれる（はず）。リスナーの削除は、画面遷移時
        // 当初は、postDataごとHomeViewから渡してもらっていたが、リスナーを設置し、画面遷移後に投稿された新しいデータを反映するため、書き換えた。
        if commentListener == nil {
            
            //該当する投稿のPath
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postId)
            
            commentListener = postRef.addSnapshotListener() { (document, error) in   //このdocumentはQueryDocumentSnapshot型に変更できず。 （postDataのインスタンス生成には使えない。）
                if let error = error {
                    print("DEBUG_PRINT: コメントのSnapshot取得に失敗しました。エラー内容: \(error)")
                    return
                }
                let postData = document!.data()
                
                
                if let postDic = postData {
                    if let comments = postDic["comments"] as? [[String: Any]] {
                        self.commentsOfPostData = comments
                        self.commentArray = self.commentsOfPostData.map { commentDic in
                            let commentData = CommentData(commentDic: commentDic)
                            
                            return commentData
                        }
                    }
                }
                self.commentTableView.reloadData()
            }
        }
    }
    
    
    
    // セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    
    // セルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        
        cell.setCommentData(commentArray[indexPath.row])
        
        //　コメントに対する「いいね！」ボタンのアクションをソースコードで設定する
        //cell.commentLikeButton.addTarget(self, action:#selector(handleCommentLikeButton(_: forEvent: )), for: .touchUpInside)
        
        return cell
    }
    
    
    
    
    // コメント投稿ボタンを押した時呼ばれるメソッド
    @IBAction func handleCommentPostButton(_ sender: Any) {
        // HUDで処理中の表示を開始
        SVProgressHUD.show()
        
        
        if let commentContent = self.commentInputTextView.text {  // textViewに文字がある事を確認
            
            let name = Auth.auth().currentUser?.displayName

            
            let commentDic = [
                "displayNameOfComment" : name!,
                "commentContent" : commentContent,
                "commentDate" : Timestamp(date: Date())     //FieldValue.serverTimestamp()は、使えなかった。
            ] as [String : Any]
            
            let updateValue = FieldValue.arrayUnion([commentDic])
            
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["comments": updateValue])

        }
        self.commentTableView.reloadData()
        

        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "コメントを投稿しました")
        
        // 画面遷移前に、リスナーを削除しておく presentのcompletionに入れるべき？
        if commentListener != nil {
            commentListener.remove()
            commentListener = nil
            //commentArray = []　ここのタイミングで空っぽにしてしまうと、エラーになる。commentArray.count = 0になるため。completionなら可？
        }
        
        // コメント一覧画面にモーダル遷移 (ホーム画面に戻るには、そこからナビゲーションバーの < で遷移）
        let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "commentList") as! CommentViewController
        //commentViewController.commentsOfPostData = commentsOfPostDataForCommentView 画面遷移後に取得しないと、投稿コメント反映されない
        commentViewController.postId = postId
        self.present(commentViewController, animated: true, completion: nil)
        
    }
    
    
    // textViewのデリゲート 入力を検知したら、「コメント...」を削除する -> viewWillAppearにfirstResponderを設定したら、不要になったかも。。。
    func textViewDidBeginEditing(_ textView: UITextView) {
        commentInputTextView.text = ""
    }
    
    /*
    // コメントの「いいね！」❤︎ボタンが押された時に呼ばれるメソッド
    @objc func handleCommentLikeButton(_ sender: UIButton, forEvent event: UIEvent) {
        
           
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.commentTableView)
        let indexPath = commentTableView.indexPathForRow(at: point)
           
        // 配列からタップされたインデックスのデータを取り出す
        let commentData = commentArray[indexPath!.row]
           
          
        if let myid = Auth.auth().currentUser?.uid {
               
            var updateValue: FieldValue
            if commentData.isCommentLiked {
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                updateValue = FieldValue.arrayUnion([myid])
            }
               
            // commentLikes配列までのアクセスは、これでできているのか？
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["comments.commentData.commentLikes": updateValue])
            //idで特定されたpostData["comments"][indexPath!.row]["commentLikes"]
               
        }
        
    }
    */

    
    // < ボタンを押した時
    @IBAction func handleBackButton(_ sender: Any) {
        
        // 画面遷移前に、リスナーを削除しておく　completionの中に入れるべき？
        if commentListener != nil {
            commentListener.remove()
            commentListener = nil
            commentArray = []
        }
        
        self.dismiss(animated: true, completion: nil)
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