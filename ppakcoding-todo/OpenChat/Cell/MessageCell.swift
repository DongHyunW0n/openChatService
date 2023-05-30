//
//  MessageCell.swift
//  ppakcoding-todo
//
//  Created by WonDongHyun on 2023/05/30.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImgView : UIImageView!
    
    @IBOutlet weak var messageLabel : UILabel!
    
    @IBOutlet weak var timestampLabel : UILabel!

    @IBOutlet weak var userNicknameLabel : UILabel!


    @IBOutlet weak var messageBubbleView: UIView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
