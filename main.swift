//
//  main.swift
//  GPX2TCXconverter
//
//  Created by chan bill on 29/7/2017.
//  Copyright © 2017 chan bill. All rights reserved.
//

import Foundation
import AEXML

// Create a FileManager instance

//let fileManager = FileManager.default
//
//// Get current directory path
//
//let path = fileManager.currentDirectoryPath
//print(path)

var xmlToParse = "?"

//let file = "2017-07-28_20218653_birkholzer-chaussee-blumberg-birkholz-loop-from-senefelderplatz_export.gpx" //this is the file. we will write to and read from it

let fullPath = "file:///Users/chanbill/Desktop/GPX2TCX/2017-07-28_20218653_birkholzer-chaussee-blumberg-birkholz-loop-from-senefelderplatz_export.gpx"
//if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//    
//    let path = dir.appendingPathComponent(file)
//    
//    //writing
////    do {
////        try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
////    }
////    catch {/* error handling here */}
//    
//}

//reading
if let url = URL(string:fullPath) {
    print(url)
do {
    xmlToParse = try String(contentsOf: url, encoding: String.Encoding.utf8)
}
catch {/* error handling here */}
}
else {
    print("convert to URL fail")
}

print(xmlToParse)
