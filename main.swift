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

extension AEXMLElement {
    func copy() -> AEXMLElement {
        let clone = AEXMLElement(name: self.name, attributes: self.attributes)
        
        for child in self.children {
            clone.addChild(child.copy())
        }
        
        return clone
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


//print(trackpointTemplate?.xml)


///FIXME: calc DistanceMeters/TotalTimeSeconds
lapTemplate?["TotalTimeSeconds"].removeFromParent()
lapTemplate?["DistanceMeters"].removeFromParent()

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
let trkName = xmlGPX?.root["trk"]["name"].value
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

var lastLat = Double(0)
var lastLog = Double(0)
var totalDistance = Double(-1)

for trkpt in (xmlGPX?.root["trk"]["trkseg"]["trkpt"].all)! {
    let track = course.addChild(name:"Track").addChild((trackpointTemplate?.copy())!)
    
    track["Time"].value = trkpt["time"].value
    let lat = Double(trkpt.attributes["lat"]!)!
    let log = Double(trkpt.attributes["lon"]!)!
    
    track["Position"]["LatitudeDegrees"].value = trkpt.attributes["lat"]
    track["Position"]["LongitudeDegrees"].value = trkpt.attributes["lon"]
    track["AltitudeMeters"].value = trkpt["ele"].value
    if totalDistance == -1 {
        track["DistanceMeters"].value = "0"
        totalDistance = 0
    }
    else {
        let distance = distanceFormCoordinates(lat0: lastLat, log0: lastLog, lat1: lat, log1: log)
        totalDistance += distance
        track["DistanceMeters"].value = String(totalDistance)
    }
    
    lastLat = lat
    lastLog = log
}

// prints the same XML structure as original
//print(xmlTCXoutput.xml)

//writing
do {
    try xmlTCXoutput.xml.write(to: URL(string:fullPathTCXOutput)!, atomically: false, encoding: String.Encoding.utf8)
}
catch {/* error handling here */}
