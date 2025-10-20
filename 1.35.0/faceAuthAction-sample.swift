//
//  faceAuthAction-sample.swift
//  IdensicMobileSDK
//
//  Copyright © 2024 Sum & Substance. All rights reserved.
//

import IdensicMobileSDK

class ApplicantActionVC: UIViewController {
    
    var sdk: SNSMobileSDK!
    
    // Typically you process applicant actions the same way you do with standard levels,
    // the only case where special handling is required is Face Auth action.
    
    func startFaceAuth() {
        
        // From your backend get an access token for the applicant the action should perform against.
        // The token must be generated with `levelName`, `userId` and `externalActionId` parameters,
        // where `levelName` is the name of an action level configured in your dashboard.
        //
        // The sdk will work in the production or in the sandbox environment
        // depend on which one the `accessToken` has been generated on.
        //
        
        let accessToken = "..."

        // Basically you configure the sdk the same way that you do with other levels,
        // the only difference is in how you get the action's result.
        //
        // Below we'll use `onDidDismiss` to inspect the `sdk.status` and `sdk.actionResult` if required.
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
                // Face Auth action has been performed or cancelled
                
                if let result = sdk.actionResult {
                    print("Face Auth action result: actionId=\(result.actionId) answer=\(result.answer ?? "<none>")")
                } else {
                    print("The action was cancelled")
                }
                
            default:
                // The other statuses are not used for now,
                // but you could see them if the user closes the sdk before the level is loaded
                break;
            }
        }
        
        // Optionally it's possible to get the Face Auth action's result immediately upon it's arrival from the backend.
        // The user sees the "Processing..." screen at this moment.

        sdk.actionResultHandler { (sdk, result, onComplete) in

            print("Face Auth action result handler: actionId=\(result.actionId) answer=\(result.answer ?? "<none>")")
            
            // You are allowed to process the result asynchronously, just don't forget to call `onComplete` when you finish,
            // you could pass `.cancel` to force the user interface to close, or `.continue` to proceed as usual
            onComplete(.continue)
        }
        
        // Present UI
        
        present(sdk.mainVC, animated: true, completion: nil)
    }

}
