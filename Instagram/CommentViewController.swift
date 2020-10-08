

import UIKit
import Firebase

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /*
     特定の投稿に対するコメント全てを一覧表示表示するクラス
     */
    
    // まず、tableViewをOutletする
    @IBOutlet weak var commentTableView: UITableView!
    
    /*
     途中で方針を変え、今回は練習のため、リスナーを設置した。そのため、画面遷移元からはpostIdのみを渡してもらい、画面遷移してから
     改めてFirestoreにアクセスしてデータを取得している。ただし、処理が重くなる可能性が大きい事、Firestoreはデータの取得・書き込みのたびに
     課金されるようなので、そうであれば、実際には、一度取得したインスタンスを受け渡して使い回す方が、機器への負担・費用的には良いと思慮する。
     即時性が重要視されるものであれば、リスナーを設置して都度情報更新が望ましいと思われる。
     */
    // この↓、コメントデータの辞書が詰まったcommentsOfPostData配列の中身は、HomeViewControllerから渡してもらったもので、
    // タップしたセルの投稿のコメント配列が代入されている commentsOfPostData = postData.comments // これは、処理の際に変数を設定すべきところ
    // commentsOfPostData の中身は、[commentDic1, commentDic2, commentDic3, ...]になっている。commentDicに、コメント１件分のデータが詰まっている。
    //var commentsOfPostData: [[String: Any]]!  当初は、HomeViewやCommentInputViewから渡してもらっていたが、入力したコメント入ってないので使えない。
    //var postData: PostData!
    var postId: String!
    
    // 該当する投稿のコメントのインスタンスを入れる配列 viewWillAppearの中でコメントのインスタンスを生成し、この配列に入れる
    var commentArray: [CommentData] = []
    
    // コメントにリスナーを設定してみる おそらく、これでこの画面遷移後に、誰かがコメント投稿しても反映される。
    var commentListener: ListenerRegistration!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        // カスタムセルの登録
        let nib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        commentTableView.register(nib, forCellReuseIdentifier: "CommentCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ログインの有無の確認・リスナー登録/削除はHomeViewで行っているので、ここではしなくていいとの認識。
        
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
                        let commentsOfPostData = comments
                        self.commentArray = commentsOfPostData.map { commentDic in
                            let commentData = CommentData(commentDic: commentDic)
                            
                            return commentData
                        }
                    }
                }
                self.commentTableView.reloadData()
            }
        }
        
        /*
        //commentsOfPostDataから、一つずつ、コメント１件のデータcommentDic(辞書)を取り出して、
        //コメント配列から一件ずつcommentDicを取り出してインスタンスを生成し、そのインスタンスをcommentArray配列に入れていく
        commentArray = commentsOfPostData.map { commentDic in
            let commentData = CommentData(commentDic: commentDic) // commentDataは、コメント１件分のデータが入ったインスタンス
            return commentData
        }
        self.commentTableView.reloadData()
       */
    }
    
    
    // セルの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
        
    }
    
    // セルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        
        // セルに、コメントデータをセットする
        cell.setCommentData(commentArray[indexPath.row])
        
        //　コメントに対する「いいね！」ボタンのアクションをソースコードで設定する
        //cell.commentLikeButton.addTarget(self, action:#selector(handleCommentLikeButton(_: forEvent: )), for: .touchUpInside)
        
        return cell
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
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postId)
            postRef.updateData(["comments.commentData.commentLikes": updateValue])
            //idで特定されたpostData["comments"][indexPath!.row]["commentLikes"]
            
        }
    }
    */
 
    //戻るボタンが押された時のメソッド
    // Home画面から来る場合と、コメントインプットビューから来る場合があるので、dismissではダメ。先頭画面に戻るようにする
    @IBAction func handleBackButton(_ sender: Any) {
        
        // 画面遷移前に、リスナーを削除しておく　completionの中に入れるべき？
        if commentListener != nil {
            commentListener.remove()
            commentListener = nil
            commentArray = []
        }
        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil )
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
