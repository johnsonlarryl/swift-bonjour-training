//
// Created by Larry Johnson on 8/18/18.
// Copyright (c) 2018 Larry Johnson. All rights reserved.
//

import Foundation

enum ServiceStatus: String {
    case UKNONWN = "unknown"
    case STOPPED = "stopped"
    case STARTING = "starting"
    case ACTIVE = "active"
    case FAILED_TO_START = "failed to start"
    case WAITING_FOR_CLIENT_MESSAGE = "waiting for client message"
    case WAITING_FOR_SERVER_MESSAGE = "waiting for server message"
}