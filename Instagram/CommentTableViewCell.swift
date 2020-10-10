

import UIKit
import Firebase

class CommentTableViewCell: UITableViewCell {
    
    /*
     このクラスには、コメントを表示するセルのOutletと、CommentViewControllerで使う setCommentData(_ commentData: CommentData) を定義する.
     setCommentDataは、commentDataのインスタンスが渡されてきた時に、必要なすべてのデータを部品にセットする
     */
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var commentDateLabel: UILabel!
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    
    
    
    //@IBOutlet weak var commentLikeButton: UIButton!  // Firestoreで更新時のアクセル方法がわからず、コメントへの「いいね！」は断念
    
    //@IBOutlet weak var commentLikeNumberLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profilePhotoImageView.layer.borderColor = UIColor.gray.cgColor
        self.profilePhotoImageView.layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // CommentDataのインスタンスを引数に入れたら、表示に必要なデータを取り出し、各部品にセットする
    func setCommentData(_ commentData: CommentData) {
        
        // プロフィールアイコンの表示
        let photoRef = Storage.storage().reference().child(Const.ProfilePhotoPath).child(commentData.displayNameOfComment! + ".jpg")
        profilePhotoImageView.sd_setImage(with: photoRef)
        
        // コメント投稿者の表示名
        self.displayNameLabel.text = "\(commentData.displayNameOfComment!) "
        // コメント入力者の表示名と、コメント本文表示
        self.commentLabel.text = " \(commentData.commentContent!)"
        
        // コメント日時
        // 現在時刻を取得して、コメント日時との差を表示したいが、とりあえずは、日付を表示する仕様にしておく
        let currentDate = Date() //本当はサーバの現在時間を取得したかったが、分からないので。。//FieldValue.serverTimestamp()
        self.commentDateLabel.text = ""
        self.commentDateLabel.textColor = UIColor.gray

        if let commentDate = commentData.commentDate {   // commentDateは、この時点ではDate型
            
            let formatter = DateFormatter()   // DateFormatterのインスタンス
            
            formatter.locale = Locale(identifier: "ja_JP")
            
            formatter.dateStyle = .long  // yyyy年MM月dd日の表記  ホームビューとは異なる形式だが、練習のため
            formatter.timeStyle = .short  // HH:mm　の表記
            

            //formatter.dateFormat = "yyyy-MM-dd HH:mm"
            //let commentDateString = formatter.string(from: commentDate)
            
            // ---ここから、現在時刻との差によって、表示の場合分け ---
            //全て秒間の差だけで、* 60 * 60 * とやればいいのだが、練習のために、秒・分・時間・日差全て求めて使う---
            let cal = Calendar(identifier: .gregorian)
            
            let diffSec = cal.dateComponents([.second], from: commentDate, to: currentDate)
            let diffMin = cal.dateComponents([.minute], from: commentDate, to: currentDate)
            let diffHour = cal.dateComponents([.hour], from: commentDate, to: currentDate)
            let diffDay = cal.dateComponents([.day], from: commentDate, to: currentDate)
            
            let commentDateString = formatter.string(from: commentDate)
            // すべて秒で差を見ないと、漏れが出る?
            
            if diffSec.second! >= 0 && diffSec.second! < 60 {
                self.commentDateLabel.text = "1分未満"
                
            } else if diffMin.minute! >= 1 && diffMin.minute! < 60 {
            
                self.commentDateLabel.text = "\(diffMin.minute!)分前"
                
            } else if diffHour.hour! >= 1 && diffHour.hour! < 24 {
            
                self.commentDateLabel.text = "\(diffHour.hour!)時間前"
                
            } else if diffDay.day! >= 1 && diffDay.day! < 4 {
                
                self.commentDateLabel.text = "\(diffDay.day!)日前"
                
            } else {
                // 4日後からは、日付と時刻
                self.commentDateLabel.text = commentDateString
                 // ---ここまで、コメント投稿日時の場合分け
            }
            
            
            
        }
        
        /*
        //ドキュメント＞コメントの辞書　へのアクセスがわからず、断念
        //コメントに対するいいね数の表示
        
        let commentLikeNumber = commentData.commentLikes.count
        self.commentLikeNumberLabel.text = "\(commentLikeNumber)"
        
        
        if commentData.isCommentLiked {
            let buttonImage = UIImage(systemName: "heart.fill")
            self.commentLikeButton.setImage(buttonImage, for: .normal)
            
        } else {
            let buttonImage = UIImage(systemName: "heart")
            self.commentLikeButton.setImage(buttonImage, for: .normal)
        }
        */
        
        
        
        
    }
    
}
