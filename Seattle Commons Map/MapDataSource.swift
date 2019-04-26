//
//  MapDataSource.swift
//  Seattle Commons Map
//
//  Created by Michael Rockhold on 4/25/19.
//  Copyright © 2019 Michael Rockhold. All rights reserved.
//

import UIKit
import Mapbox
import MapKit

class MapDataSource: NSObject, MGLMapViewDelegate {

    let startingCenter: CLLocationCoordinate2D
    let startingZoomLevel: Double
    let mapboxStyleURL: URL
    let showsUserLocation: Bool = true
    
    init(startingCenter: CLLocationCoordinate2D, startingZoomLevel: Double, mapboxStyleURL: URL) {
        self.startingCenter = startingCenter
        self.startingZoomLevel = startingZoomLevel
        self.mapboxStyleURL = mapboxStyleURL
        super.init()
    }
    
    // TODO: check out this great error handling
    func loadFeatures(at url:URL, andThen continuation: @escaping ([MGLFeature]?)->Void) {
        
        // Parsing GeoJSON can be CPU intensive, do it on a background thread
        DispatchQueue.global(qos: .background).async {
            
            do {
                // Convert the file contents to a shape collection feature object
                let data = try Data(contentsOf: url)
                
                guard let shapeCollectionFeature = try MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as? MGLShapeCollectionFeature else {
                    fatalError("Could not cast to specified MGLShapeCollectionFeature")
                }
                
                continuation(shapeCollectionFeature.shapes)
                
            } catch {
                fatalError("GeoJSON parsing failed")
            }
        }
    }
    
    func name(of annotation: MGLShape) -> String? {
        if let attributes = annotation.value(forKey:"attributes") as! Dictionary<String,Any>?,
            let name = attributes["name"] as! String? {
                return name
        }
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.75
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 3.0
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        if let name = name(of: annotation) {
            if name.contains("green street") || name == "Seattle Commons Park" {
                return .green
            }
        }
        return .red
    }

    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return .green
    }
}
