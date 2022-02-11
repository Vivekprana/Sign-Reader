//
//  HandTerms.swift
//  HandPose
//
//  Created by Yannis De Cleene on 04/07/2020.
//  Copyright © 2020 Apple. All rights reserved.
//
import CoreGraphics

public struct Thumb {
    let TIP: CGPoint
    let IP: CGPoint
    let MP: CGPoint
    let CMC: CGPoint
}

struct PossibleThumb {
    let TIP: CGPoint?
    let IP: CGPoint?
    let MP: CGPoint?
    let CMC: CGPoint?
}

public struct Finger {
    let TIP: CGPoint
    let DIP: CGPoint
    let PIP: CGPoint
    let MCP: CGPoint
}

struct PossibleFinger {
    let TIP: CGPoint?
    let DIP: CGPoint?
    let PIP: CGPoint?
    let MCP: CGPoint?
}

enum FingerIndicator {
    case thumb
    case index
    case middle
    case ring
    case little
}

struct Fingers {
    let thumb: Thumb
    let index: Finger
    let middle: Finger
    let ring: Finger
    let little: Finger
    let wrist: CGPoint
    
    var letter: String?
    
    func extends(finger: FingerIndicator) -> Bool {
        var chosenFinger = index
        
        switch finger {
        case .index:
            chosenFinger = index
        case .middle:
            chosenFinger = middle
        case .ring:
            chosenFinger = ring
        case .little:
            chosenFinger = little
        case .thumb:
            let thumbTIPAngle = abs(CGPoint.angleBetween(p1: thumb.TIP, p2: thumb.IP, p3: thumb.MP))
            let TIPExtends = thumb.TIP.distance(from: wrist) > thumb.IP.distance(from: wrist) && thumbTIPAngle > 160.0
            let DIPExtends = thumb.IP.distance(from: wrist) > thumb.MP.distance(from: wrist)
            let PIPExtends = thumb.MP.distance(from: wrist) > thumb.CMC.distance(from: wrist)
            return TIPExtends && DIPExtends && PIPExtends
        }
        
        let TIPExtends = chosenFinger.TIP.distance(from: wrist) > chosenFinger.DIP.distance(from: wrist)
        let DIPExtends = chosenFinger.DIP.distance(from: wrist) > chosenFinger.PIP.distance(from: wrist)
        let PIPExtends = chosenFinger.PIP.distance(from: wrist) > chosenFinger.MCP.distance(from: wrist)
        return TIPExtends && DIPExtends && PIPExtends
    }
    func claws(finger: FingerIndicator) -> Bool {
        var chosenFinger = index
        
        switch finger {
        case .index:
            chosenFinger = index
        case .middle:
            chosenFinger = middle
        case .ring:
            chosenFinger = ring
        case .little:
            chosenFinger = little
        case .thumb:
            let thumbTIPAngle = abs(CGPoint.angleBetween(p1: thumb.TIP, p2: thumb.IP, p3: thumb.MP))
            let TIPExtends = thumb.TIP.distance(from: wrist) < thumb.IP.distance(from: wrist) && thumbTIPAngle > 160.0
            return TIPExtends
        }
        
        let TIPExtends = chosenFinger.TIP.distance(from: wrist) < chosenFinger.DIP.distance(from: wrist)
        return TIPExtends
    }
    
    func determineState(finger: FingerIndicator) -> String {
        // Set variables
        var chosenFinger = index
        var TIPExtends: Bool = false
        var DIPExtends: Bool = false
        var PIPExtends: Bool = false
        
        
        switch finger {
            case .index:
                chosenFinger = index
            case .middle:
                chosenFinger = middle
            case .ring:
                chosenFinger = ring
            case .little:
                chosenFinger = little
            case .thumb:
                let thumbTIPAngle = abs(CGPoint.angleBetween(p1: thumb.TIP, p2: thumb.IP, p3: thumb.MP))
                TIPExtends = thumb.TIP.distance(from: wrist) > thumb.IP.distance(from: wrist) && thumbTIPAngle > 160.0
                DIPExtends = thumb.IP.distance(from: wrist) > thumb.MP.distance(from: wrist)
                PIPExtends = thumb.MP.distance(from: wrist) > thumb.CMC.distance(from: wrist)
        }
        // Extends
        if(finger != .thumb){
            TIPExtends = chosenFinger.TIP.distance(from: wrist) > chosenFinger.DIP.distance(from: wrist)
            DIPExtends = chosenFinger.DIP.distance(from: wrist) > chosenFinger.PIP.distance(from: wrist)
            PIPExtends = chosenFinger.PIP.distance(from: wrist) > chosenFinger.MCP.distance(from: wrist)
        }
        if(TIPExtends && DIPExtends && PIPExtends) {
            return "extends"
        }
        else if(!TIPExtends && DIPExtends && PIPExtends){
            return "bent"
        }
        else if(!TIPExtends && !DIPExtends && PIPExtends){
            return "tucked"
        }
        else {
            return "folded"
        }
    }
    
    func extendsDirection(chosenFinger: Finger) -> String {
        if(chosenFinger.TIP.x - chosenFinger.MCP.x < abs(30)  && chosenFinger.PIP.x - chosenFinger.DIP.x < abs(30)) {
            if(chosenFinger.TIP.y > chosenFinger.MCP.y) {
                return "South"
            }
            else {
                return "North"
            }
        }
        else if(chosenFinger.TIP.y - chosenFinger.MCP.y < abs(45)  && chosenFinger.PIP.y - chosenFinger.DIP.y < abs(45)) {
            if(chosenFinger.TIP.x > chosenFinger.MCP.x) {
                return "East"
            }
            else {
                return "West"
            }
        }
        return "none"
    }
    
    func findGesture() -> String {
        let thumbState = determineState(finger: .thumb)
        let indexState = determineState(finger: .index)
        let middleState = determineState(finger: .middle)
        let ringState = determineState(finger: .ring)
        let littleState = determineState(finger: .little)
        
        print("thumb", thumbState)
        print("index", indexState)
        print("middle", middleState)
        print("ringState", ringState)
        print("littleState", littleState)
        let thumbAngle = abs(CGPoint.angleBetween(p1: thumb.IP, p2: thumb.MP, p3: thumb.CMC))
        let indexAngle = abs(CGPoint.angleBetween(p1: index.DIP, p2: index.PIP, p3: index.MCP))
        let middleAngle = abs(CGPoint.angleBetween(p1: middle.DIP, p2: middle.PIP, p3: middle.MCP))
        let ringAngle = abs(CGPoint.angleBetween(p1: ring.DIP, p2: ring.PIP, p3: ring.MCP))
        let littleAngle = abs(CGPoint.angleBetween(p1: little.DIP, p2: little.PIP, p3: little.MCP))
        
        // Let Pinch Distance come out
        typealias PointsPair = (thumbTip: CGPoint, indexTip: CGPoint)
        let standardPinchDistance = index.TIP.distance(from: thumb.TIP)
        let middlePinchDistance = middle.TIP.distance(from: thumb.TIP)
        let ringPinchDistance = ring.TIP.distance(from: thumb.TIP)
        let littlePinchDistance = little.TIP.distance(from: thumb.TIP)
        
        let ringLittlePIP = little.PIP.distance(from: ring.PIP)
        print("ring/litte distance", ringLittlePIP)
        print("standard Pinch Distance", standardPinchDistance)
        print("knuckle dist", index.PIP.distance(from: middle.PIP))
        

        print("thumbAngle", thumbAngle)
        print("indexang", indexAngle)
        print("middleang", middleAngle)
        print("ringAngle", ringAngle)
        print("littleAngle", littleAngle)
        
        print("middle Tip", middle.TIP.x)
        print("index Tip", index.TIP.x)
//        print("extends direction", extendsDirection(chosenFinger: index))
        
        var letter = ""
        if(standardPinchDistance < 40 && middlePinchDistance < 40 && ringPinchDistance < 40 && middleState != "extends" && indexState != "extends" && ringState != "extends" ) {
            letter = "O"
        }
        else if(thumbState == "extends" && standardPinchDistance > 100 && standardPinchDistance < 200 && index.TIP.y > index.PIP.y && index.PIP.y > index.MCP.y)
        {
            letter = "Q"
        }
        else if(indexState == "extends" && ringState != "extends" && littleState != "extends"){
            if(extendsDirection(chosenFinger: index) == "North")
            {
                if(middleState != "extends")
                {
                    if (thumbState == "extends") {
                        letter = "L"
                    }
                    else {
                        letter = "D"
                    }
                }
                else if(middleState == "extends")
                {
                    if(thumbState == "extends" && middle.TIP.y < middle.DIP.y) {
                        letter = "K"
                    }
                    else if(index.TIP.x - middle.TIP.x >= -15 && middleState == "extends") {
                        letter = "R"
                    }
                    else if(index.TIP.distance(from: middle.TIP) < 50){
                        letter = "U"
                    }
                    else if(index.TIP.distance(from: middle.TIP) > 50){
                        letter = "V"
                    }
                }
            }

            else if(extendsDirection(chosenFinger: index) == "West") {
                if(middleState != "extends") {
                    letter = "G"
                }
                else if(middleState == "extends" && extendsDirection(chosenFinger: middle) == "West") {
                    if (index.TIP.distance(from: middle.TIP) < 50)
                    {
                        letter = "H"
                    }
                    else {
                        letter = "P"
                    }
                }
                else {
                    letter = "P"
                }
            }
            else if(middleState != "extends" && thumbState == "extends")
            {
                letter = "Q"
            }
            else if(index.TIP.y > index.DIP.y && index.TIP.y > thumb.CMC.y)
            {
                letter = "Z"
            }
            else {
                letter = "P"
            }
        }
        else if(indexState != "extends" && (middleState != "extends") && ringState != "extends" && (littleState != "extends")) {
            if (index.TIP.y < middle.MCP.y && index.DIP.y < middle.DIP.y && (ringState == "tucked" || ringState == "folded")) {
                letter = "X"
            }
            else if(115 < thumbAngle && thumbAngle < 155) {
                if(thumb.TIP.y > index.TIP.y) {
                    letter = "E"
                }
                else if(thumbState == "bent")
                {
                    letter = "A"
                }
                else
                {
                    letter = "S"
                }
            }
            else if(ring.PIP.y < middle.PIP.y || ring.TIP.y < middle.TIP.y)
            {
                letter = "M"
            }
            else if(middle.PIP.y < index.PIP.y || middle.TIP.y < index.PIP.y)
            {
                letter = "N"
            }
            else if(index.PIP.y < middle.PIP.y || index.TIP.y < middle.PIP.y)
            {
                letter = "T"
            }
        }
        else if(indexState != "extends" && middleState == "extends" && ringState == "extends" && littleState == "extends") {
            letter = "F"
        }
        else if(indexState != "extends" && thumbState != "extends" && middleState != "extends" && ringState != "extends" && littleState == "extends") {
            if (little.TIP.y > little.MCP.y)
            {
                letter = "J"
            }
            else {
                letter = "I"
            }
                    
        }
        else if(indexState == "extends" && middleState == "extends" && ringState == "extends" && littleState == "extends") {
            if(thumbAngle > 160 && thumbAngle < 180 && middleAngle > 200 && ringAngle > 200 && littleAngle > 200){
                letter = "C"
            }
            
            else if(115 < thumbAngle && thumbAngle < 155){
                letter = "B"
            }
            
        }
        else if(ringState == "extends" && middleState == "extends" && indexState == "extends" && littleState != "extends" && thumbState != "extends") {
            letter = "W"
        }
        else if(ringState != "extends" && middleState != "extends" && indexState != "extends" && littleState == "extends" && thumbState == "extends") {
            letter = "Y"
        }
        else if(index.TIP.y > index.DIP.y && index.TIP.y > thumb.CMC.y) {
            letter = "Z"
        }

        print(letter)
        return letter
    }
}

typealias PossibleFingers = (thumb: PossibleThumb, index: PossibleFinger, middle: PossibleFinger, ring: PossibleFinger, little: PossibleFinger, wrist: CGPoint?)

let defaultHand = Fingers(thumb: Thumb(TIP: .zero, IP: .zero, MP: .zero, CMC: .zero),
                          index: Finger(TIP: .zero, DIP: .zero, PIP: .zero, MCP: .zero),
                          middle: Finger(TIP: .zero, DIP: .zero, PIP: .zero, MCP: .zero),
                          ring: Finger(TIP: .zero, DIP: .zero, PIP: .zero, MCP: .zero),
                          little: Finger(TIP: .zero, DIP: .zero, PIP: .zero, MCP: .zero),
                          wrist: .zero)
