//
//  sample.swift
//  IdensicMobileSDK
//
//  Copyright © 2021 Sum & Substance. All rights reserved.
//
import UIKit
import IdensicMobileSDK

class ViewController: UIViewController {
    
    var sdk: SNSMobileSDK!
    
    // MARK: -
    
    func start(fromVC: UIViewController? = nil) {

        // MARK: Initialization
        //
        // From your backend get an access token for the applicant to be verified.
        // The token must be generated with `levelName` and `userId`,
        // where `levelName` is the name of a level configured in your dashboard.
        //
        // The sdk will work in the production or in the sandbox environment
        // depend on which one the `accessToken` has been generated on.
        //
        let accessToken = "..."

        sdk = SNSMobileSDK(
            accessToken: accessToken
        )
        
        guard sdk.isReady else {
            print("Initialization failed: " + sdk.verboseStatus)
            return
        }

        // MARK: tokenExpirationHandler
        //
        // The access token has a limited lifespan and when it's expired, you must provide another one.
        // Get a new token using your backend, then call `onComplete` to pass the new token back.
        //
        sdk.tokenExpirationHandler { (onComplete) in
            get_token_from_your_backend { (newToken) in
                onComplete(newToken)
            }
        }
        
        // MARK: Advanced setup
        //
        // It's optional and could be skipped
        //
        setupLogging()
        setupHandlers()
        setupCallbacks()
        setupLocalization()
        setupSupportItems()
        setupTheme()

        // MARK: Presentation
        //
        present(sdk.mainVC, animated: true, completion: nil)
    }
    
    // MARK: -
    
    func setupLogging() {
        
        #if DEBUG
        
        // MARK: logLevel
        //
        // Change `logLevel` to see more info in console (it's set to `.error` by default)
        //
        sdk.logLevel = .error
        
        // MARK: logHandler
        //
        // By default, the SDK uses `NSLog` for logging purposes. If it doesn't work, you may use `logHandler`.
        //
        sdk.logHandler { (level, message) in
            print(Date(), "[Idensic] \(message)")
        }
        
        #else
        
        // Perhaps it's a good idea to shut the logs down in production
        sdk.logLevel = .off
        
        #endif
    }

    func setupHandlers() {
        
        // MARK: verificationHandler
        //
        // Fired when the verification process is completed and a final decision has been made
        //
        sdk.verificationHandler { (isApproved) in
            print("verificationHandler: Applicant is " + (isApproved ? "approved" : "finally rejected"))
        }
        
        // MARK: dismissHandler
        //
        // If `dismissHandler` is assigned, it's up to you to dismiss the `mainVC` controller.
        //
        sdk.dismissHandler { (sdk, mainVC) in
            mainVC.presentingViewController?.dismiss(animated: true, completion: nil)
        }

    }
    
    func setupCallbacks() {
        
        // MARK: onStatusDidChange
        //
        // Fired when the SDK's status has been updated
        //
        sdk.onStatusDidChange { (sdk, prevStatus) in
            
            print("onStatusDidChange: [\(sdk.description(for: prevStatus))] -> [\(sdk.description(for: sdk.status))]", terminator: " ")
            
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
                
            case .actionCompleted:
                print("Applicant action has been completed")
            }
        }
        
        // MARK: onEvent
        //
        // Subscribing to `onEvent` allows you to be aware of the events happening along the processing
        //
        sdk.onEvent { (sdk, event) in
            
            switch event.eventType {
            
            case .applicantLoaded:
                if let event = event as? SNSEventApplicantLoaded {
                    print("onEvent: Applicant [\(event.applicantId)] has been loaded")
                }

            case .stepInitiated:
                if let event = event as? SNSEventStepInitiated {
                    print("onEvent: Step [\(event.idDocSetType)] has been initiated")
                }
                
            case .stepCompleted:
                if let event = event as? SNSEventStepCompleted {
                    print("onEvent: Step [\(event.idDocSetType)] has been \(event.isCancelled ? "cancelled" : "fulfilled")")
                }
                
            case .analytics:
                if let event = event as? SNSEventAnalytics {
                    print("onEvent: Analytics event [\(event.eventName)] has occured with payload=\(event.eventPayload ?? [:])")
                }

            @unknown default:
                print("onEvent: eventType=[\(event.description(for: event.eventType))] payload=\(event.payload)")
            }

        }

        // MARK: onDidDismiss
        //
        // A way to be notified when `mainVC` is dismissed
        //
        sdk.onDidDismiss { (sdk) in
            print("onDidDismiss: sdk has been dismissed with status [\(sdk.description(for: sdk.status))]")
        }

    }
        
    func setupLocalization() {
        
        // MARK: locale
        //
        // Set the locale the sdk should use for texts (the system locale will be used by default)
        // Use locale in a form of `en` or `en_US`
        //
        sdk.locale = Locale.current.identifier
    }
    
    func setupSupportItems() {
        
        // MARK: addSupportItem
        //
        // Add Support Items if required
        //
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

        // MARK: theme
        //
        // You could either adjust UI in place,
        //
        sdk.theme.fonts.headline1 = .systemFont(ofSize: 24, weight: .bold)
        sdk.theme.colors.secondaryButtonBackground = .clear
        
        // or apply your own Theme if it's more convenient
        sdk.theme = OwnTheme()
    }
    
}

// MARK: -

fileprivate class OwnTheme: SNSTheme {
    override init() {
        super.init()

        fonts.headline1 = .systemFont(ofSize: 24, weight: .bold)
        colors.secondaryButtonBackground = .clear
    }
}

// MARK: -

fileprivate func get_token_from_your_backend(_ onComplete: @escaping (_ newToken: String?) -> Void) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let newToken = "..."
        onComplete(newToken)
    }
}
