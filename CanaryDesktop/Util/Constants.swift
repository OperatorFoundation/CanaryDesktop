//
//  Constants.swift
//  Canary
//
//  Created by Mafalda on 8/15/19.
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

/// Yes, this one's a var.
/// Note: this directory will not work when running in Xcode, as we populate this using currentDirectoryPath which points to derived data.
var resourcesDirectoryPath = "\(FileManager.default.currentDirectoryPath)/Sources/Resources"

let adversaryLabClientProcessName = "AdversaryLabClient"
let shShifterResourcePath = "shapeshifter-dispatcher"

let obfs2ServerPort = "4567"
let obfs4ServerPort = "1234"
let shsocksServerPort: UInt16 = 2345
let meekServerPort = "443"
let replicantServerPort = "2277"

let allTransports = [replicant, shadowsocks]

let httpRequestString = "GET / HTTP/1.0\r\nConnection: close\r\n\r\n"
let canaryString = "Yeah!\n"

let meekOptionsPath = "Configs/meek.json"
let obfs4FilePath = "Configs/obfs4.json"
let obfs4iatFilePath = "Configs/obfs4iatMode.json"
let shSocksFilePath = "shadowsocks.json"
let replicantFilePath = "ReplicantClientConfig.json"

//Transports
let obfs2 = Transport(name: "obfs2", port: obfs2ServerPort)
let obfs4 = Transport(name: "obfs4", port: obfs4ServerPort)
let obfs4iatMode = Transport(name: "obfs4iatMode", port: obfs4ServerPort)
let shadowsocks = Transport(name: "shadow", port: "\(shsocksServerPort)")
let replicant = Transport(name: "Replicant", port: replicantServerPort)
let meek = Transport(name: "meeklite", port: meekServerPort)

// Web Tests
let facebook = WebTest(website: "https://www.facebook.com/", name: "facebook", port: "443")
let cnn = WebTest(website: "https://www.cnn.com/", name: "cnn", port: "443")
let wikipedia = WebTest(website: "https://www.wikipedia.org/", name: "wikipedia", port: "443")
let ymedio = WebTest(website: "https://www.14ymedio.com", name: "14ymedio", port: "443")
let cnet = WebTest(website: "https://www.cubanet.org", name: "cnet", port: "443")
let diario = WebTest(website: "https://diariodecuba.com", name: "diario", port: "443")

let allWebTests = [facebook, cnn, wikipedia, ymedio]

let stateDirectoryPath = "TransportState"

let resultsFileName = "CanaryResults"
let resultsExtension = "csv"
let outputDirectoryName = "Output"

let serverIPKey = "ServerIP"
let configPathKey = "ConfigPath"
