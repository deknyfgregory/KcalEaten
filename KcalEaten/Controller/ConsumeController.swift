//
//  ConsumeController.swift
//  KcalEaten
//
//  Created by Gregory De knyf on 19/03/2019.
//  Copyright © 2019 Gregory De knyf. All rights reserved.
//

import UIKit

//---------------------------
//MARK: - Outlets & variables
//---------------------------
class ConsumeController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    private var _consumeGroupedByDate = [[Consume]]()
    private var _consumesFromCoreData: [Consume]!
    private let _coreDataService = CoreDataHelper()
    
}

//---------------
//MARK: - Methods
//---------------
extension ConsumeController {
    private func attemptToAssembleGroupedConsume() {

        _consumeGroupedByDate.removeAll()

        //Groupe consume by date
        let groupedConsume = Dictionary(grouping: _consumesFromCoreData) { (element) -> Date in
            guard let elementDate = element.date else { return Date() }
            //Formatting the date in medium version and conversion to a string
            let dateString = elementDate.toString()
            //Creation of a medium date from the string
            let date = dateString.toDate()
            return date
        }

        //Sorte consume by date; key == date
        let sortedKeys = groupedConsume.keys.sorted(by: >)
        sortedKeys.forEach { (key) in
            let values = groupedConsume[key]
            _consumeGroupedByDate.append(values ?? [])
        }
    }
    
    private func populateTableView() {
        _consumesFromCoreData = try? _coreDataService.fetchConsume()
        attemptToAssembleGroupedConsume()
        tableview.reloadData()
    }
}

//------------------
//MARK: - Life Cycle
//------------------
extension ConsumeController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateTableView()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.topItem?.title = "Détails du jour"
    }
}

//---------------------------------------
//MARK: - Tableview dataSource & delegate
//---------------------------------------
extension ConsumeController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _consumeGroupedByDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //Creating cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "consumeCell", for: indexPath) as! ConsumeCell

        //Set cell
        cell.setup(dayConsume: _consumeGroupedByDate[indexPath.section])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var products = [ProductObject]()
        _consumeGroupedByDate[indexPath.section].forEach { (consume) in
            if let product = consume.product {
                products.append(product)
            }
        }
        performSegue(withIdentifier: "showConsumeDetails", sender: products)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            _consumeGroupedByDate[indexPath.section].forEach { (consume) in
                try? _coreDataService.delete(consume: consume)
            }
            populateTableView()
        }
    }
}
//------------------------
//MARK: - Navigation
//------------------------
extension ConsumeController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showConsumeDetails" else { return }
        guard let destination = segue.destination as? ShowProductCollectionController else { return }
        destination.product = sender as? [ProductObject]
    }
}
