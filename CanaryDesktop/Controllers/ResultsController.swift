//
//  ResultsController.swift
//  Canary
//
//  Created by Mafalda on 7/27/20.
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
import ZIPFoundation

func zipResults()
{
    let sourceURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("adversary_data")
    
    guard FileManager.default.fileExists(atPath: sourceURL.path)
    else
    {
        print("\nWe were unable to save any results as no packets were captured.")
        return
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
    let zipName = "adversary_data_\(formatter.string(from: Date())).zip"
    let destinationURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(zipName)
    do {
        try FileManager.default.zipItem(at: sourceURL, to: destinationURL)
        globalRunningLog.updateLog("\n🍩🍩 Saved zip: \(destinationURL)\n")
    } catch {
        globalRunningLog.updateLog("\n🚨 Creation of ZIP archive failed with error:\(error) 🚨\n")
        return
    }
}
