//
//  DetailViewCCViewController.swift
//  Mohammad Dawi

import UIKit

class DetailViewCCViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var wv: UIWebView?
    var wiki: String?
    var spinner = UIActivityIndicatorView(style: .gray)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Position Activity Indicator in the center of the main view
        spinner.center = view.center
        view.addSubview(spinner)
        //customize the back button to navigate back in web view
        let backButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Previous", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButtonItem
        
        wv?.delegate = self
        //load the web url page for the articel or publication
        let nsurl: NSURL = NSURL(string: wiki!)!
        let nsrequest: NSURLRequest = NSURLRequest(url: nsurl as URL)
        wv?.loadRequest(nsrequest as URLRequest)
        // Start Activity Indicator
        spinner.startAnimating()
    }
    
    func goBack(_ sender: Any) {
        if (wv?.canGoBack)! {
            wv?.goBack()
        } else {
            //Pop view controller to preview view controller
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.view.viewWithTag(100)?.isHidden = true
        spinner.stopAnimating()
        
    }
    
    /*
     #pragma mark - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}
