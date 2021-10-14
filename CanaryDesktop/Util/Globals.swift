//
//  Globals.swift
//  CanaryDesktop
//
//  Created by Mafalda on 8/27/21.
//

import Foundation
import Logging

var uiLog = Logger(label: "org.OperatorFoundation.CanaryDesktopUI", factory: CanaryLogHandler.init)
var globalRunningLog = RunningLog()

class RunningLog: ObservableObject
{
    @Published var testsAreRunning = false
    @Published var logString: String = ""
    
    func updateState(runningTests: Bool)
    {
        DispatchQueue.main.async {
            self.testsAreRunning = runningTests
        }
    }
}
