//
//  KinveyErrorCodes.h
//  KinveyKit
//
//  Created by Brian Wilson on 1/10/12.
//  Copyright (c) 2012-2013 Kinvey. All rights reserved.
//

#ifndef KinveyKit_KinveyErrorCodes_h
#define KinveyKit_KinveyErrorCodes_h

// NSError UserInfo Keys
/** String Error code that corresponds to a specific error on the server. This can be used as the key for checking the error type or creating localized errors */
#define KCSErrorCode @"kinveyErrorCode"
/** This is an optional server error string, useful for reporting back to Kinvey for debugging purposes. */
#define KCSErrorInternalError @"kinveyInternalErrorString"
/** This is an optional request id, useful for reporting back to Kinvey for debugging purposes. */
#define KCSRequestId @"kinveyRequestId"

// Error Domains
#define KCSNetworkErrorDomain @"KCSNetworkErrorDomain"
#define KCSAppDataErrorDomain @"KCSAppDataErrorDomain"
#define KCSResourceErrorDomain @"KCSResourceErrorDomain"
#define KCSDatalinkErrorDomain @"KCSDatalinkErrorDomain"
#define KCSUserErrorDomain @"KCSUserErrorDomain"
#define KCSPushErrorDomain @"KCSPushErrorDomain"
#define KCSErrorDomain @"KCSErrorDomain"
#define KCSServerErrorDomain @"KCSServerErrorDomain"

// Error Codes
typedef enum KCSErrorCodes : NSInteger {
    // Error Codes Based on HTTP
    KCSBadRequestError = 400,
    KCSDeniedError = 401,
    KCSForbiddenError = 403,
    KCSNotFoundError = 404,
    KCSBadMethodError = 405,
    KCSNoneAcceptableError = 406,
    KCSProxyAuthRequiredError = 407,
    KCSRequestTimeoutError = 408,
    KCSConflictError = 409,
    KCSGoneError = 410,
    KCSLengthRequiredError = 411,
    KCSPrecondFailedError = 412,
    KCSRequestTooLargeError = 413,
    KCSUriTooLongError = 414,
    KCSUnsupportedMediaError = 415,
    KCSRetryWithError = 449,
    KCSServerErrorError = 500,
    KCSNotSupportedError = 501,
    KCSBadGatewayError = 502,
    KCSServiceUnavailableError = 503,
    KCSGatewayTimeoutError = 504,
    KCSVersionNotSupporteError = 505,
    KCSBackendLogicError = 550,
    
    
    // Internal Library Codes (starting at 60000)
    KCSUnderlyingNetworkConnectionCreationFailureError = 60000,
    KCSNetworkUnreachableError = 60001,
    KCSKinveyUnreachableError = 60002,
    KCSUserCreationContentionTimeoutError = 60003,
    KCSUserNoImplictUserError = 60014,
    KCSUnexpectedResultFromServerError = 60004,
    KCSAuthenticationRetryError = 60005,
    KCSUserAlreadyLoggedInError = 60006,
    KCSUserAlreadyExistsError = 60007,
    KCSOperationRequiresCurrentUserError = 60008,
    KCSLoginFailureError = 60009,
    KCSUnexpectedError = 60010,
    KCSFileError = 60011,
    KCSInvalidArgumentError = 60012,
    KCSInvalidJSONFormatError = 60013,
    
    KCSReferenceNoIdSetError = 60101,
    KCSInvalidKCSPersistableError = 60102,
    
    // For testing only, no user should ever see this!
    KCSTestingError = 65535
    
} KCSErrorCodes;


#endif
