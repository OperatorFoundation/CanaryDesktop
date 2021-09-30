//
//  Globals.swift
//  CanaryDesktop
//
//  Created by Mafalda on 8/27/21.
//

import Foundation


var globalRunningLog = RunningLog()


class RunningLog: ObservableObject
{
    @Published var testsAreRunning = false
    @Published var logString: String = ""
    
    func updateLog(_ newMessage: String)
    {
        DispatchQueue.main.async { [self] in
            logString += newMessage
        }
    }
    
    func updateState(runningTests: Bool)
    {
        DispatchQueue.main.async {
            self.testsAreRunning = runningTests
        }
    }
}
