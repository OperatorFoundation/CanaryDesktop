//
//  ContentView.swift
//  CanaryDesktop
//
//  Created by Mafalda on 8/6/21.
//

import SwiftUI
import Network
import ArgumentParser

struct ContentView: View
{
    
    @ObservedObject var runningLog = globalRunningLog
    
    @State private var ipStringMessage = ""
    @State private var isEditing = false
    @State private var isValidIP = false
    @State private var isValidConfigPath = false
    @State private var serverIP = UserDefaults.standard.string(forKey: serverIPKey) ?? ""
    @State private var testCount = 1
    @State private var configPath = UserDefaults.standard.string(forKey: configPathKey) ?? "Config Directory Needed"
        
    var body: some View
    {
        VStack()
        {
            Section(header:Text("Transport Server").bold()) // Server IP
            {
                TextField("Enter the transport server IP", text: $serverIP)
                {
                    (isEditing) in
                    
                    self.isEditing = isEditing
                }
                .onChange(of: serverIP)
                {
                    value in
                    
                    isValidIP = validate(serverIP: serverIP)
                    
                    if (isValidIP)
                    {
                        UserDefaults.standard.set(self.serverIP, forKey: serverIPKey)
                    }
                }
                .padding([.top, .leading, .trailing])
                .disableAutocorrection(true)
                .multilineTextAlignment(.center)
                
                Text(serverIP)
                    .foregroundColor(!isValidIP ? .red : .blue)
            }
            Divider()
            Section(header: Text("Transport Config Files").bold()) // Configs Folder
            {
                Text(configPath)
                    .foregroundColor(isValidIP ? .blue: .red)
                    .padding(.top)
                
                
                Button("Browse")
                {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    if panel.runModal() == .OK
                    {
                        isValidConfigPath = validate(configURL: panel.url)
                        
                        if isValidConfigPath
                        {
                            configPath = panel.url!.path
                            UserDefaults.standard.set(self.configPath, forKey: configPathKey)
                        }
                        else
                        {
                            configPath = "Invalid Directory Path"
                        }
                    }
                }
                .disabled(globalRunningLog.testsAreRunning)
            }
            Divider()
            Section() // Number of runs
            {
                Text("How many times do you want to run the test?")
                    .fontWeight(.regular)
                    .padding(.top)
                
                Stepper("\(testCount) time(s)")
                {
                    if testCount < 10
                    {
                        testCount += 1
                    }
                }
                onDecrement:
                {
                    if testCount > 0
                    {
                        testCount -= 1
                    }
                }
                .padding(.leading)
            }
            Section() // Start Test(s)
            {
                Button("Run Test")
                {
                    if (isValidIP && isValidConfigPath)
                    {
                        runningLog.logString += "\nRunning Canary tests. This may take a few moments.\n"
                        var test = CanaryTest(serverIP: serverIP, testCount: testCount)
                        test.resourceDirPath = configPath
                        test.runTest()
                    }
                    else
                    {
                        runningLog.logString += "\nFailed to run the requested tests, please check that you entered a valid IP address, and that the config directory you selected has the correct transport config files.\n"
                    }
                }
                .disabled(globalRunningLog.testsAreRunning)
                .padding(.top)
            }
            Divider()
            Section(header: Text("Run Log").bold()) // Log
            {
                
            }
        }
        ScrollViewReader // Test Log with automatic scrolling
        {
            sp in
            
            ScrollView
            {
                Text(runningLog.logString)
                    .id(0)
                    .onChange(of: runningLog.logString)
                {
                    Value in
                    sp.scrollTo(0, anchor: .bottom)
                }
            }
            .frame(maxHeight: 150)
        }
        .onAppear()
        {
            
            isValidIP = validate(serverIP: serverIP)
            isValidConfigPath = validate(configURL: URL(string: configPath))
        }
        .padding(.vertical)
    }
    
    func validate(serverIP: String) -> Bool
    {
        var sin = sockaddr_in()
            return serverIP.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1
    }
    
    func validate(configURL: URL?) -> Bool
    {
        guard let isaURL = configURL
        else { return false }
        
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: isaURL.path, isDirectory: &isDirectory)
        
        return exists && isDirectory.boolValue
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
