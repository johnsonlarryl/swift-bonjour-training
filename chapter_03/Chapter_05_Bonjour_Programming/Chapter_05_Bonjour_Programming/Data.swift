//
// Created by Larry Johnson on 8/20/18.
// Copyright (c) 2018 Larry Johnson. All rights reserved.
//

import Foundation

extension Data {
    /**
        Consumes the specified input stream, creating a new Data object
        with its content.
        - Parameter reading: The input stream to read data from.
        - Note: Closes the specified stream.
    */
    init(reading input: InputStream) {
        self.init()
        input.open()

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            self.append(buffer, count: read)
        }
        buffer.deallocate(capacity: bufferSize)

        input.close()
    }
}