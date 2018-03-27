//
//  ConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Cashier

// FIXME: Figure out how to do accept language header properly

final class ConnectionManager {
    let baseURL = "https://nstack.io/api/v1/"

    let configuration: APIConfiguration
    
    //URL Session
    private var session: URLSession
    private var component: URLComponents?

    var defaultHeaders: [String : String] {
        return [
            "X-Application-id"  : configuration.appId,
            "X-Rest-Api-Key"    : configuration.restAPIKey,
        ]
    }

    init(configuration: APIConfiguration) {
        self.configuration = configuration
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "X-Application-id"  : configuration.appId,
            "X-Rest-Api-Key"    : configuration.restAPIKey,
        ]
        config.timeoutIntervalForRequest = 20
        session = URLSession(configuration: config)
        component = URLComponents(string: baseURL)
    }
}

extension ConnectionManager: AppOpenRepository {
    func postAppOpen(oldVersion: String = VersionUtilities.previousAppVersion,
                     currentVersion: String = VersionUtilities.currentAppVersion,
                     acceptLanguage: String? = nil, completion: @escaping Completion<[String: Any]>) {
        var params: [String : Any] = [
            "version"           : currentVersion,
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "last_updated"      : ConnectionManager.lastUpdatedString,   
            "old_version"       : oldVersion
        ]

        if let overriddenVersion = VersionUtilities.versionOverride {
            params["version"] = overriddenVersion
        }

        var headers = defaultHeaders
        if let acceptLanguage = acceptLanguage {
            headers["Accept-Language"] = acceptLanguage
        }

        guard let component = component,
            let url = component.url?.appendingPathComponent("open" + (configuration.isFlat ? "?flat=true" : ""))
            else {
                print("failed in bulding appOpen url")
                return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let dataTask = session.dataTask(with: urlRequest, completionHandler: session.decode(completion))
        dataTask.resume()

    }
}

extension ConnectionManager: TranslationsRepository {
    func fetchTranslations(acceptLanguage: String,
                           completion: @escaping Completion<TranslationsResponse>) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "last_updated"      : ConnectionManager.lastUpdatedString
        ]

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        guard let component = component,
            let url = component.url?.appendingPathComponent("translate/mobile/keys?all=true" + (configuration.isFlat ? "&flat=true" : ""))
            else {
                print("failed in bulding fetchTranslations url")
                return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let dataTask = session.dataTask(with: urlRequest, completionHandler: session.decode(completion))
        dataTask.resume()
    }

    func fetchCurrentLanguage(acceptLanguage: String,
                              completion:  @escaping Completion<Language>) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "last_updated"      : ConnectionManager.lastUpdatedString
        ]

        var headers = defaultHeaders
        headers["Accept-Language"] = acceptLanguage

        guard let component = component,
            let url = component.url?.appendingPathComponent("translate/mobile/languages/best_fit?show_inactive_languages=true")
            else {
                print("failed in bulding fetchCurrentLanguage url")
                return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let dataTask = session.dataTask(with: urlRequest, completionHandler: session.decode(completion))
        dataTask.resume()
    }

    func fetchAvailableLanguages(completion:  @escaping Completion<[Language]>) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
        ]
        
        guard let component = component,
            let url = component.url?.appendingPathComponent("translate/mobile/languages")
            else {
                print("failed in bulding fetchCurrentLanguage url")
                return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = defaultHeaders
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let dataTask = session.dataTask(with: urlRequest, completionHandler: session.decode(completion))
        dataTask.resume()
    }

    func fetchPreferredLanguages() -> [String] {
        return Locale.preferredLanguages
    }

    func fetchBundles() -> [Bundle] {
        return Bundle.allBundles
    }
}

extension ConnectionManager: UpdatesRepository {
    func fetchUpdates(oldVersion: String = VersionUtilities.previousAppVersion,
                      currentVersion: String = VersionUtilities.currentAppVersion,
                      completion: @escaping Completion<Update>) {
        let params: [String : Any] = [
            "current_version"   : currentVersion,
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "old_version"       : oldVersion,
            ]

        guard let component = component,
            let url = component.url?.appendingPathComponent("notify/updates")
            else {
                print("failed in bulding fetchUpdates url")
                return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = defaultHeaders
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let dataTask = session.dataTask(with: urlRequest, completionHandler: session.decode(completion))
        dataTask.resume()
    }
}

extension ConnectionManager: VersionsRepository {
    func markWhatsNewAsSeen(_ id: Int) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "update_id"         : id,
            "type"              : "new_in_version",
            "answer"            : "no",
        ]

        guard let component = component,
            let url = component.url?.appendingPathComponent("notify/updates/views")
            else {
                print("failed in bulding markWhatsNewAsSeen url")
                return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = defaultHeaders
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let dataTask = session.dataTask(with: urlRequest)
        dataTask.resume()
    }

    func markMessageAsRead(_ id: String) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "message_id"        : id
        ]
        
        guard let component = component,
            let url = component.url?.appendingPathComponent("notify/messages/views")
            else {
                print("failed in bulding markMessageAsRead url")
                return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = defaultHeaders
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let dataTask = session.dataTask(with: urlRequest)
        dataTask.resume()
    }

    #if os(iOS) || os(tvOS)
    func markRateReminderAsSeen(_ answer: AlertManager.RateReminderResult) {
        let params: [String : Any] = [
            "guid"              : Configuration.guid,
            "platform"          : "ios",
            "answer"            : answer.rawValue
        ]

    
        guard let component = component,
            let url = component.url?.appendingPathComponent("notify/rate_reminder/views")
        else {
            print("failed in bulding markRateReminderAsSeen url")
            return
        }
    
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = defaultHeaders
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    
        let dataTask = session.dataTask(with: urlRequest, completionHandler: session.decode(completion))
        dataTask.resume()
    }
    #endif
}

// MARK: - Geography -

extension ConnectionManager: GeographyRepository {
    func fetchContinents(completion: @escaping Completion<[Continent]>) {
        guard let component = component, let url = component.url?.appendingPathComponent("geographic/continents") else { return }
        
        let dataTask = session.dataTask(with: url, completionHandler: session.decode(completion))
        dataTask.resume()
    }
    
    func fetchLanguages(completion: @escaping Completion<[Language]>) {
        guard let component = component, let url = component.url?.appendingPathComponent("geographic/languages") else { return }
        
        let dataTask = session.dataTask(with: url, completionHandler: session.decode(completion))
        dataTask.resume()
    }
    
    func fetchTimeZones(completion: @escaping Completion<[Timezone]>) {
        guard let component = component, let url = component.url?.appendingPathComponent("geographic/time_zones") else { return }
        
        let dataTask = session.dataTask(with: url, completionHandler: session.decode(completion))
        dataTask.resume()
    }
    
    func fetchTimeZone(lat: Double, lng: Double, completion: @escaping Completion<Timezone>) {
        guard let component = component, let url = component.url?.appendingPathComponent("geographic/time_zones/by_lat_lng?lat_lng=\(String(lat)),\(String(lng))")
            else { return }
        
        let dataTask = session.dataTask(with: url, completionHandler: session.decode(completion))
        dataTask.resume()
    }
    
    func fetchIPDetails(completion: @escaping Completion<IPAddress>) {
        guard let component = component, let url = component.url?.appendingPathComponent("geographic/ip-address") else { return }
        
        let dataTask = session.dataTask(with: url, completionHandler: session.decode(completion))
        dataTask.resume()
    }
    
    func fetchCountries(completion:  @escaping Completion<[Country]>) {
        guard let component = component, let url = component.url?.appendingPathComponent("geographic/countries") else { return }
        
        let dataTask = session.dataTask(with: url, completionHandler: session.decode(completion))
        dataTask.resume()
    }
}

// MARK: - Validation -

extension ConnectionManager: ValidationRepository {
    func validateEmail(_ email: String, completion:  @escaping Completion<Validation>) {
        guard let component = component, let url = component.url?.appendingPathComponent("validator/email?email=\(email)") else { return }
        
        let dataTask = session.dataTask(with: url, completionHandler: session.decode(completion))
        dataTask.resume()
    }
}

// MARK: - Content -

extension ConnectionManager: ContentRepository {
    func fetchContent(_ id: Int, completion: @escaping Completion<[String: Any]>) {
        guard let component = component, let url = component.url?.appendingPathComponent("content/responses/\(id)") else { return }
        
        let dataTask = session.dataTask(with: url, completionHandler: session.decode(completion))
        dataTask.resume()
    }
    
    func fetchContent(_ slug: String, completion: @escaping Completion<[String: Any]>) {
        guard let component = component, let url = component.url?.appendingPathComponent("content/responses/\(slug)") else { return }
        
        let dataTask = session.dataTask(with: url, completionHandler: session.decode(completion))
        dataTask.resume()
    }
}

// MARK: - Utility Functions -

// FIXME: Refactor

extension ConnectionManager {

    static var lastUpdatedString: String {
        let cache = Constants.persistentStore

        // FIXME: Handle language change
//        let previousAcceptLanguage = cache.string(forKey: Constants.CacheKeys.prevAcceptedLanguage)
//        let currentAcceptLanguage  = TranslationManager.acceptLanguage()
//
//        if let previous = previousAcceptLanguage, previous != currentAcceptLanguage {
//            cache.setObject(currentAcceptLanguage, forKey: Constants.CacheKeys.prevAcceptedLanguage)
//            setLastUpdated(Date.distantPast)
//        }

        let key = Constants.CacheKeys.lastUpdatedDate
        let date = cache.object(forKey: key) as? Date ?? Date.distantPast
        return date.stringRepresentation()
    }

    func setLastUpdated(toDate date: Date = Date()) {
        Constants.persistentStore.setObject(date, forKey: Constants.CacheKeys.lastUpdatedDate)
    }
}
