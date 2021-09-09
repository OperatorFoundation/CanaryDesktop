//
//  BatchTestController.swift
//  transport-canary
//
//  Created by Adelita Schule on 6/23/17.
//  MIT License
//
//  Copyright (c) 2020 Operator Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Logging

import Chord

class TestController
{
    static let sharedInstance = TestController()
    
    let log = Logger(label: "TransportLogger")
    
    init()
    {
        LoggingSystem.bootstrap(StreamLogHandler.standardError)
    }
    
    func runSwiftTransportTest(serverIP: String, forTransport transport: Transport) -> TestResult?
    {
        var result: TestResult?
        let transportController = TransportController(transport: transport, serverIP: serverIP, log: log)
        
        guard let connection = Synchronizer.sync(transportController.startTransport)
        else { return nil }
        
        globalRunningLog.logString += "\n🧩 Launched \(transport). 🧩"
                
        ///Connection Test
        let connectionTest = TransportConnectionTest(transportConnection: connection, canaryString: canaryString)
        let success = connectionTest.run()
        
        result = TestResult(serverIP: serverIP, testDate: Date(), name: transport.name, success: success)
        
        // Save this result to a file
        let _ = save(result: result!, testName: transport.name)
        
//        ///Cleanup
//        globalRunningLog.logString += "\n🛁  🛁  🛁  🛁  Cleaning up after test! 🛁  🛁  🛁  🛁"
//        ShapeshifterController.sharedInstance.stopShapeshifterClient()
        
        sleep(2)
        return result
    }
    
    /// Launches shapeshifter dispatcher with the transport, runs a connection test, and then saves the results to a csv file.
    ///
    /// - Parameters:
    ///   - serverIP: A string value indicating the IPV4 address of the transport server.
    ///   - transport: The information needed to indicate which transport we are testing.
    /// - Returns: A TestResult value that indicates whether or not the connection test was successful. This is the same test result information that is also saved to a timestamped csv file.
    func runTransportTest(serverIP: String, forTransport transport: Transport) -> TestResult?
    {
        var result: TestResult?

//        ///Shapeshifter
//        guard ShapeshifterController.sharedInstance.launchShapeshifterClient(serverIP: serverIP, transport: transport) == true
//        else
//        {
//            globalRunningLog.logString += "\n❗️ Failed to launch Shapeshifter Client for \(transport) with serverIP: \(serverIP)"
//            return nil
//        }
        
        globalRunningLog.logString += "\n🧩 Launched shapeshifter-dispatcher for \(transport). 🧩"
                
        ///Connection Test
        let testWebAddress = "http://127.0.0.1:1234/"
        let canaryString = "Yeah!\n"
        let connectionTest = ConnectionTest(testWebAddress: testWebAddress, canaryString: canaryString)
        let success = connectionTest.run()
        
        result = TestResult(serverIP: serverIP, testDate: Date(), name: transport.name, success: success)
        
        // Save this result to a file
        let _ = save(result: result!, testName: transport.name)
        
//        ///Cleanup
//        globalRunningLog.logString += "🛁  🛁  🛁  🛁  Cleaning up after test! 🛁  🛁  🛁  🛁\n"
//        ShapeshifterController.sharedInstance.stopShapeshifterClient()
        
        sleep(2)
        return result
    }
    
    /// Tests ability to connect to a given web address without the use of transports
    func runWebTest(serverIP: String, port: String, name: String, webAddress: String) -> TestResult?
    {
        var result: TestResult?
        
        ///Connection Test
        let connectionTest = ConnectionTest(testWebAddress: webAddress, canaryString: nil)
        let success = connectionTest.run()
        
        result = TestResult(serverIP: serverIP, testDate: Date(), name: name, success: success)
        
        // Save this result to a file
        let _ = save(result: result!, testName: webAddress)
        
//        ///Cleanup
//        globalRunningLog.logString += "🛁  🛁  🛁  🛁  Cleaning up after web test! 🛁  🛁  🛁  🛁\n"
//        ShapeshifterController.sharedInstance.stopShapeshifterClient()
        
        sleep(2)
        return result
    }
    
    /// Saves the provided test results to a csv file with a filename that contains a timestamp.
    /// If a file with this name already exists it will append the results to the end of the file.
    ///
    /// - Parameter result: The test result information to be saved. The type is a TestResult struct.
    /// - Returns: A boolean value indicating whether or not the results were saved successfully.
    func save(result: TestResult, testName: String) -> Bool
    {
        let resultString = "\(result.testDate), \(result.serverIP), \(testName), \(result.success)\n"
        
        guard let resultData = resultString.data(using: .utf8)
            else { return false }
        
        let currentDirectoryPath = FileManager.default.currentDirectoryPath
        let outputDirectoryPath = "\(currentDirectoryPath)/\(outputDirectoryName)"
        let resultFilePath = "/\(outputDirectoryPath)/\(resultsFileName)\(getNowAsString()).\(resultsExtension)"
        
        if FileManager.default.fileExists(atPath: resultFilePath)
        {
            // We already have a file at this address let's add out results to the end of it.
            guard let fileHandler = FileHandle(forWritingAtPath: resultFilePath)
                else
            {
                globalRunningLog.logString += "\n🛑  Error creating a file handler to write to \(resultFilePath)\n"
                return false
            }
            
            fileHandler.seekToEndOfFile()
            fileHandler.write(resultData)
            fileHandler.closeFile()
            
            globalRunningLog.logString += "\nSaved test results to file: \(resultFilePath)"
            return true
        }
        else
        {
            // Make a new csv file for our test results
            // The first row should be our labels
            let labelRow = "TestDate, ServerIP, Transport, Success\n"
            guard let labelData = labelRow.data(using: .utf8)
                else { return false }
            
            // Append our results to the label row
            let newFileData = labelData + resultData
            
            // Make sure our output directory exists
            if !FileManager.default.fileExists(atPath: outputDirectoryPath)
            {
                do
                {
                    try FileManager.default.createDirectory(at: URL(fileURLWithPath: outputDirectoryPath, isDirectory: true), withIntermediateDirectories: true, attributes: nil)
                }
                catch
                {
                    globalRunningLog.logString += "\n🛑  Error creating output directory at \(outputDirectoryPath): \(error)\n"
                    return false
                }
            }
            
            // Save the new file
            let saved = FileManager.default.createFile(atPath: resultFilePath, contents: newFileData, attributes: nil)
            print("Test results saved? \(saved.description)")
            //print("File path: \(resultFilePath)")
            
            return saved
        }
    }
    
    func test(name: String, serverIPString: String, port: String, interface: String?, webAddress: String?)
    {
        AdversaryLabController.sharedInstance.launchAdversaryLab(transportName: name, port: port, interface: interface)
        
        if webAddress == nil
        {
            if let transportTestResult = self.runSwiftTransportTest(serverIP: serverIPString, forTransport: Transport(name: name, port: port))
            {
                sleep(5)
                AdversaryLabController.sharedInstance.stopAdversaryLab(testResult: transportTestResult)
            }
            else
            {
                globalRunningLog.logString += "\n🛑  Received a nil result when testing \(name) transport.\n"
                sleep(5)
                AdversaryLabController.sharedInstance.stopAdversaryLab(testResult: nil)
            }
        }
        else
        {
            if let webTestResult = self.runWebTest(serverIP: serverIPString, port: port, name: name, webAddress: webAddress!)
            {
                //print("Test result for \(transport.name):\n\(webTestResult)\n")
                sleep(5)
                AdversaryLabController.sharedInstance.stopAdversaryLab(testResult: webTestResult)
                //dispatchGroup.leave()
            }
            else
            {
                globalRunningLog.logString += "\n🛑  Received a nil result when testing \(name) web address."
                sleep(5)
                AdversaryLabController.sharedInstance.stopAdversaryLab(testResult: nil)
                //dispatchGroup.leave()
            }
        }
        
        sleep(1)
    }
    
    func getNowAsString() -> String
    {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withFullDate, .withColonSeparatorInTime]
        var dateString = formatter.string(from: Date())
        dateString = dateString.replacingOccurrences(of: "-", with: "_")
        dateString = dateString.replacingOccurrences(of: ":", with: "_")
        
        return dateString
    }
    
}
