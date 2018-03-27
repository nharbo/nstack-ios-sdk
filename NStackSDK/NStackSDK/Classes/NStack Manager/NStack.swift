//
//  NStack.swift
//  NStack
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Cashier

public class NStack {

    /// The singleton object which should be used to interact with NStack API.
    public static let sharedInstance = NStack()

    /// The configuration object the shared instance have been initialized with.
    public fileprivate(set) var configuration: Configuration!

    /// The manager responsible for fetching, updating and persisting translations.
    public fileprivate(set) var translationsManager: TranslationManager?

    #if os(iOS) || os(tvOS)
    /// The manager responsible for handling and showing version alerts and messages.
    public fileprivate(set) var alertManager: AlertManager!
    #endif

    /// This gets called when the phone language has changed while app is running.
    /// At this point, translations have been updated, if there was an internet connection.
    public var languageChangedHandler: (() -> Void)?

    /// Description
    public var logLevel: LogLevel = .error {
        didSet {
            logger.logLevel = logLevel
            translationsManager?.logger.logLevel = logLevel
        }
    }

    #if os(macOS) || os(watchOS)
    public typealias LaunchOptionsKeyType = String
    internal var avoidUpdateList: [LaunchOptionsKeyType] = []
    #else
    public typealias LaunchOptionsKeyType = UIApplicationLaunchOptionsKey
    internal var avoidUpdateList: [LaunchOptionsKeyType] = [.location]
    #endif

    internal var connectionManager: ConnectionManager!
    internal fileprivate(set) var configured = false
    internal var observer: ApplicationObserver?
    internal var logger: LoggerType = ConsoleLogger()

    // MARK: - Start NStack -

    fileprivate init() {}

    /// Initializes NStack and, if `updateAutomaticallyOnStart` is set on the passed `Configuration`
    /// object, fetches all data (including translations if enabled) from NStack API right away.
    ///
    /// - Parameters:
    ///   - configuration: A `Configuration` struct containing API keys and translations type.
    ///   - launchOptions: Launch options passed from `applicationDidFinishLaunching:` function.
    public class func start(configuration: Configuration,
                            launchOptions: [LaunchOptionsKeyType: Any]?) {
        sharedInstance.start(configuration: configuration, launchOptions: launchOptions)
    }

    fileprivate func start(configuration: Configuration,
                           launchOptions: [LaunchOptionsKeyType: Any]?) {
        guard !configured else {
            logger.log("NStack is already configured. Kill the app and start it again with new configuration.",
                level: .error)
            return
        }

        self.configuration = configuration
        self.configured = true

        // For testing purposes
        VersionUtilities.versionOverride = configuration.versionOverride

        // Setup the connection manager
        let apiConfiguration = APIConfiguration(appId: configuration.appId,
                                                restAPIKey: configuration.restAPIKey,
                                                isFlat: configuration.flat)
        connectionManager = ConnectionManager(configuration: apiConfiguration)

        // Observe if necessary
        if configuration.updateOptions.contains(.onDidBecomeActive) {
            observer = ApplicationObserver(handler: { (action) in
                guard action == .didBecomeActive else { return }

                self.update { error in
                    if let error = error {
                        self.logger.logError("Error updating NStack on did become active: " +
                            error.localizedDescription)
                        return
                    }
                }
            })
        }

        // Setup translations
        if let translationsClass = configuration.translationsClass {
            translationsManager = TranslationManager(translationsType: translationsClass,
                                                     repository: connectionManager,
                                                     logger: ConsoleLogger())

            // Delete translations if new version
            if VersionUtilities.isVersion(VersionUtilities.currentAppVersion,
                                          greaterThanVersion: VersionUtilities.previousAppVersion) {
                translationsManager?.clearTranslations(includingPersisted: true)
            }

            // Set callback 
            translationsManager?.languageChangedAction = {
                self.languageChangedHandler?()
            }
        }

        #if os(iOS) || os(tvOS)
        // Setup alert manager
        alertManager = AlertManager(repository: connectionManager)
        #endif

        // Update if necessary and launch options doesn't contain a key present in avoid update list
        if configuration.updateOptions.contains(.onStart) &&
            launchOptions?.keys.contains(where: { self.avoidUpdateList.contains($0) }) != true &&
            !configuration.updateOptions.contains(.never) {
            update()
        }
    }

    /// Fetches the latest data from the NStack server and updates accordingly.
    ///
    /// - Shows appropriate notifications to the user (Update notifications, what's new, messages, rate reminders).
    /// - Updates the translation strings for current language.
    ///
    /// *Note:* By default, this is automatically invoked after *NStack.start()* has been called and subsequently on applicationDidBecomeActive.
    /// To override this behavior, see the properties on the *configuration* struct.
    ///
    /// - Parameter completion: This is run after the call has finished. 
    ///                         If *error* was nil, translation strings are up-to-date.
    public func update(_ completion: ((_ error: NStackError.Manager?) -> Void)? = nil) {
        guard configured else {
            print(NStackError.Manager.notConfigured.description)
            completion?(.notConfigured)
            return
        }

        // FIXME: Refactor

        connectionManager.postAppOpen(completion: { response in
            switch response {
            case .success(let dictionary):
                let wrapper = AppOpenResponse(dictionary: dictionary)


                defer {
                    completion?(nil)
                }

                guard let appOpenResponseData = wrapper.data else { return }

                // Update translations
//                if let translations = appOpenResponseData.translate, translations.count > 0 {
//                    self.translationsManager?.set(translationsDictionary: translations)
//                }

                #if os(iOS) || os(tvOS)

                if !self.alertManager.alreadyShowingAlert {

                    if let newVersion = appOpenResponseData.update?.newerVersion {
                        self.alertManager.showUpdateAlert(newVersion: newVersion)
                    } else if let changelog = appOpenResponseData.update?.newInThisVersion {
                        self.alertManager.showWhatsNewAlert(changelog)
                    } else if let message = appOpenResponseData.message {
                        self.alertManager.showMessage(message)
                    } else if let rateReminder = appOpenResponseData.rateReminder {
                        self.alertManager.showRateReminder(rateReminder)
                    }

                    VersionUtilities.previousAppVersion = VersionUtilities.currentAppVersion
                }
                #endif

                self.connectionManager.setLastUpdated()

            case .successWithError(let dictionary, let error):
                //TODO: do this
                break
            case let .failure(error):
                self.logger.log("Failure: \(response)", level: .error)
                completion?(.updateFailed(reason: error.localizedDescription))
            }
        })

        // Update translations if needed
        translationsManager?.updateTranslations()
    }
}

// MARK: - Geography -

public extension NStack {
    
    // MARK: - IPAddress
    
    /// Retrieve details based on the requestee's ip address
    ///
    /// - Parameter completion: Completion block when the API call has finished.
    public func ipDetails(completion: @escaping ((_ ipDetails: IPAddress?, _ error: Error?) -> ())) {
        connectionManager.fetchIPDetails { (response) in
            switch response {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            case .successWithError(let data, let error):
                completion(data, error)
            }
        }
    }
    
    // MARK: - Countries
    
    /// Updates the list of countries stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func updateCountries(completion: ((_ countries: [Country], _ error: Error?) -> ())? = nil) {
        connectionManager.fetchCountries { (response) in
            switch response {
            case .success(let data):
                self.countries = data
                completion?(data, nil)
            case .failure(let error):
                completion?([], error)
            case .successWithError(let data, let error):
                completion?(data, error)
            }
        }
    }
    
    /// Locally stored list of countries
    public private(set) var countries: [Country]? {
        get {
            return Constants.persistentStore.object(forKey: Constants.CacheKeys.countries) as? [Country]
        }
        set {
            guard let newValue = newValue else {
                Constants.persistentStore.deleteObject(forKey: Constants.CacheKeys.countries)
                return
            }
            Constants.persistentStore.setObject(newValue, forKey: Constants.CacheKeys.countries)
        }
    }
    
    // MARK: - Continents
    
    /// Updates the list of continents stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func updateContinents(completion: ((_ continents: [Continent], _ error: Error?) -> ())? = nil) {
        connectionManager.fetchContinents { (response) in
            switch response {
            case .success(let data):
                self.continents = data
                completion?(data, nil)
            case .failure(let error):
                completion?([], error)
            case .successWithError(let data, let error):
                completion?(data, error)
            }
        }
    }
    
    /// Locally stored list of continents
    public private(set) var continents: [Continent]? {
        get {
            return Constants.persistentStore.object(forKey: Constants.CacheKeys.continents) as? [Continent]
        }
        set {
            guard let newValue = newValue else {
                Constants.persistentStore.deleteObject(forKey: Constants.CacheKeys.continents)
                return
            }
            Constants.persistentStore.setObject(newValue, forKey: Constants.CacheKeys.continents)
        }
    }
    
    // MARK: - Languages
    
    /// Updates the list of languages stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func updateLanguages(completion: ((_ countries: [Language], _ error: Error?) -> ())? = nil) {
        connectionManager.fetchLanguages { (response) in
            switch response {
            case .success(let data):
                self.languages = data
                completion?(data, nil)
            case .failure(let error):
                completion?([], error)
            case .successWithError(let data, let error):
                completion?(data, error)
            }
        }
    }
    
    /// Locally stored list of languages
    public private(set) var languages: [Language]? {
        get {
            return Constants.persistentStore.object(forKey: Constants.CacheKeys.languanges) as? [Language]
        }
        set {
            guard let newValue = newValue else {
                Constants.persistentStore.deleteObject(forKey: Constants.CacheKeys.languanges)
                return
            }
            Constants.persistentStore.setObject(newValue, forKey: Constants.CacheKeys.languanges)
        }
    }
    
    // MARK: - Timezones
    
    /// Updates the list of timezones stored by NStack.
    ///
    /// - Parameter completion: Optional completion block when the API call has finished.
    public func updateTimezones(completion: ((_ countries: [Timezone], _ error: Error?) -> ())? = nil) {
        connectionManager.fetchTimeZones { (response) in
            switch response {
            case .success(let data):
                self.timezones = data
                completion?(data, nil)
            case .failure(let error):
                completion?([], error)
            case .successWithError(let data, let error):
                completion?(data, error)
            }
        }
    }
    
    /// Locally stored list of timezones
    public private(set) var timezones: [Timezone]? {
        get {
            return Constants.persistentStore.object(forKey: Constants.CacheKeys.timezones) as? [Timezone]
        }
        set {
            guard let newValue = newValue else {
                Constants.persistentStore.deleteObject(forKey: Constants.CacheKeys.timezones)
                return
            }
            Constants.persistentStore.setObject(newValue, forKey: Constants.CacheKeys.timezones)
        }
    }
    
    /// Get timezone for latitude and longitude
    ///
    /// - Parameters
    ///     lat: A double representing the latitude
    ///     lgn: A double representing the longitude
    ///     completion: Completion block when the API call has finished.
    public func timezone(lat: Double, lng: Double, completion: @escaping ((_ timezone: Timezone?, _ error: Error?) -> ())) {
        connectionManager.fetchTimeZone(lat: lat, lng: lng) { (response) in
            switch response {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            case .successWithError(let data, let error):
                completion(data, error)
            }
        }
    }
}

// MARK: - Validation -

public extension NStack {
    
    /// Validate an email.
    ///
    /// - Parameters
    ///     email: A string to be validated as a email
    ///     completion: Completion block when the API call has finished.
    public func validateEmail(_ email:String, completion: @escaping ((_ valid: Bool, _ error: Error?) -> ())) {
        connectionManager.validateEmail(email) { (response) in
            switch response {
            case .success(let data):
                completion(data.ok, nil)
            case .failure(let error):
                completion(false,error)
            case .successWithError(let data, let error):
                completion(data.ok, error)
            }
        }
    }
}

// MARK: - Content -

public extension NStack {
    
    /// Get content response for id made on NStack web console
    ///
    /// - Parameters
    ///     id: The integer id of the required content response
    ///     unwrapper: Optional unwrapper where to look for the required data, default is in the data object
    ///     key: Optional string if only one property or object is required, default is nil
    ///     completion: Completion block with the response as a any object if successful or error if not
    public func getContentResponse(_ id: Int, key: String? = nil, completion: @escaping ((_ response: Any?, _ error: Error?) -> ())) {
        connectionManager.fetchContent(id) { (response) in
            self.handle(response, key: key, completion: completion)
        }
    }
    
    /// Get content response for slug made on NStack web console
    ///
    /// - Parameters
    ///     slug: The string slug of the required content response
    ///     unwrapper: Optional unwrapper where to look for the required data, default is in the data object
    ///     key: Optional string if only one property or object is required, default is nil
    ///     completion: Completion block with the response as a any object if successful or error if not
    public func getContentResponse(_ slug: String, key: String? = nil, completion: @escaping ((_ response: Any?, _ error: Error?) -> ())) {
        connectionManager.fetchContent(slug) { (response) in
            self.handle(response, key: key, completion: completion)
        }
    }
    
    private func handle(_ response: DResult<[String: Any]>, key: String? = nil, completion: @escaping ((_ response: Any?, _ error: Error?) -> ())) {
        switch response {
        case .success(let sourceDictionary):
            if let key = key {
                if let value = sourceDictionary[key] {
                    completion(value, nil)
                } else {
                    completion(nil, NStackError.Manager.parsing(reason: "No data found for specified key"))
                }
            } else {
                completion(sourceDictionary, nil)
            }
        case let .failure(error):
            completion(nil,error)
        case .successWithError(let sourceDictionary, let error):
            if let key = key {
                if let value = sourceDictionary[key] {
                    completion(value, error)
                } else {
                    completion(nil, NStackError.Manager.parsing(reason: "No data found for specified key"))
                }
            } else {
                completion(sourceDictionary, error)
            }
        }
    }
}

