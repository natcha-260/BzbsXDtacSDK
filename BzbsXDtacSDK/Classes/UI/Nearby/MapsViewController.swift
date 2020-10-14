//
//  MapsViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 27/9/2562 BE.
//

import UIKit
import GoogleMaps
import InfiniteCarouselCollectionView

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var place: BzbsPlace?
    var locationID:Int? {
        place?.locationId
    }
    
    init(position: CLLocationCoordinate2D, name: String, place: BzbsPlace?) {
        self.position = position
        self.name = name
        self.place = place
    }
}


class MapsViewController: BzbsXDtacBaseViewController ,UIScrollViewDelegate{
    
    // MARK:- Properties
    // MARK:- Outlet
    @IBOutlet weak var vwOverlay: UIView!
    @IBOutlet weak var vwPlace: UIView!
    @IBOutlet weak var cstBottoom: NSLayoutConstraint!
    @IBOutlet weak var vwMapContainer: UIView!
    @IBOutlet weak var vwCurrent: UIView!
    @IBOutlet weak var vwCurrentShadow: UIView!
    @IBOutlet weak var vwBtnImv: UIView!
    @IBOutlet weak var cstCurrent: NSLayoutConstraint!
    
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var vwLeft: UIView!
    @IBOutlet weak var vwRight: UIView!
    @IBOutlet weak var vwButton: UIView!
    @IBOutlet weak var lblDirection: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cstContainerViewWidth: NSLayoutConstraint!
    
    
    // MARK:- Variable
    var campaigns :[BzbsCampaign]!
    var places = [BzbsPlace]()
    var mapView : GMSMapView!
    var currentMarker : GMSMarker?
    var customHeader : String?
    var currentIndex : Int = 0
    
    var clusterManager: GMUClusterManager!
    
    var currentPlace:BzbsPlace?
    {
        didSet{
            if currentPlace == nil {
                closeInfoView()
            }
        }
    }
    
    var listCurrentPlace:[POIItem]?
    {
        didSet{
            if listCurrentPlace == nil {
                closeInfoView()
            } else {
                showInfoView()
            }
        }
    }
    var itemView = [UIView]()
    var isShowBackToList = true
    
    var backSelector: (() -> Void)?
    
    // MARK:- View life cycle
    // MARK:-
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        if isShowBackToList {
            self.navigationItem.rightBarButtonItems = BarItem.generate_nearby(self, selector: #selector(backToList))
        }
        
        lblDirection.textColor = .white
        lblAmount.textColor = .lightGray
        lblDirection.font = UIFont.mainFont()
        lblAmount.font = UIFont.mainFont()
        vwButton.backgroundColor = .dtacBlue
        vwButton.cornerRadius()
        
        vwOverlay.alpha = 0
        cstBottoom.constant = -1 * self.vwOverlay.bounds.size.height
        //        vwOverlay.layoutIfNeeded()
        
        cstCurrent.constant = 8
        
        vwCurrent.cornerRadius()
        vwCurrentShadow.addShadow(shadowRadius: 2.5, shadowOffset: CGSize.zero)
        if currentMarker == nil
        {
            intiMapView()
        }
        
        let strTitle = customHeader ?? currentPlace?.name ?? "nearby_map_title".localized()
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = strTitle
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
//        self.title = strTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        scrollView.delegate = self
        scrollView.indicatorStyle = .white
        lblDirection.text = "nearby_direction".localized()
        
        if let place = currentPlace,
            let lat = place.latitude,
            let lon = place.longitude
        {
            delay(1) {
                DispatchQueue.main.async {
                    let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    self.showInfoView()
                    let poiItem = POIItem(position: location, name: place.name ?? "", place: place)
                    self.updateDetail([poiItem], position: location)
                }
            }
        }

        analyticsSetScreen(screenName: "dtac_reward_map")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
    }
    
    override func back_1_step() {
        backSelector?()
        super.back_1_step()
    }
    
    @objc func backToList()
    {
        super.back_1_step()
        isClickBack = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = vwMapContainer.bounds
        mapView.frame = frame
        mapView.layoutIfNeeded()
    }
    
    override func updateLocation() {
        
        if currentMarker == nil
        {
            intiMapView()
        }
    }
    
    func intiMapView() {
        if let coordinate = LocationManager.shared.coordinate
        {
            currentMarker = GMSMarker(position: coordinate)
            currentMarker?.icon = UIImage(named: "img_location", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        }
        let currentPosition = currentMarker?.position ?? CLLocationCoordinate2DMake(0, 0)
        let camera = GMSCameraPosition.camera(withTarget: currentPosition, zoom: 15.0)
        var frame = vwMapContainer.frame
        frame.origin = CGPoint.zero
        mapView = GMSMapView.map(withFrame: frame, camera: camera)
        self.mapView.setMinZoom(1, maxZoom: 20)
        currentMarker?.map = mapView
        mapView.delegate = self
        vwMapContainer.addSubview(mapView)
        intiClusterManager()
    }
    
    func intiClusterManager() {
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = ClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Generate and add random items to the cluster manager.
        generateClusterItems()
        
        // Call cluster() after items have been added to perform the clustering and rendering on map.
        clusterManager.cluster()
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    
    // MARK:- Util
    // MARK:-
    
    override func updateUI() {
        lblDirection.text = "nearby_direction".localized()
        let strTitle = customHeader ?? currentPlace?.name ?? "nearby_map_title".localized()
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = strTitle
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
//        self.title = strTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
    }
    
    func showInfoView()
    {
        updateInfoView()
        UIView.animate(withDuration: 0.33, animations: {
            self.vwOverlay.alpha = 1
            self.cstBottoom.constant = 0
            self.view.layoutIfNeeded()
        }) { (isComplete) in
            UIView.animate(withDuration: 0.33) {
                self.cstCurrent.constant = 8 + self.vwOverlay.bounds.size.height
            }
        }
    }
    
    func closeInfoView()
    {
        UIView.animate(withDuration: 0.33, animations: {
            self.vwOverlay.alpha = 0
            self.cstBottoom.constant = -1 * self.vwOverlay.bounds.size.height
            self.view.layoutIfNeeded()
        }) { (isComplete) in
            UIView.animate(withDuration: 0.33) {
                self.cstCurrent.constant = 16
            }
        }
    }
    
    func updateInfoView()
    {
        if (listCurrentPlace?.count ?? 0) <= currentIndex - 1 {
            return
        }

        lblAmount.isHidden = false
        lblAmount.text = "\(currentIndex + 1)/\(listCurrentPlace?.count ?? 0)"
        if let item = listCurrentPlace?[currentIndex]
        {
            currentPlace = item.place
        }
        
        let strTitle = customHeader ?? currentPlace?.name ?? "nearby_map_title".localized()
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = strTitle
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
//        self.title = strTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        
        vwLeft.isHidden = false
        vwRight.isHidden = false
        if currentIndex == 0 {
            vwLeft.isHidden = true
        } else if (currentIndex + 1 == listCurrentPlace?.count ?? 0){
            vwRight.isHidden = true
        }
        
        if (listCurrentPlace?.count ?? 0) <= 1 {
            vwRight.isHidden = true
            lblAmount.isHidden = true
        }
    }
    
    // MARK:- Event
    // MARK:- Click
    
    @IBAction func clickImage(_ sender: Any) {
        if campaigns.count <= currentIndex { return }
        if let reference_code = currentPlace?.reference_code,
            let id = BuzzebeesConvert.IntFromObjectNull(reference_code as AnyObject)
        {
            let campaign = BzbsCampaign()
            campaign.ID = id
            GotoPage.gotoCampaignDetail(self.navigationController!, campaign: campaign, target: self)
        }
    }
    
    @IBAction func clickCurrentPosition(_ sender: Any) {
        guard let marker = currentMarker else { return  }
        let camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: mapView.camera.zoom)
        mapView.animate(with: GMSCameraUpdate.setCamera(camera))
    }
    
    @IBAction func clickCloseInfo(_ sender: Any) {
        closeInfoView()
        currentPlace = nil
    }
    
    @IBAction func clickDirection(_ sender: Any) {
        if let place = currentPlace
        {
            let webStrUrl = "https://maps.google.com/?q=\(place.latitude!),\(place.longitude!)"
            if let strURl = webStrUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
                let url = URL(string: strURl)
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                
            }
        }
    }
    
    @IBAction func clickLeft(_ sender: Any) {
        if let list = listCurrentPlace
        {
            if currentIndex <= 0 {
                return
            }
            if list.count > (currentIndex - 1) {
                currentIndex -= 1
                let itemWidth = vwPlace.bounds.size.width
                scrollView.setContentOffset(CGPoint(x: itemWidth * CGFloat(currentIndex), y: 0), animated: true)
                updateInfoView()
            }
        }
    }
    
    @IBAction func clickRight(_ sender: Any) {
        if let list = listCurrentPlace
        {
            if (currentIndex + 1) > list.count { return }
            if list.count > (currentIndex + 1) {
                currentIndex += 1
                let itemWidth = vwPlace.bounds.size.width
                scrollView.setContentOffset(CGPoint(x: itemWidth * CGFloat(currentIndex), y: 0), animated: true)
                updateInfoView()
            }
        }
    }
    
    
    // MARK: - Private
    /// Randomly generates cluster items within some extent of the camera and adds them to the
    /// cluster manager.
    private func generateClusterItems() {
        
        let sortedcampaigns = campaigns.sorted { $0.name < $1.name }
        campaigns = sortedcampaigns
        
        for item in sortedcampaigns
        {
            if let first = item.places.first,
                let id = item.ID
            {
                //JU: wordaround campaign id as reference code
                first.reference_code = "\(id)"
                places.append(first)
            }
        }
        
        for place in places
        {
            let lat = place.latitude!
            let lng = place.longitude!
            let name = place.name ?? ""
            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name, place: place)
            
            clusterManager.add(item)
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        vwBtnImv.isHidden = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        vwBtnImv.isHidden = false
        let width = scrollView.frame.size.width
        let index = Int(scrollView.contentOffset.x / width)
        currentIndex = index
        updateInfoView()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        vwBtnImv.isHidden = false
        let width = scrollView.frame.size.width
        let index = Int(scrollView.contentOffset.x / width)
        currentIndex = index
        updateInfoView()
    }
}

// MARK:- Extension
// MARK:- GMSMapViewDelegate
extension MapsViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker == currentMarker {
            currentPlace = nil
        } else {
            if let place = marker.userData as? BzbsPlace
            {
                currentPlace = place
                mapView.animate(with: GMSCameraUpdate.setTarget(marker.position))
            }
        }
        
        return true
    }
    
}
// MARK: - GMUClusterManagerDelegate

extension MapsViewController: GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        if let items = [clusterItem] as? [POIItem]{
            updateDetail(items, position: clusterItem.position)
        }
        return true
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        if let items = cluster.items as? [POIItem]{
            updateDetail(items, position: cluster.position)
        }
        return true
    }
    
    func updateDetail(_ items:[POIItem], position:CLLocationCoordinate2D)
    {
        listCurrentPlace = items
        for vw in itemView
        {
            vw.removeFromSuperview()
        }
        itemView.removeAll()
        
        for item in items {
            let vw = CellPlaceDetail.getClassObject()
            vw.frame = vwPlace.bounds
            vw.layoutIfNeeded()
            if let place = item.place {
                let campaign = campaigns.first { (tmp) -> Bool in
                    if let id = tmp.ID {
                        return "\(id)" == place.reference_code
                    }
                    return false
                }
                var distance:Double = 0
                
                if let currentCoordiante = self.currentMarker?.position,
                    let lat = place.location?.latitude,
                    let lon = place.location?.longitude
                {
                    let currentLocation = CLLocation(latitude: currentCoordiante.latitude, longitude: currentCoordiante.longitude)
                    let location = CLLocation(latitude: lat, longitude: lon)
                    distance = currentLocation.distance(from: location) / 1000
                }
                
                vw.updateInfoView(name: campaign?.name ??  place.name ?? "-",
                                  agencyName:place.name ?? "-",
                                  locationAgencyId: place.locationId ?? 0,
                                  distance: distance)
            }
            itemView.append(vw)
        }
        
        let width = vwPlace.bounds.size.width
        let height = vwPlace.bounds.size.height
        var i:CGFloat = 0
        for item in itemView{
            item.frame = CGRect(x: width * i, y: 0, width: width, height: height)
            containerView.addSubview(item)
            i += 1
        }
        
        currentIndex = 0
        lblAmount.text = "1/\(listCurrentPlace?.count ?? 0)"
        scrollView.contentSize = CGSize(width: width * CGFloat(items.count), height: height)
        scrollView.isPagingEnabled = true
        if itemView.count <= 1 {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        cstContainerViewWidth.constant = width * CGFloat(items.count)
        containerView.layoutIfNeeded()
        
        var zoom = mapView.camera.zoom
        if zoom < 18 {
            zoom += 1
        }
        let newCamera = GMSCameraPosition.camera(withTarget: position,
                                                 zoom: zoom)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.animate(with: update)
    }
    
    func clusterManager(clusterManager: GMUClusterManager
        , didTapCluster cluster: GMUCluster) {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.animate(with: update)
    }
    
    
}

// MARK:- Extension GMUClusterRendererDelegate
extension MapsViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        
        if let _ = marker.userData as? GMUStaticCluster{
            
        }else{
            
            marker.icon = UIImage(named: "img_pin_unactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            
            if let item = marker.userData as? POIItem {
                
                if let current = currentPlace {
                    if (current.latitude == item.place?.latitude) && (current.longitude == item.place?.longitude) {
                        marker.icon = UIImage(named: "img_pin_active", in: Bzbs.shared.currentBundle, compatibleWith: nil)
                    }
                }
            }
        }
    }
    
}

//// MARK:- Extension UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
//extension MapsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
//{
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return listCurrentPlace?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        if let item = listCurrentPlace?[indexPath.row] {
//            currentPlace = item.place
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPlaceDetail", for: indexPath) as! CellPlaceDetail
//            if let place = currentPlace {
//                let campaign = campaigns.first { (tmp) -> Bool in
//                    return tmp.locationAgencyId == place.locationId
//                }
//                cell.updateInfoView(name: campaign?.name ??  place.name ?? "-",
//                                    agencyName:place.name ?? "-",
//                                    locationAgencyId: place.locationId ?? 0,
//                                    location: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
//            }
//            return cell
//        }
//        return UICollectionViewCell()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        currentIndex = indexPath.row
//        lblAmount.text = "\(currentIndex! + 1)/\(listCurrentPlace?.count ?? 0)"
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let height = collectionView.bounds.size.height * 0.9
//        let width = collectionView.frame.size.width * 0.9
//        print(height, width)
//        return CGSize(width: width, height: height)
//    }
//}
