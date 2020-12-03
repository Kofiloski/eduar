//
//  MapController.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 6/27/19.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import os

protocol MapControllerNotifierDelegate: class {
    func reachedDestination()
    func retrievedRoutes(routes: [MKRoute])
}

class MapController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.showsBackgroundLocationIndicator = true
        return locationManager
    }()
    
    private var notificationCenter: UNUserNotificationCenter = {
        return UNUserNotificationCenter.current()
    }()
    
    weak var delegate: MapControllerNotifierDelegate?
    
    private var mapSetup = false
    private var reachedDestination = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        checkNotificationStatus()
        // Note: For quick discovery of max, uncomment the following line.
        // delegate?.reachedDestination()
    }
    
    // MARK: Notifications Handling
    
    private func checkNotificationStatus() {
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                self.requestNotifications()
                return
            }
        }
    }
    
    private func requestNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            if granted {
                return
            } else {
                self.presentEnableNotificationsAlert()
            }
        }
    }
    
    private func presentEnableNotificationsAlert() {
        let alertController = UIAlertController(title: "Notifications disabled", message: "Please enable notifications so we can notify you when you are near to Max.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        
        alertController.addAction(okayAction)
        present(alertController, animated: true)
    }
    
    // MARK: Setting up map
    
    private func setupMapRegion() {
        guard let location = locationManager.location else {
            return
        }
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                               longitudeDelta: 0.01))
        mapView.camera.centerCoordinate = location.coordinate
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)
        mapView.centerCoordinate = location.coordinate
        zoom()
    }
    
    private func zoom() {
        var region = mapView.region
        var span = mapView.region.span
        span.latitudeDelta *= 0.2
        span.longitudeDelta *= 0.2
        region.span = span
        mapView.setRegion(region, animated: true)
        mapSetup = true
        // Waiting for the animation of mapView.setRegion to finish.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.calculateRandomLocationBasedOnCurrentLocation()
        }
    }
    
    /// Takes user current location from the map and selects random location between 500 and 550, and adds a pin on that location.
    /// To approximate between 500 and 550, this is not too close so we can get a path, and not too far so the user doesn't have to walk too much.
    private func calculateRandomLocationBasedOnCurrentLocation() {
        let randomNumber = Int.random(in: 500..<550)
        let centerMapPoint = CGPoint(x: mapView.center.x + CGFloat(randomNumber), y: mapView.center.y + CGFloat(randomNumber))
        let centerMapCoordinate = mapView.convert(centerMapPoint, toCoordinateFrom: mapView)
        
        guard let locationLat = locationManager.location?.coordinate.latitude,
              let locationLon = locationManager.location?.coordinate.longitude else {
            os_log("Error: Failed to get current user location lat. and lot.", log: .default, type: .info)
            return
        }
        
        let randomBetweenNumbers = { (firstNumber: Float, secondNumber: Float) -> Float in
            return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
        }
        
        let latRange = randomBetweenNumbers(Float(centerMapCoordinate.latitude), Float(locationLat))
        let longRange = randomBetweenNumbers(Float(centerMapCoordinate.longitude), Float(locationLon))
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(latRange), longitude: CLLocationDegrees(longRange))
        
        addPinToMap(on: location)
        createAndMonitorRegion(centerLocation: location)
    }
    
    private func addPinToMap(on location: CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = location
        pin.title = "Max"
        mapView.addAnnotation(pin)
        calculateDirectionsTo(endAnnotation: pin)
    }
    
    private func createAndMonitorRegion(centerLocation: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: centerLocation, radius: 0.5, identifier: "Pinregion")
        // Waiting for the location manager to stabilize with location.
        // After that add monitoring to avoid false positives of user entering the region.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.locationManager.startMonitoring(for: region)
        }
    }
    
    private func calculateDirectionsTo(endAnnotation: MKAnnotation) {
        let destinationPlacemark = MKPlacemark(coordinate: endAnnotation.coordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.transportType = .walking
        directionRequest.destination = destinationMapItem
        directionRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response,
                  let route = response.routes.first,
                  error == nil else {
                os_log("Error: %@", log: .default, type: .error, String(describing: error))
                return
            }
            
            self.delegate?.retrievedRoutes(routes: response.routes)
            self.showRouteOnMap(route)
        }
    }
    
    private func showRouteOnMap(_ route: MKRoute) {
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
        
        mapView.addOverlay(route.polyline, level: .aboveRoads)
        let rect = route.polyline.boundingMapRect
        mapView.setRegion(MKCoordinateRegion(rect), animated: true)
    }
    
    private func presentNotification() {
        let content = UNMutableNotificationContent()
        content.title = "You found Max"
        content.body = "Switch to AR to see Max."
        content.categoryIdentifier = "alarm"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    /// Logic to be executed when user reached the destination.
    private func performReachedDestination() {
        if !reachedDestination {
            reachedDestination = true
            presentNotification()
            delegate?.reachedDestination()
        }
    }
}

// MARK: CLLocationManagerDelegate

extension MapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last != nil && !mapSetup {
            setupMapRegion()
        }
    }
    
    // Note: Gives false positives
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion,
           region.identifier == "Pinregion" {
            performReachedDestination()
        }
    }
    
    // Note: Gives false positives
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if let region = region as? CLCircularRegion,
           region.identifier == "Pinregion",
           state == .inside {
            performReachedDestination()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways || status != .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}

// MARK: MKMapViewDelegate

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 5.0
        return renderer
    }
}
