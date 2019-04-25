//
//  ViewController.swift
//  Seattle Commons Map
//
//  Created by Michael Rockhold on 4/24/19.
//  Copyright © 2019 Michael Rockhold. All rights reserved.
//

import UIKit
import Mapbox

class MapViewController: UIViewController {

    override func loadView() {
        view = MGLMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), styleURL: mapDataSource.mapboxStyleURL)
        (view as! MGLMapView).setCenter(mapDataSource!.startingCenter,
                                        zoomLevel: mapDataSource!.startingZoomLevel,
                                        animated: false)
    }
    
    var mapView: MGLMapView {
        return self.view as! MGLMapView
    }
    
    // vc does not own its map view delegate, it's lent one by its owner
    weak var mapDataSource: MapDataSource!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, mapDataSource: MapDataSource) {
        self.mapDataSource = mapDataSource
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // TODO: implement me properly: discover a mapViewDelegate to use based on decoded info
    required init?(coder aDecoder: NSCoder) {
        mapDataSource = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = mapDataSource
        
        mapView.showsUserLocation = mapDataSource.showsUserLocation
        
        // Get the path for example.geojson in the app's bundle
        let jsonPath = Bundle.main.path(forResource: "features", ofType: "geojson")

        mapDataSource.loadFeatures(at: URL(fileURLWithPath: jsonPath!)) { features in
            if let features = features {
                // Add the annotation (if any) on the main thread
                guard features.count > 0 else {
                    return
                }
                DispatchQueue.main.async(execute: {
                    // Unowned reference to self to prevent retain cycle
                    [unowned self] in
                    self.mapView.addAnnotations(features)
                })
            }
        }
    }

}

