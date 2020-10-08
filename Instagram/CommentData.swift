//
//  CommentData.swift
//  Instagram
//
//  Created by 藤田恵梨子 on 2020/10/02.
//  Copyright © 2020 eriko.fujita. All rights reserved.
//

import UIKit
import Firebase

class CommentData: NSObject {
    
    /*
     このクラスでは、他のクラスでコメントを表示する際、CommentDataのインスタンスを作成してデータを使えるようにするため、
     プロパティとイニシャライザを設定する.
     プロパティ名は、少々長すぎる気もするが、混同を避けるため、postDicの辞書キーとかぶらないように設定
     */
    
    var displayNameOfComment: String?
    var commentContent: String?              // コメント文
    var commentDate: Date?
    
    //var commentLikes: [String] = []          // 断念
    //var isCommentLiked: Bool = false         // Firestoreのドキュメント内の深い階層には、データの追加は出来ても、更新は難しいかもしれない。
    
    
    
    // １件のpostDataのcommentsにはたくさんのコメントが入っていることもあり、postDataだとイニシャライザの引数には不適当。
    // 引数には、一件分のコメントのデータだけが取り出せる引数を設定する。
    init(commentDic: [String: Any]) {
        
        self.displayNameOfComment = commentDic["displayNameOfComment"] as? String
        self.commentContent = commentDic["commentContent"] as? String
        
        let timestamp = commentDic["commentDate"] as? Timestamp
        self.commentDate = timestamp?.dateValue()      // これで、Date型に変換？  commentDic["commentDate"] as?
        
        
        /*
        // コメントに対する「いいね！」をしたユーザが入っている配列
        if let commentLikes = commentDic["commentLikes"] as? [String] {
            self.commentLikes = commentLikes
        }
        
        // ログインしているユーザ自身がこのコメントに「いいね！」しているかどうか
        if let myid = Auth.auth().currentUser?.uid {
            if self.commentLikes.firstIndex(of: myid) != nil {
                self.isCommentLiked = true
            }
        }
        */
        
    }

}
