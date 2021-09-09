//
//  KillAll.swift
//  transport-canary
//
//  Created by Adelita Schule on 7/10/17.
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

func killAll(processToKill: String)
{
    let killTask = Process()
    let executablePath = "/usr/bin/killall"
    
    killTask.executableURL = URL(fileURLWithPath: executablePath, isDirectory: false)
    //Arguments will pass the arguments to the executable, as though typed directly into terminal.
    killTask.arguments = [processToKill]
    killTask.standardOutput = Pipe()
    killTask.standardError = Pipe()
    
    //Go ahead and run the process/task
    killTask.launch()
    killTask.waitUntilExit()
    sleep(2)
    
    //Do it again, maybe it doesn't want to die.
    
    let killAgain = Process()
    killAgain.executableURL = URL(fileURLWithPath: executablePath, isDirectory: false)
    killAgain.arguments = ["-9", processToKill]
    killAgain.standardOutput = Pipe()
    killAgain.standardError = Pipe()
    killAgain.launch()
    killAgain.waitUntilExit()
    sleep(2)
}
