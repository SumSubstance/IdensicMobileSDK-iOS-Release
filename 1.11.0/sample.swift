//
//  sample.swift
//  IdensicMobileSDK
//
//  Copyright © 2020 Sum & Substance. All rights reserved.
//
import UIKit
import IdensicMobileSDK

class ViewController: UIViewController {
    
    let baseUrl = "https://test-api.sumsub.com" // or "https://api.sumsub.com" for production
    let accessToken = "..." // get accessToken for the applicant to be verified from your backend
    let flowName = "..." // the name of the applicant flow (must be set up via the dashboard)
    let locale = Locale.current.identifier // or any locale in a form of "en" or "en_US"
    let supportEmail = "support@your-company.com" // or use `nil` and configure Support Items later on

    var sdk: SNSMobileSDK!
    
    func start() {
        
        sdk = SNSMobileSDK(
            baseUrl: baseUrl,
            flowName: flowName,
            accessToken: accessToken,
            locale: locale,
            supportEmail: supportEmail
        )
        
        guard sdk.isReady else {
            print("Initialization failed: " + sdk.verboseStatus)
            return
        }

        // Advanced setup (it's optional and could be skipped)
        
        setupLogging()
        setupHandlers()
        setupCallbacks()
        setupSupportItems()
        setupTheme()

        // Present UI
        
        present(sdk.mainVC, animated: true, completion: nil)
    }
    
    func setupLogging() {
        
        #if DEBUG
        
        // Change `logLevel` to see more info in console (it set to `.error` by default)
        sdk.logLevel = .error
        
        // By default SDK uses `NSLog` for the logging purposes. If it does not work, you could use `logHandler` to overcome.
        sdk.logHandler { (level, message) in
            print(Date(), "[Idensic] \(message)")
        }
        
        #else
        
        // Perhaps it's good idea to shut the logs down in production
        sdk.logLevel = .off
        
        #endif
    }

    func setupHandlers() {
        
        // Get new token using your backend then call `onComplete` to pass new token back
        sdk.tokenExpirationHandler { (onComplete) in
            get_token_from_your_backend { (newToken) in
                onComplete(newToken)
            }
        }
        
        // Fired when verification process is done with a final decision
        sdk.verificationHandler { (isApproved) in
            print("verificationHandler: Applicant is " + (isApproved ? "approved" : "finally rejected"))
        }
        
        // If `dismissHandler` is assigned, it's up to you to dismiss the `mainVC` controller.
        sdk.dismissHandler { (sdk, mainVC) in
            mainVC.dismiss(animated: true, completion: nil)
        }

    }
    
    func setupCallbacks() {
        
        // Fired when the sdk's status has been updated
        sdk.onStatusDidChange { (sdk, prevStatus) in
            
            print("onStatusDidChange: [\(sdk.description(for: prevStatus))] -> [\(sdk.description(for: sdk.status))]")
            
            switch sdk.status {
                
            case .ready:
                // Technically .ready couldn't ever be passed here, since the callback has been set after `status` became .ready
                break

            case .failed:
                print("failReason: [\(sdk.description(for: sdk.failReason))] - \(sdk.verboseStatus)")
                
            case .initial:
                print("No verification steps are passed yet")
                
            case .incomplete:
                print("Some but not all of the verification steps have been passed over")
                
            case .pending:
                print("Verification is pending")
                
            case .temporarilyDeclined:
                print("Applicant has been declined temporarily")
                
            case .finallyRejected:
                print("Applicant has been finally rejected")
                
            case .approved:
                print("Applicant has been approved")
            }
        }
        
        // A way to be notified when `mainVC` is dismissed
        sdk.onDidDismiss { (sdk) in
            print("onDidDismiss: sdk has been dismissed with status [\(sdk.description(for: sdk.status))]")
        }

    }
        
    func setupSupportItems() {
        
        // Add Support Items if required
        
        sdk.addSupportItem { (item) in
            item.title = NSLocalizedString("URL Item", comment: "")
            item.subtitle = NSLocalizedString("Tap me to open an url", comment: "")
            item.icon = UIImage(named: "AppIcon")
            item.actionURL = URL(string: "https://google.com")
        }

        sdk.addSupportItem { (item) in
            item.title = NSLocalizedString("Callback Item", comment: "")
            item.subtitle = NSLocalizedString("Tap me to get callback fired", comment: "")
            item.icon = UIImage(named: "AppIcon")
            item.actionHandler { (supportVC, item) in
                print("[\(item.title)] tapped")
            }
        }
    }
    
    func setupTheme() {

        // You could either adjust UI in place
        sdk.theme.sns_CameraScreenTorchButtonTintColor = .white

        // or apply your own Theme if it's more convenient
        sdk.theme = OwnTheme()
    }
    
}

fileprivate class OwnTheme: SNSTheme {
    override init() {
        super.init()
        
        sns_CameraScreenTorchButtonTintColor = .white
    }
}

fileprivate func get_token_from_your_backend(_ onComplete: @escaping (_ newToken: String?) -> Void) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let newToken = "..."
        onComplete(newToken)
    }
}
