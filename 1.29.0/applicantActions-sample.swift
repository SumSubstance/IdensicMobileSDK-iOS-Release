//
//  applicantActions-sample.swift
//  IdensicMobileSDK
//
//  Copyright © 2021 Sum & Substance. All rights reserved.
//

import IdensicMobileSDK

class ApplicantActionVC: UIViewController {
    
    var sdk: SNSMobileSDK!
    
    func start() {
        
        // From your backend get an access token for the applicant the action should perform against.
        // The token must be generated with `levelName`, `userId` and `externalActionId` parameters,
        // where `levelName` is the name of an action level configured in your dashboard.
        //
        // The sdk will work in the production or in the sandbox environment
        // depend on which one the `accessToken` has been generated on.
        //
        
        let accessToken = "..."

        // Basically you setup the sdk the same way that you do with regular levels, the only difference is in how you get the action's result.
        // Below we'll use `onDidDismiss` to inspect the `sdk.status` and `sdk.actionResult`.
        // It's possible to use `dismissHandler` or `onStatusDidChange` callbacks as well, use them for your convenience.
        
        sdk = SNSMobileSDK(
            accessToken: accessToken
        )
        
        guard sdk.isReady else {
            print("Initialization failed: " + sdk.verboseStatus)
            return
        }
        
        // Setup callback to take the action's result when sdk is dismissed
        
        sdk.onDidDismiss { (sdk) in
            
            switch sdk.status {
            
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
                // in case of an action level, the other statuses are not used for now,
                // but you could see them if the user closes the sdk before the level is loaded
                break;
            }
        }
        
        // Optionally it's possible to get the action's result upon it's arrival from the backend.
        // The user sees the "Processing..." screen at this moment.

        sdk.actionResultHandler { (sdk, result, onComplete) in

            print("actionResultHandler: actionId=\(result.actionId) answer=\(result.answer ?? "<none>")")
            
            // you are allowed to process the result asynchronously, just don't forget to call `onComplete` when you finish,
            // you could pass `.cancel` to force the user interface to close, or `.continue` to proceed as usual
            onComplete(.continue)
        }
        
        // Present UI
        
        present(sdk.mainVC, animated: true, completion: nil)
    }

}
