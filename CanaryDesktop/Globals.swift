//
//  Globals.swift
//  CanaryDesktop
//
//  Created by Mafalda on 8/27/21.
//

import Foundation
import Logging

let serverIPKey = "ServerIP"
let configPathKey = "ConfigPath"

var uiLog = Logger(label: "CanaryDesktop.MacOS", factory: CanaryLogHandler.init)
var globalRunningLog = RunningLog()

class RunningLog: ObservableObject
{
    @Published var logString: String = ""
}
