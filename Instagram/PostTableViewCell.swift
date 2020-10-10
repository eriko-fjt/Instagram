

import UIKit
import FirebaseUI



class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeLabel: UILabel!    // いいね！の数表示
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    
    
    // 以下、課題用
    //コメント入力用ボタン（吹き出し）
    @IBOutlet weak var commentInputButton: UIButton!
    
    
    // 1件目（最新）のコメント表示用ラベル
    @IBOutlet weak var firstCommentLabel: UILabel!
    
    // 2番目に新しいコメント表示用ラベル
    @IBOutlet weak var secondCommentLabel: UILabel!
    
    // コメント全件表示ボタン　「コメントxx件 すべてを表示」
    @IBOutlet weak var displayAllCommentsButton: UIButton!
    
    // プロフィールアイコン
    @IBOutlet weak var profileImageView: UIImageView!
    
    // 投稿者の表示名
    @IBOutlet weak var displayNameLabel: UILabel!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImageView.layer.borderColor = UIColor.gray.cgColor
        self.profileImageView.layer.borderWidth = 0.5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        
        //表示名
        self.displayNameLabel.text = "\(postData.name!)"
        // プロフィールアイコンの表示
        let photoRef = Storage.storage().reference().child(Const.ProfilePhotoPath).child(postData.name! + ".jpg")
        profileImageView.sd_setImage(with: photoRef)
        
        
        
        // 画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        
        postImageView.sd_setImage(with: imageRef)
        
        
        // キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        
        
        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {   // if postData.date != nil { let date = postData.date! ...} の意味？
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }
        
        
        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
            
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        // 以下、課題
        // １番新しいのコメントの表示　「表示名（スペース）コメント本文）」
        if  let commentContent1 = postData.commentContent1 {  // postData.commentContent1がnilでない事を確認した上で、セットする
            
            self.firstCommentLabel.text = "\(postData.displayNameOfComment1!)  \(commentContent1)"
        } else {
            self.firstCommentLabel.text = ""
        }
        
        // ２番目に新しいコメントの表示
        if let commentContent2 = postData.commentContent2 {
            
            self.secondCommentLabel.text = "\(postData.displayNameOfComment2!)  \(commentContent2)"
        } else {
            self.secondCommentLabel.text = ""
        }
        
        
        // コメント全件表示ボタンに、「コメントxx件すべて表示」というタイトルを設定
        let totalComments = postData.comments.count   // この投稿に対するコメント件数を取得
        //displayAllCommentsButton.backgroundColor = UIColor.gray
        displayAllCommentsButton.setTitle("コメント\(totalComments)件 すべて表示", for: UIControl.State.normal)
        
    }
    
}
