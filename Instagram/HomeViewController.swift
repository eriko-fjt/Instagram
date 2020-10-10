

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firebaseのリスナー
    var listener: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムcellを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
    }
    
    
    // この中に、投稿データを読み込む処理を追加する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRING: viewWillAppear")
        
        
        if Auth.auth().currentUser != nil {   // ログインしている
            
            if listener == nil {
                
                // listener未登録なら、登録してスナップショットを受信する    // 各documentのDataの”date"順にソート
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    
                    if let error = error {  // if error != nil { let error = error! }のこと？！
                        print("DEBUG_PRINT: snapshotの取得に失敗しました。\(error)")
                        return
                    }
                    
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得\(document.documentID)")
                        
                        let postData = PostData(document: document)
                        return postData
                    }
                    
                    // TableViewの表示を更新
                    self.tableView.reloadData()
                }
            }
            
        } else {    // 未ログイン（またはログアウト済）
            
            if listener != nil {   // listener登録済なら削除してpostArrayをクリアする
                
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])  // setPostDataメソッドは、PostTableViewcell.swiftで設定
        
        
        // セル内のボタン（いいねボタン）のアクションをソースコードで設定する（9.4で追記）
        cell.likeButton.addTarget(self, action: #selector(handleButton(_: forEvent:)), for: .touchUpInside)
        
        // 課題
        // セル内の、コメント入力用の吹き出しボタンのアクションを設定
        cell.commentInputButton.addTarget(self, action: #selector(handleCommentInputButton(_:forEvent:)), for: .touchUpInside)
        
        // セル内の、コメント全件表示ボタンのアクションをソースコードで設定する
        cell.displayAllCommentsButton.addTarget(self, action: #selector(handleDisplayAllCommentsButton(_: forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    
    
    // いいね、ボタンが押された時に呼ばれる
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                
                // 既にいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
                
            } else {
                
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    
    // 課題
    
    // コメント入力ボタン押下時（コメント入力画面への遷移　＊値の受け渡しあり）
    @objc func handleCommentInputButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        print("DEBUG_PRINT: コメント入力ボタンがタップされました。")
        
        // タップされた投稿のセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // 配列からタップされたインデックスのデータを取り出して、commentInputViewに渡す
        //let postData = postArray[indexPath!.row]
        //　CommentInputViewController画面へ遷移する(documentIDを渡す）
        let commentInputViewController = self.storyboard?.instantiateViewController(identifier: "commentInput") as! CommentInputViewController
        
        //commentInputViewController.commentsOfPostData = postData.comments //遷移後に新たに取得するので、受け渡しはしない。
        commentInputViewController.postData = postData
        commentInputViewController.postId = postData.id
        self.present(commentInputViewController, animated: true, completion: nil)
        
    }
    
    
    
    // 全コメント表示ボタン押下時
    @objc func handleDisplayAllCommentsButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        print("DEBUG_PRINT: comment全件表示ボタンがタップされました。")
        
        // タップされた投稿のセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        
        
        // commeentViewControllerは、コメント全件表示画面
        let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "commentList") as! CommentViewController
        
        // コメントの入ったpostDataは、画面遷移後に改めて取得するように仕様変更（更新データを都度取得できるようにする）したため、渡さないことにした
        // ただし、実際のアプリでは重区なるかもしれないので、オンタイムでコメントを取得するのが良いのかどうかは、都度考えるべき。
        
        //commentViewController.postData = postData
        //commentViewController.commentsOfPostData = postData.comments  // タップされたインデックスのpostData(投稿）の、comments(配列)を渡す
        commentViewController.postId = postData.id
        self.present(commentViewController, animated: true, completion: nil)
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
