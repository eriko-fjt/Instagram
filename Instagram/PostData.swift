
import UIKit
import Firebase

class PostData: NSObject {
    
    /*
     Firestoreに保存してあるデータで、PostPathに保存してあり、swiftで使いたいデータは、
     ここで取得して、このクラスのイニシャライザにセットして、インスタンス生成時にswiftで使えるように変換しておく。
     （PostData型（PostDataクラス）として他のクラスで使えるように）
     
     */
    
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false  // likes配列の中にユーザ自身のIDが入っているかどうか
    
    
    // 以下、課題の各投稿に対するコメントに関する変数
    var comments: [[String: Any]] = []   // 辞書形式のコメントデータが入った配列　か
    
    /*以下は、上記commentsに入っている１件分のコメントデータ（辞書形式）。
     表示には、コメント１件１件のインスタンスを生成して使うのでCommentData.swiftのイニシャライザにセットする
     
     var displayNameOfComment: String?
     var commentContent: String?
     var commentDate: Date?
     
     var commentLikes: [String] = []
     var isCommentLiked: Bool = false
     
     */
    
    // 課題には、各投稿のキャプションの下にコメントを表示する指定があるので、最新のコメント2件のみ、「表示名：コメント文」を表示することにする
    // 現在のInstagramの仕様(現行Instagramは投稿画面には２行のみ表示）を参考に、全件表示する別ビューを用意するので３件目以降はそちらで見るようにする
    /* PostTableView.swiftで定義したsetPostData(_ postData: PostData)は、
     postDataのインスタンスを引数に入れただけで、HomeViewの1件分の投稿を入れるセルに表示する内容の全てを取得できなければいけない。
     そのため、キャプションの下に表示するコメントのデータも、ここで用意しておかなければいけない.
     全件取得して表示するのは、実際のアプリとしては現実的ではないので　ここでは、２件のみ*/
    
    var displayNameOfComment1: String?
    var commentContent1: String?
    
    var displayNameOfComment2: String?
    var commentContent2: String?
    
    
    init(document: QueryDocumentSnapshot) {
        
        self.id = document.documentID
        
        let postDic = document.data()
        
        self.name = postDic["name"] as? String
        
        self.caption = postDic["caption"] as? String
        
        let timestamp = postDic["date"] as? Timestamp
        
        self.date = timestamp?.dateValue()
        
        if let likes = postDic["likes"] as? [String] {  // if postDic["likes"] as? [String] != nil {let likes = ...以下略）}
            self.likes = likes
        }
        
        
        if let myid = Auth.auth().currentUser?.uid {
            
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                
                // myidがあれば、いいねを押していると認識する
                self.isLiked = true
            }
        }
        
        // 以下、課題
        if let comments = postDic["comments"] as? [[String: Any]] {
            
            self.comments = comments   // この中には、配列で、コメントのDicが入っている[ コメントDic1, コメントDic2, コメントDic3, ...]
            
            // コメントは、配列の最後に追加される形で追加になるので、配列の最後にあるものほど新しい（はず）
            if comments.count == 0 {
                
                self.displayNameOfComment1 = ""
                self.commentContent1 = ""
                
                self.displayNameOfComment2 = ""
                self.commentContent2 = ""
                
            } else if comments.count == 1 {  // comments配列の要素が１つしかない場合
                
                let commentDic1 = comments[comments.count - 1]   //配列の要素数−１が、一番最後の要素のインデックス
                self.displayNameOfComment1 = commentDic1["displayNameOfComment"] as? String
                self.commentContent1 = commentDic1["commentContent"] as? String
                
                self.displayNameOfComment2 = ""
                self.commentContent2 = ""
                
            } else if comments.count >= 2 { // comments配列の要素が２つ以上ある場合
                
                let commentDic1 = comments[comments.count - 1]
                self.displayNameOfComment1 = commentDic1["displayNameOfComment"] as? String
                self.commentContent1 = commentDic1["commentContent"] as? String
                
                let commentDic2 = comments[comments.count - 2]
                self.displayNameOfComment2 = commentDic2["displayNameOfComment"] as? String
                self.commentContent2 = commentDic2["commentContent"] as? String
                
            }
        }
        
        
    }
    
    
    

}
