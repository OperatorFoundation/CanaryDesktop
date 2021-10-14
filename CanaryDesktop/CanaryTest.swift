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

import ArgumentParser
import Foundation

import Gardener
import NetUtils
import Darwin
import Transmission

struct CanaryTest//: ParsableCommand
{
    var canaryTestQueue = DispatchQueue(label: "CanaryTests")
    
    //@Argument(help: "IP address for the transport server.")
    var serverIP: String
    
    //@Argument(help: "Optionally set the path to the directory where Canary's required resources can be found. It is recommended that you only use this if the default directory does not work for you.")
    var resourceDirPath: String?
    
    //@Option(name: NameSpecification.shortAndLong, parsing: SingleValueParsingStrategy.next, help:"Set how many times you would like Canary to run its tests.")
    var testCount: Int = 1
    
    //@Option(name: NameSpecification.shortAndLong, parsing: SingleValueParsingStrategy.next, help: "Optionally specify the interface name.")
    var interface: String?
    
    
//    func validate() throws
//    {
//        guard numberOfTimesToRun >= 1 && numberOfTimesToRun <= 15
//        else
//        {
//            throw ValidationError("'<runs>' must be at least 1 and no more than 15.")
//        }
//    }
    
    /// launch AdversaryLabClient to capture our test traffic, and run a connection test.
    ///  a csv file and song data (zipped) are saved with the test results.
    func runTest()
    {
        uiLog.info("\n Attmpting to run tests...\n")
        globalRunningLog.updateState(runningTests: true)
        
        if let rPath = resourceDirPath
        {
            resourcesDirectoryPath = rPath
            uiLog.info("\nUser selected resources directory: \(resourcesDirectoryPath)\n")
            print("\nUser selected resources directory: \(resourcesDirectoryPath)")
        }
        else
        {
            resourcesDirectoryPath = "\(FileManager.default.currentDirectoryPath)/Sources/Resources"
            
            uiLog.info("\nYou did not indicate a preferred resources directory, using the default directory: \(resourcesDirectoryPath)\n")
            print("\nYou did not indicate a preferred resources directory, using the default directory: \(resourcesDirectoryPath)")
        }
        
        // Make sure we have everything we need first
        guard checkSetup() else { return }
        
        
        var interfaceName: String
        
        if interface != nil
        {
            // Use the user provided interface name
            interfaceName = interface!
        }
        else
        {
            // Try to guess the interface, if we cannot then give up
            guard let name = guessUserInterface()
            else { return }
            
            interfaceName = name
        }
        
        uiLog.info("Selected an interface for running test: \(interfaceName)\n")
        
        canaryTestQueue.async {
            for i in 1...testCount
            {
                uiLog.info("\n***************************\nRunning test batch \(i) of \(testCount)\n***************************\n")
                print("\n***************************\nRunning test batch \(i) of \(testCount)\n***************************")
                
                for transport in allTransports
                {
                    uiLog.log(level: .info, "\n 🧪 Starting test for \(transport.name) 🧪")
                    //print("\n 🧪 Starting test for \(transport.name) 🧪\n")
                    TestController.sharedInstance.test(name: transport.name, serverIPString: serverIP, port: transport.port, interface: interfaceName, webAddress: nil)
                }
                
                for webTest in allWebTests
                {
                    uiLog.info("\n 🧪 Starting web test for \(webTest.website) 🧪")
                    TestController.sharedInstance.test(name: webTest.name, serverIPString: serverIP, port: webTest.port, interface: interfaceName, webAddress: webTest.website)
                }
                
                // This directory contains our test results.
                zipResults()
            }
        }
        
        
        //ShapeshifterController.sharedInstance.killAllShShifter()
        uiLog.info("\nCanary tests are complete.\n")
        globalRunningLog.updateState(runningTests: false)
    }
    
    func guessUserInterface() -> String?
    {
        var allInterfaces = Interface.allInterfaces()
        
        // Get interfaces sorted by name
        allInterfaces.sort(by: {
            (interfaceA, interfaceB) -> Bool in
            
            return interfaceA.name < interfaceB.name
        })
        
        print("\nUser did not indicate a preferred interface. Printing all available interfaces.")
        for interface in allInterfaces { print("\(interface.name)")}
        
        // Return the first interface that begins with the letter e
        // Note: this is just a best guess based on what we understand to be a common scenario
        // The user should use the interface flag if they have something different
        guard let bestGuess = allInterfaces.firstIndex(where: { $0.name.hasPrefix("e") })
        else
        {
            print("\nWe were unable to identify a likely interface name. Please try running the program again using the interface flag and one of the other listed interfaces.\n")
            return nil
        }
        
        print("\nWe will try using the \(allInterfaces[bestGuess].name) interface. If Canary fails to capture data, it may be because this is not the correct interface. Please try running the program again using the interface flag and one of the other listed interfaces.\n")
        
        return allInterfaces[bestGuess].name
    }
    
    func checkSetup() -> Bool
    {
        // Does the Resources Directory Exist
        guard FileManager.default.fileExists(atPath: resourcesDirectoryPath)
        else
        {
            uiLog.info("\nResource directory does not exist at \(resourcesDirectoryPath).\n")
            print("Resource directory does not exist at \(resourcesDirectoryPath).")
            return false
        }
        
        // Does it contain the files we need
        // One config for every transport being tested
        for transport in allTransports
        {
            switch transport
            {
            case shadowsocks:
                guard FileManager.default.fileExists(atPath:"\(resourcesDirectoryPath)/\(shSocksFilePath)")
                else
                {
                    uiLog.info("Shadowsocks config not found at \(resourcesDirectoryPath)/\(shSocksFilePath)")
                    return false
                }
            case replicant:
                guard FileManager.default.fileExists(atPath:"\(resourcesDirectoryPath)/\(replicantFilePath)")
                else
                {
                    uiLog.info("Replicant config not found at \(resourcesDirectoryPath)/\(replicantFilePath)")
                    print("Replicant config not found at \(resourcesDirectoryPath)/\(replicantFilePath)")
                    return false
                }
            default:
                uiLog.info("\nTried to test a transport that has no config file. Transport name: \(transport.name)\n")
                print("Tried to test a transport that has no config file. Transport name: \(transport.name)")
                return false
            }
        }
        
        // Is the transport server running
        if !allTransports.isEmpty
        {            
            guard let _ = Transmission.Connection(host: serverIP, port: Int(string: allTransports[0].port), type: .tcp)
            else
            {
                uiLog.info("\nFailed to connect to the transport server.\n")
                return false
            }
        }
        
        return true
    }
}


