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
    // Server - Common
    var baseURL: String {
        guard let key = Bundle.main.infoDictionary?["BASE_URL"] as? String else { fatalError("BASE_URL error") }
        return key
    }

    // Server - Auth
    var googleLoginPath: String {
        guard let key = Bundle.main.infoDictionary?["GOOGLE_LOGIN_PATH"] as? String else { fatalError("GOOGLE_LOGIN_PATH error") }
        return key
    }
    var kakaoLoginPath: String {
        guard let key = Bundle.main.infoDictionary?["KAKAO_LOGIN_PATH"] as? String else { fatalError("KAKAO_LOGIN_PATH error") }
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
    var fineProfileImgPath: String {
        guard let key = Bundle.main.infoDictionary?["FIND_PROFILE_IMG_PATH"] as? String else { fatalError("FIND_PROFILE_IMG_PATH error") }
        return key
    }
    
    // Server - Feed
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
}
