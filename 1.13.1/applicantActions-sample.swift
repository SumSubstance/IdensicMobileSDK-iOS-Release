//
//  applicantActions-sample.swift
//  IdensicMobileSDK
//
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import IdensicMobileSDK

class ApplicantActionVC: UIViewController {
    
    let baseUrl = "https://test-api.sumsub.com" // or "https://api.sumsub.com" for production
    let flowName = "your-action-flow" // the name of the applicant action flow (must be set up via the dashboard)
    let accessToken = "..." // an access token for the applicant the action should perform against (it must be generated with both `userId` and `externalActionId` parameters)
    let locale = Locale.current.identifier // or any locale in a form of "en" or "en_US"
    let supportEmail = "support@your-company.com" // or use `nil` and configure Support Items later on
    
    var sdk: SNSMobileSDK!
    
    func start() {
        
        // Basically you setup the sdk the same way as you do with regular flows, the only difference is how you get the action results.
        // Below we'll use `onDidDismiss` to inspect the `sdk.status` and `sdk.actionResult`.
        // It's possible to use `dismissHandler` or `onStatusDidChange` callbacks as well, use them for your convenience.
        
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
        
        // Setup callback to take the action's result when sdk is dismissed
        
        sdk.onDidDismiss { (sdk) in
            
            switch sdk.status {
            
            case .initial:
                // normally the action flow would be failed or completed, so you could see `.initial` in `onStatusDidChange` only,
                // it just means that the action data were sucessfully loaded
                break;
                
            case .failed:
                print("failReason: [\(sdk.description(for: sdk.failReason))] - \(sdk.verboseStatus)")
            
            case .actionCompleted:
                // the action was performed or cancelled
                
                if let result = sdk.actionResult {
                    print("Last action result: actionId=\(result.actionId) answer=\(result.answer ?? "<none>")")
                } else {
                    print("The action was cancelled")
                }
                
            default:
                // in case of action flow the other statuses are not used for now
                break;
            }
        }
        
        // Optionally it's possible to get the action's result once it has arrived from the backend.
        // The user sees the "Processing..." screen at this moment.

        sdk.actionResultHandler { (sdk, result, onComplete) in

            print("actionResultHandler: actionId=\(result.actionId) answer=\(result.answer ?? "<none>")")
            
            // you are allowed to process the result asynchronously, just don;t forget to call `onComplete` when you finished,
            // you could pass `.cancel` to force the user interface to be closed, or `.continue` to proceed as usual
            onComplete(.continue)
        }
        
        // Present UI
        
        present(sdk.mainVC, animated: true, completion: nil)
    }

}
