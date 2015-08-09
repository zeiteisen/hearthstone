import UIKit

class ZEArenaPickViewController: UIViewController {
    @IBOutlet weak var firstCardButton: SmartButton!
    @IBOutlet weak var secondCardButton: SmartButton!
    @IBOutlet weak var thirdCardButton: SmartButton!
    
    private var drafts: NSArray!
    private var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let quizzes = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("ArenaDrafts", ofType: "plist")!)!
        let firstQuiz = quizzes[0] as! NSDictionary
        drafts = firstQuiz["draft"] as! NSArray
        updateCardsWithCurrentIndex(currentIndex)
    }
    
    func imageFromName(name: String) -> UIImage {
        let imageName = "\(name).jpg"
        return UIImage(named: imageName)!
    }
    
    func updateCardsWithCurrentIndex(index: Int) {
        let draft = drafts[index] as! NSDictionary
        let first = draft["1"] as! String
        let second = draft["2"] as! String
        let third = draft["3"] as! String
//        let pick = draft["pick"] as! String
        firstCardButton.setImage(imageFromName(first), forState: .Normal)
        secondCardButton.setImage(imageFromName(second), forState: .Normal)
        thirdCardButton.setImage(imageFromName(third), forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as! ZEAppDelegate
        appDelegate.onlyPortrait = false
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeLeft.rawValue, forKey: "orientation")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as! ZEAppDelegate
        appDelegate.onlyPortrait = true
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
    }
    
    func showNext() {
        if drafts.count > currentIndex + 1 {
            currentIndex++
            updateCardsWithCurrentIndex(currentIndex)
        }
    }
    
    @IBAction func firstTouched(sender: AnyObject) {
        showNext()
    }
    
    @IBAction func secondTouched(sender: AnyObject) {
        showNext()
    }
    
    @IBAction func thirdTouched(sender: AnyObject) {
        showNext()
    }
    
}
