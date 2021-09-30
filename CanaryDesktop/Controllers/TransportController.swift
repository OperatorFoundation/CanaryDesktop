//
//  TransportController.swift
//  Canary
//
//  Created by Mafalda on 1/27/21.
//

import Foundation
import Logging

import ReplicantSwiftClient
import ReplicantSwift
import ShadowSwift
import Transport

#if (os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
import Network
#else
import NetworkLinux
#endif

class TransportController
{
    let transportQueue = DispatchQueue(label: "TransportQueue")
    let transport: Transport
    let serverIP: String
    let log: Logger
    
    var connectionCompletion: ((Connection?) -> Void)?
    var connection: Connection?
    
    init(transport: Transport, serverIP: String, log: Logger)
    {
        self.transport = transport
        self.serverIP = serverIP
        self.log = log        
    }
            
    func startTransport(completionHandler: @escaping (Connection?) -> Void)
    {
        connectionCompletion = completionHandler
        
        switch transport
        {
            case replicant:
                launchReplicant()
            case shadowsocks:
                launchShadow()
            default:
                print("Cannot start \(transport.name), this transport is not currently supported.")
                return
        }
    }
    
    func handleStateUpdate(_ newState: NWConnection.State)
    {
        guard let completion = connectionCompletion
        else
        {
            print("Unable to establish transport connection, our completion handler is nil.")
            return
        }
        
        switch newState
        {
            case .ready:
                completion(connection)
            case .cancelled:
                completion(nil)
            case .failed(let error):
                print("Transport connection failed: \(error)")
                completion(nil)
            default:
                return
        }
    }
    
    func launchShadow()
    {
        let configPath = "\(resourcesDirectoryPath)/\(shSocksFilePath)"
        guard let shadowConfig = ShadowConfig(path: configPath)
        else
        {
            globalRunningLog.updateLog("\n Unable to parse the ShadowSocks config at \(configPath)")
            print("\n Unable to parse the ShadowSocks config at \(configPath)")
            return
        }
        
        let port = NWEndpoint.Port(integerLiteral: shsocksServerPort)
        let host = NWEndpoint.Host(serverIP)
        let shadowFactory = ShadowConnectionFactory(host: host, port: port, config: shadowConfig, logger: log)
        
        guard var shadowConnection = shadowFactory.connect(using: .tcp)
        else
        {
            
            print("Failed to create a ShadowSocks connection.")
            return
        }
        
        connection = shadowConnection
        shadowConnection.stateUpdateHandler = self.handleStateUpdate
        shadowConnection.start(queue: transportQueue)
    }
    
    func launchReplicant()
    {
        guard let replicantConfig = ReplicantConfig<SilverClientConfig>(polish: nil, toneBurst: nil)
        else
        {
            print("Failed to create a replicant config.")
            return
        }

        guard let replicantFactory = ReplicantConnectionFactory(ipString: serverIP, portInt: UInt16(string: replicantServerPort), config: replicantConfig, logger: log)
        else
        {
            print("Failed to create Replicant Connection Factory")
            return
        }

        guard var replicantConnection = replicantFactory.connect(using: .tcp)
        else
        {
            print("Failed to create a Replicant connection.")
            return
        }

        connection = replicantConnection
        replicantConnection.stateUpdateHandler = self.handleStateUpdate
        replicantConnection.start(queue: transportQueue)
    }
}
