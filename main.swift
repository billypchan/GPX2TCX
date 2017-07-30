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


let name = xmlGPX?.root["trk"]["name"].value
print(name)
//xmlGPX.


//xmlTCXtemplate?.root["Folders"]["Courses"]["CourseFolder"]["CourseNameRef"]["Id"].value = nil
var foldersTemplate = xmlTCXtemplate?.root["Folders"]
//let val = folders?["Courses"]["CourseFolder"]["CourseNameRef"]["Id"].last?.value
//let val = folders?.xmlCompact

foldersTemplate?["Courses"]["CourseFolder"]["CourseNameRef"]["Id"].value = nil

//print(val)
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
folders["Courses"]["CourseFolder"]["CourseNameRef"]["Id"].value = name

// prints the same XML structure as original
print(xmlTCXoutput.xml)
