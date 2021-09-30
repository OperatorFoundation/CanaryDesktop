//
//  AdversaryLabController.swift
//  transport-canary
//
//  Created by Adelita Schule on 6/22/17.
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

import AdversaryLabClientCore
import Datable

class AdversaryLabController
{    
    static let sharedInstance = AdversaryLabController()
    private var adversaryLabClient: AdversaryLabClient?
       
    
    /// Uses AdversaryLab library to start recording packets
    /// - Parameters:
    ///   - transportName: The name of the transport being used for this connection as a String
    ///   - port: The capture port as a string
    ///   - interface: The name of the interface device if it is not the default.
    func launchAdversaryLab(transportName: String, port: String, interface: String?)
    {
        adversaryLabClient = AdversaryLabClientCore.AdversaryLabClient(transport: transportName, port: UInt16(string: port), allowBlock: nil)
        
        globalRunningLog.updateLog("\n🔬  Launching Adversary Lab.")
        
        let recording = adversaryLabClient?.startRecording(interface)
        
        if (recording == nil || !recording!)
        {
            globalRunningLog.updateLog("\n🔬  Failed to launch Adversary Lab: traffic data will not be recorded.")
        }
        
    }
    
    func stopAdversaryLab(testResult: TestResult?)
    {
        if let result = testResult
        {
            globalRunningLog.updateLog("\n🔬  Stopping Adversary Lab.\n")
            
            guard adversaryLabClient != nil
            else
            {
                globalRunningLog.updateLog("🔬  Attempted to stop adversary lab when it is not running.\n")
                return
            }
            
            // Before exiting let Adversary Lab know what kind of category this connection turned out to be based on whether or not the test was successful
            adversaryLabClient?.stopRecording(result.success)
        }
    }

}
