//
//  Ex+ Bundle.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/09/27.
//

import Foundation

// MARK: Bundle에서 API Key 바로 꺼내쓰기 위한 Extension
// 사용 예시. Bundle.main.(변수명)

extension Bundle {
    // MARK: - Server - Common
    var baseURL: String {
        guard let key = Bundle.main.infoDictionary?["BASE_URL"] as? String else { fatalError("BASE_URL error") }
        return key
    }

    // MARK: - Server - Auth
    var getAuthorizeCodePath: String {
        guard let key = Bundle.main.infoDictionary?["GET_AUTHORIZE_CODE_PATH"] as? String else { fatalError("GET_AUTHORIZE_CODE_PATH error") }
        return key
    }
    var signInPath: String {
        guard let key = Bundle.main.infoDictionary?["SIGN_IN_PATH"] as? String else { fatalError("SIGN_IN_PATH error") }
        return key
    }
    var checkDuplicateNickNamePath: String {
        guard let key = Bundle.main.infoDictionary?["CHECK_DUPLICATE_NICKNAME_PATH"] as? String else { fatalError("CHECK_DUPLICATE_NICKNAME_PATH error") }
        return key
    }
    var setProfilePath: String {
        guard let key = Bundle.main.infoDictionary?["SET_PROFILE_PATH"] as? String else { fatalError("SET_PROFILE_PATH error") }
        return key
    }
    var resignPath: String {
        guard let key = Bundle.main.infoDictionary?["RESIGN_PATH"] as? String else { fatalError("RESIGN_PATH error") }
        return key
    }
    var reIssueTokenPath: String {
        guard let key = Bundle.main.infoDictionary?["REISSUE_TOKEN_PATH"] as? String else { fatalError("REISSUE_TOKEN_PATH error") }
        return key
    }
    var findProfileImgPath: String {
        guard let key = Bundle.main.infoDictionary?["FIND_PROFILE_IMG_PATH"] as? String else { fatalError("FIND_PROFILE_IMG_PATH error") }
        return key
    }
    
    var findIntrodunction: String {
        guard let key = Bundle.main.infoDictionary?["FIND_INTRODUCTION"] as? String else { fatalError("FIND_INTRODUCTION error") }
        return key
    }
    
    var block: String {
        guard let key = Bundle.main.infoDictionary?["BLOCK"] as? String else { fatalError("BLOCK error") }
        return key
    }
    
    var unblock: String {
        guard let key = Bundle.main.infoDictionary?["UNBLOCK"] as? String else { fatalError("UNBLOCK error") }
        return key
    }
        
    // MARK: -  Server - Feed
    var saveFeedPath: String {
        guard let key = Bundle.main.infoDictionary?["SAVE_FEED_PATH"] as? String else { fatalError("SAVE_FEED_PATH error") }
        return key
    }
    
    var findDayFeedPath: String {
        guard let key = Bundle.main.infoDictionary?["FIND_DAY_FEED_PATH"] as? String else { fatalError("FIND_DAY_FEED_PATH error") }
        return key
    }
    
    var findMonthFeedPath: String {
        guard let key = Bundle.main.infoDictionary?["FIND_MONTH_FEED_PATH"] as? String else { fatalError("FIND_MONTH_FEED_PATH error") }
        return key
    }
    
    var findDetailFeed: String {
        guard let key = Bundle.main.infoDictionary?["FIND_DETAIL_FEED_PATH"] as? String else { fatalError("FIND_DETAIL_FEED_PATH error") }
        return key
    }
    
    var findOtherFeed: String {
        guard let key = Bundle.main.infoDictionary?["FIND_OTHER_FEED_PATH"] as? String else { fatalError("FIND_OTHER_FEED_PATH error") }
        return key
    }
    
    var findUserFeed: String {
        guard let key = Bundle.main.infoDictionary?["FIND_USER_FEED_PATH"] as? String else { fatalError("FIND_USER_FEED_PATH error") }
        return key
    }
    
    var analysisHappinessPath: String {
        guard let key = Bundle.main.infoDictionary?["ANALYSIS_HAPPINESS_PATH"] as? String else { fatalError("ANALYSIS_HAPPINESS_PATH error") }
        return key
    }
    
    var findMonthHappinessPath: String {
        guard let key = Bundle.main.infoDictionary?["FIND_MONTH_HAPPINESS_PATH"] as? String else { fatalError("FIND_MONTH_HAPPINESS_PATH error") }
        return key
    }
    
    var findYearHappinessPath: String {
        guard let key = Bundle.main.infoDictionary?["FIND_YEAR_HAPPINESS_PATH"] as? String else { fatalError("FIND_YEAR_HAPPINESS_PATH error") }
        return key
    }
    
    var updatePublicStatusPath: String {
        guard let key = Bundle.main.infoDictionary?["UPDATE_PUBLIC_STATUS_PATH"] as? String else { fatalError("UPDATE_PUBLIC_STATUS_PATH error") }
        return key
    }
    
    var updateLikePath: String {
        guard let key = Bundle.main.infoDictionary?["UPDATE_LIKE_PATH"] as? String else { fatalError("UPDATE_LIKE_PATH error") }
        return key
    }
    
    var findFeedImage: String {
        guard let key = Bundle.main.infoDictionary?["FIND_FEED_IMAGE"] as? String else { fatalError("FIND_FEED_IMAGE error") }
        return key
    }
    
    var findFeedUiimage: String {
        guard let key = Bundle.main.infoDictionary?["FIND_FEED_UIIMAGE"] as? String else { fatalError("FIND_FEED_UIIMAGE error") }
        return key
    }
    
    // MARK: - Server - Notice
    var connectNoticePath: String {
        guard let key = Bundle.main.infoDictionary?["CONNECT_NOTICE_PATH"] as? String else { fatalError("CONNECT_NOTICE_PATH error") }
        return key
    }
    
    // MARK: - App Service
    var tosPath: String {
        guard let key = Bundle.main.infoDictionary?["TOS_PATH"] as? String else { fatalError("TOS_PATH error") }
        return key
    }
    
    var privatePolicyPath: String {
        guard let key = Bundle.main.infoDictionary?["PRIVATE_POLICY_PATH"] as? String else { fatalError("PRIVATE_POLICY_PATH error") }
        return key
    }
    
    // MARK: - Inquiry Text
    var inquiryMessage: String {
        guard let key = Bundle.main.infoDictionary?["INQUIRY_MESSAGE"] as? String else { fatalError("INQUIRY_MESSAGE error") }

        return key.replacingOccurrences(of: "\\n", with: "\n")
    }
    
    var appleID: String {
        guard let key = Bundle.main.infoDictionary?["APPLEID"] as? String else { fatalError("APPLEID error") }
        return key
    }
}
