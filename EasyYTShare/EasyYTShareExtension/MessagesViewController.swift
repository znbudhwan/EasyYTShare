import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController, UITextViewDelegate {
    
    @IBOutlet weak var textBody: UITextView!
    var keys: NSDictionary?
    var videoWatchID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textBody.textContainer.maximumNumberOfLines = 10
        textBody.textContainer.lineBreakMode = .byTruncatingTail
        textBody.isScrollEnabled = true
        textBody.textColor = UIColor.lightGray
        textBody.text = "Enter name of Youtube video here"
        textBody.delegate = self
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textBody.textColor == UIColor.lightGray && textBody.isFirstResponder {
            textBody.text = nil
            textBody.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textBody.text.isEmpty || textBody.text == "" {
                    textBody.textColor = UIColor.lightGray
                    textBody.text = "Enter name of Youtube video here"
                }
    }
    
    func convertToURLString(textSnippetstring tSS: String)->String {
        let textSnippetString = tSS.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "!", with: "").replacingOccurrences(of: "@", with: "").replacingOccurrences(of: "#", with: "").replacingOccurrences(of: " ", with: ",").replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "%", with: "").replacingOccurrences(of: "^", with: "").replacingOccurrences(of: "&", with: "").replacingOccurrences(of: "*", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: ";", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "\'", with: "").replacingOccurrences(of: "/'", with: "").replacingOccurrences(of: "/n", with: "")
        return textSnippetString
    }
    
    @IBAction func fetchYTVideoData(_ sender: Any) {
        if textBody.textColor != UIColor.lightGray && textBody.text != "" {
            let textSnippetString = convertToURLString(textSnippetstring: textBody.text)
            if let keysDictionary = keys {
                let youtubeAPIKey = keysDictionary["youtubeAPIKey"] as? String
                let youtubeSearchString = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=1&order=relevance&q=" + textSnippetString + "&key=" + youtubeAPIKey!
                let youtubeSearchRequestURL = URL(string: youtubeSearchString)
                URLSession.shared.dataTask(with: youtubeSearchRequestURL!) { (data, response, error) in
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] {
                            if let itemsArray = jsonResult["items"] as? [AnyObject] {
                                if let itemsList = itemsArray[0] as? [String: AnyObject] {
                                    if let idList = itemsList["id"] as? [String: AnyObject] {
                                        if let videoIDString = idList["videoId"] as? String {
                                            DispatchQueue.main.async {
                                                self.videoWatchID = videoIDString
                                                let youtubeWatchString = "https://www.youtube.com/watch?v=" + self.videoWatchID
                                                self.activeConversation?.insertText(youtubeWatchString, completionHandler: nil)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        print("json error: \(error)")
                    }
                }.resume()
            }
        }
    }
}
