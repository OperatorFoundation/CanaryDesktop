//
//  CanaryLogHandler.swift
//  CanaryDesktop
//
//  Created by Mafalda on 10/14/21.
//

import Foundation
import Logging

public struct CanaryLogHandler
{
    public var metadata = Logger.Metadata()
    public var logLevel = Logger.Level.info

    private let label: String

    public init(label: String)
    {
        self.label = label
    }
}

extension CanaryLogHandler: LogHandler
{
    public subscript(metadataKey key: String) -> Logger.Metadata.Value?
    {
        get
        {
            metadata[key]
        }
        set(newValue)
        {
            metadata[key] = newValue
        }
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt)
    {
        var mergedMetadata = self.metadata
        for (key, value) in metadata ?? [:]
        {
            mergedMetadata[key] = value // Override keys if necessary
        }
        
        DispatchQueue.main.async
        {
            globalRunningLog.logString += message.description
        }
        
    }
}
