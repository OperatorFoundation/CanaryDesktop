//
//  ConnectionTest.swift
//  Canary
//
//  Created by Mafalda on 3/19/19.
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

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class ConnectionTest
{
    var testWebAddress: String
    var canaryString: String?
    
    init(testWebAddress: String, canaryString: String?)
    {
        self.testWebAddress = testWebAddress
        self.canaryString = canaryString
    }
    
    func run() -> Bool
    {
        uiLog.info("\n📣 Running connection test.")
        //globalRunningLog.updateLog("\n📣 Running connection test.")
        
        if let url = URL(string: testWebAddress)
        {
            var taskResponse: HTTPURLResponse?
            var taskData: Data?
            var taskError: Error?
            
            let queue = OperationQueue()
            let op = BlockOperation(block:
            {
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                
                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                sessionConfig.urlCache = nil
                let session = URLSession(configuration: sessionConfig)
                let testTask = session.dataTask(with: url)
                {
                    (maybeData, maybeResponse, maybeError) in
                    
                    taskResponse = maybeResponse as? HTTPURLResponse
                    taskData = maybeData
                    taskError = maybeError
                    
                    dispatchGroup.leave()
                }
                
                testTask.resume()
                dispatchGroup.wait()
            })

            queue.addOperations([op], waitUntilFinished: true)
            
            guard let response = taskResponse
                else
            {
                print("🚫 We did not receive a response 🚫")
                    return false
            }
            
            guard response.statusCode == 200
                else
            {
                print("🚫 We received a response \(response) with status code \(response.statusCode) 🚫")
                    return false
            }
            
            uiLog.info("\n💕 received status code 200 💕")
            
            //Control Data
            if canaryString != nil
            {
                let controlData = canaryString!.data(using: String.Encoding.utf8)
                
                if let observedData = taskData
                {
                    if observedData == controlData
                    {
                        uiLog.info("\n💕 🐥 It works! 🐥 💕")
                        return true
                    }
                    else
                    {
                        uiLog.info("\n🖤  We connected but the data did not match. 🖤\n")
                        
                        if let observedString = String(data: observedData, encoding: String.Encoding.ascii)
                        {
                            uiLog.info("Here's what we got back instead: \(observedString)\n")
                        }
                        
                        return false
                    }
                }
            }
            
            
            if let error = taskError
            {
                print("\nReceived an error while trying to connect to our test web address: \(error)")
            }
            
            return true
        }
        else
        {
            print("\nCould not resolve string to url: \(testWebAddress)")
            return false
        }
    }
}
