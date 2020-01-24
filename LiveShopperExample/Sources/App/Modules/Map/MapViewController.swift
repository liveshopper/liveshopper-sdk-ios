import LiveShopperSDK
import MapKit
import UIKit

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!

    var state: SDKState = .loading {
        willSet(newState) {
            update(newState)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            let destinationController = segue.destination as? TaskOverviewViewController,
            let taskContainer = sender as? LSTask {
            destinationController.task = taskContainer
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true

        App.shared.delegateService.register(delegate: self)

        setSpan()
    }

    override func viewWillAppear(_: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    private func setSpan() {
        var region = MKCoordinateRegion()

        region.span.latitudeDelta = 0.25
        region.span.longitudeDelta = 0.25
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.setCenter(userLocation.coordinate, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard
            !(annotation is MKUserLocation)
        else {
            return nil
        }

        let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView") ?? MKAnnotationView()
        dequeuedView.image = UIImage(named: "orange_pin")
        dequeuedView.annotation = annotation

        return dequeuedView
    }

    func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = (view.annotation as? TaskAnnotation) else { return }

        let task = annotation.task

        if task.state == .completed {
            let identifier = "RewardsViewController"
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            guard
                let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? RewardsViewController
            else {
                fatalError("RewardsViewController not found in storyboard")
            }

            viewController.task = task

            present(viewController, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: SegueIdentifier.taskOverview, sender: task)
        }
    }
}

extension MapViewController: SDKDelegate {
    func update(_ newState: SDKState) {
        switch (state, newState) {
            case (.loading, .loading): toLoading()
            case (.loading, .loaded), (.loaded, .loaded): toLoaded()
            default: fatalError("Transition from \(state) to \(newState) unsupported.")
        }
    }

    private func toLoaded() {
        let newTasks = App.shared.taskService.tasks

        mapView.removeAnnotations(mapView.annotations)

        newTasks.forEach {
            mapView.addAnnotation(TaskAnnotation(task: $0))
        }
    }

    private func toLoading() {}
}
