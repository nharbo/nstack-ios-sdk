//
//  NStackTests.swift
//  NStackTests
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//


import XCTest
import Serpent
import Alamofire
@testable import NStackSDK

let testConfiguration: () -> Configuration = {
    var conf = Configuration(plistName: "NStack", translationsClass: Translations.self)
    conf.verboseMode = true
    conf.updateOptions = []
    conf.versionOverride = "2.0"
    return conf
}

class NStackTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Configuration
    func testConfigured() {
        NStack.start(configuration: testConfiguration(), launchOptions: nil)
        XCTAssertTrue(NStack.sharedInstance.configured, "NStack should be configured after calling start.")
    }
    
    // MARK: - Geography
    
    func testIPAddress() {
        let exp = expectation(description: "IP-address returned")
        NStack.sharedInstance.ipDetails { (ipAddress, _) in
            if let _ = ipAddress {
                exp.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }
    func testUpdateCountriesList() {
        let exp = expectation(description: "Cached list of contries updated")
        NStack.sharedInstance.updateCountries { (countries, error) in
            if let cachedCountries = NStack.sharedInstance.countries, !cachedCountries.isEmpty, !countries.isEmpty {
                exp.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }
    
    // MARK: - Validation
    func testValidEmail() {
        let exp = expectation(description: "Valid email")
        NStack.sharedInstance.validateEmail("chgr@nodes.dk") { (valid, error) in
            if valid {
                exp.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }
    
    func testInvalidEmail() {
        let exp = expectation(description: "Invalid email")
        NStack.sharedInstance.validateEmail("veryWrongEmail") { (valid, error) in
            if !valid {
                exp.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }
    
    // MARK: - Content
    
    func testContentResponse() {
        let exp = expectation(description: "Content recieved")
        NStack.sharedInstance.getContentResponseForId(60) { (response, error) in
            //parse content
            guard let dictionary = response as? NSDictionary,
                let data = dictionary.object(forKey: "data") as? NSDictionary,
                let name = data.object(forKey: "name") as? String,
                name == "Africa" else {
                XCTFail()
                return
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
    
//    func testContentInvalidId() {
//        let exp = expectation(description: "Invalid id")
//        NStack.sharedInstance.getContentResponseForId(6029035) { (response, error) in
//            //parse content
//            if error == nil {
//                XCTFail()
//            } else {
//                exp.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 5.0)
//    }
    
    func testContentValueResponse() {
        let exp = expectation(description: "Content recieved")
        NStack.sharedInstance.getValueForId(60, andKey: "name") { (response, error) in
            
            if let name = response as? String, name == "Africa" {
                exp.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5.0)
    }
}
