//
//  main.swift
//  GPX2TCX
//
//  Created by chan bill on 29/7/2017.
//  Copyright © 2017 chan bill. All rights reserved.
//

import Foundation
import AEXML

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

let xmlGPX = readXML(fullPath)
let xmlTCXtemplate = readXML(fullPathTCXTemplate)

var foldersTemplate = xmlTCXtemplate?.root["Folders"]
//let val = folders?["Courses"]["CourseFolder"]["CourseNameRef"]["Id"].last?.value
//let val = folders?.xmlCompact

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
///FIXME: calc DistanceMeters
trackpointTemplate?["DistanceMeters"].removeFromParent()


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
let lap = course.addChild(lapTemplate!)

let beginPosition = xmlGPX?.root["trk"]["trkseg"]["trkpt"].first?.attributes
let endPosition = xmlGPX?.root["trk"]["trkseg"]["trkpt"].last?.attributes

lap["BeginPosition"]["LatitudeDegrees"].value = beginPosition?["lat"]
lap["BeginPosition"]["LongitudeDegrees"].value = beginPosition?["lon"]
lap["EndPosition"]["LatitudeDegrees"].value = endPosition?["lat"]
lap["EndPosition"]["LongitudeDegrees"].value = endPosition?["lon"]


for trkpt in (xmlGPX?.root["trk"]["trkseg"]["trkpt"].all)! {
    let track = course.addChild(name:"Track").addChild(trackpointTemplate!)

    track["Time"].value = trkpt["time"].value
    track["Position"]["LatitudeDegrees"].value = trkpt.attributes["lat"]
    track["Position"]["LongitudeDegrees"].value = trkpt.attributes["lon"]
    track["AltitudeMeters"].value = trkpt["ele"].value
//    track["DistanceMeters"].value = "0"

//    break
}

// prints the same XML structure as original
print(xmlTCXoutput.xml)
