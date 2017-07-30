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

///FIXME: calc DistanceMeters/TotalTimeSeconds
lapTemplate?["TotalTimeSeconds"].removeFromParent()
lapTemplate?["DistanceMeters"].removeFromParent()

lapTemplate?["BeginPosition"]["LatitudeDegrees"].value = "0"
lapTemplate?["BeginPosition"]["LongitudeDegrees"].value = "0"
lapTemplate?["EndPosition"]["LatitudeDegrees"].value = "0"
lapTemplate?["EndPosition"]["LongitudeDegrees"].value = "0"

print(lapTemplate?.xml)

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

let lap = trainingCenterDatabase.addChild(name:"Courses").addChild(name:"Course").addChild(lapTemplate!)

let beginPosition = xmlGPX?.root["trk"]["trkseg"]["trkpt"].first?.attributes
let endPosition = xmlGPX?.root["trk"]["trkseg"]["trkpt"].last?.attributes

lap["BeginPosition"]["LatitudeDegrees"].value = beginPosition?["lat"]
lap["BeginPosition"]["LongitudeDegrees"].value = beginPosition?["lon"]
lap["EndPosition"]["LatitudeDegrees"].value = endPosition?["lat"]
lap["EndPosition"]["LongitudeDegrees"].value = endPosition?["lon"]


// prints the same XML structure as original
print(xmlTCXoutput.xml)
