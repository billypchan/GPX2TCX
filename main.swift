//
//  main.swift
//  GPX2TCX
//
//  Created by chan bill on 29/7/2017.
//  Copyright © 2017 chan bill. All rights reserved.
//

import Foundation
import AEXML
import CoreLocation

///TODO: pull request
extension AEXMLElement {
    func copy() -> AEXMLElement {
        let clone = AEXMLElement(name: self.name, attributes: self.attributes)
        
        for child in self.children {
            clone.addChild(child.copy())
        }
        
        return clone
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}


extension Double {
    func string(fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

func distanceFormCoordinates(lat0: Double, log0: Double, lat1: Double, log1: Double) -> Double{
    let coordinate0 = CLLocation(latitude: lat0, longitude: log0)
    let coordinate1 = CLLocation(latitude: lat1, longitude: log1)
    
    let distanceInMeters = coordinate0.distance(from: coordinate1)
    
    return distanceInMeters
}


func readXML(_ fullPath: String) -> AEXMLDocument?{
    var xmlToParse = "?"
    
    //reading
    if let url = URL(string:fullPath) {
        do {
            xmlToParse = try String(contentsOf: url, encoding: String.Encoding.utf8)
        }
        catch {/* error handling here */}
    }
    else {
        print("convert to URL fail, string = \(fullPath)")
    }
    
    
    do {
        //        print("xmlToParse")
        let xmlDoc = try AEXMLDocument(xml: xmlToParse)
        return xmlDoc
    }
    catch {
        print("\(error)")
    }
    
    return nil
}




let fullPath = "file:///Users/chanbill/Desktop/GPX2TCX/2017-07-28_20218653_birkholzer-chaussee-blumberg-birkholz-loop-from-senefelderplatz_export.gpx"

let fullPathTCXTemplate = "file:///Users/chanbill/Desktop/GPX2TCX/template.tcx"
let fullPathTCXOutput = "file:///Users/chanbill/Desktop/GPX2TCX/output.tcx"

let xmlGPX = readXML(fullPath)
let xmlTCXtemplate = readXML(fullPathTCXTemplate)

var foldersTemplate = xmlTCXtemplate?.root["Folders"]

foldersTemplate?["Courses"]["CourseFolder"]["CourseNameRef"]["Id"].value = nil

var coursesTemplate = xmlTCXtemplate?.root["Courses"]
var courseTemplate = coursesTemplate?["Course"].first
var lapTemplate = courseTemplate?["Lap"].first
var trackpointTemplate = courseTemplate?["Track"]["Trackpoint"].first

trackpointTemplate?["Time"].value = "0"
trackpointTemplate?["Position"]["LatitudeDegrees"].value = "0"
trackpointTemplate?["Position"]["LongitudeDegrees"].value = "0"
trackpointTemplate?["AltitudeMeters"].value = "0"
trackpointTemplate?["DistanceMeters"].value = "0"

//lapTemplate?["TotalTimeSeconds"].removeFromParent()
//lapTemplate?["DistanceMeters"].removeFromParent()

lapTemplate?["BeginPosition"]["LatitudeDegrees"].value = "0"
lapTemplate?["BeginPosition"]["LongitudeDegrees"].value = "0"
lapTemplate?["EndPosition"]["LatitudeDegrees"].value = "0"
lapTemplate?["EndPosition"]["LongitudeDegrees"].value = "0"

//folders?["CourseFolder"]["CourseNameRef"]["Id"].value = nil
//print(folders?.xml)
//var id = xmlTCXtemplate?.root["Folders"]["CourseFolder"]["CourseNameRef"]["Id"]
//print(id?.xml)

// create XML Document
let xmlTCXoutput = AEXMLDocument()

//let trainingCenterDatabase = xmlTCXtemplate?.root["trainingCenterDatabase"]

//let trainingCenterDatabase = xmlTCXoutput.addChild((xmlTCXtemplate?.root["TrainingCenterDatabase"])!)
let trainingCenterDatabase = xmlTCXoutput.addChild(name: (xmlTCXtemplate?.root.name)!, attributes:(xmlTCXtemplate?.root.attributes)!)

let folders = trainingCenterDatabase.addChild(foldersTemplate!)
var trkName = xmlGPX?.root["trk"]["name"].value
/** Hack: Germin 500 does not like name.count > 15  */
if (trkName?.characters.count)! > 15 {
    let index = trkName?.index((trkName?.startIndex)!, offsetBy: 15)
    trkName = trkName?.substring(to: index!)
}
folders["Courses"]["CourseFolder"]["CourseNameRef"]["Id"].value = trkName

let course = trainingCenterDatabase.addChild(name:"Courses").addChild(name:"Course")

let name = course.addChild(name:"Name")
name.value = trkName

let lap = course.addChild(lapTemplate!)

let beginPosition = xmlGPX?.root["trk"]["trkseg"]["trkpt"].first?.attributes
let endPosition = xmlGPX?.root["trk"]["trkseg"]["trkpt"].last?.attributes

lap["BeginPosition"]["LatitudeDegrees"].value = beginPosition?["lat"]
lap["BeginPosition"]["LongitudeDegrees"].value = beginPosition?["lon"]
lap["EndPosition"]["LatitudeDegrees"].value = endPosition?["lat"]
lap["EndPosition"]["LongitudeDegrees"].value = endPosition?["lon"]

let beginTime = xmlGPX?.root["trk"]["trkseg"]["trkpt"].first?["time"].value
let endTime = xmlGPX?.root["trk"]["trkseg"]["trkpt"].last?["time"].value

let beginDate = beginTime?.dateFromISO8601
let totalTimeSeconds = endTime?.dateFromISO8601?.timeIntervalSince(beginDate!)

lap["TotalTimeSeconds"].value = String(describing: Int(totalTimeSeconds!))

var lastLat = Double(0)
var lastLog = Double(0)
var totalDistance = Double(-1)

let track = course.addChild(name:"Track")

for trkpt in (xmlGPX?.root["trk"]["trkseg"]["trkpt"].all)! {
    let trackPoint = track.addChild((trackpointTemplate?.copy())!)
    
    trackPoint["Time"].value = trkpt["time"].value
    let lat = Double(trkpt.attributes["lat"]!)!
    let log = Double(trkpt.attributes["lon"]!)!
    
    trackPoint["Position"]["LatitudeDegrees"].value = trkpt.attributes["lat"]
    trackPoint["Position"]["LongitudeDegrees"].value = trkpt.attributes["lon"]
    trackPoint["AltitudeMeters"].value = trkpt["ele"].value
    if totalDistance == -1 {
        trackPoint["DistanceMeters"].value = "0"
        totalDistance = 0
    }
    else {
        let distance = distanceFormCoordinates(lat0: lastLat, log0: lastLog, lat1: lat, log1: log)
        totalDistance += distance
        trackPoint["DistanceMeters"].value = String(totalDistance)
    }
    
    lastLat = lat
    lastLog = log
}

lap["DistanceMeters"].value = totalDistance.string(fractionDigits:1)

//writing
do {
    try xmlTCXoutput.xml.write(to: URL(string:fullPathTCXOutput)!, atomically: false, encoding: String.Encoding.utf8)
}
catch {/* error handling here */}
