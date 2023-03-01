//
//  ViewController.swift
//  ToDo2023Moi
//
//  Created by lpiem on 31/01/2023.
//

import UIKit
import CoreData

class PlaceViewController: UITableViewController {
    
    public var category: Category?
    private var items: [Places] = []
    
    private var viewContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = category!.name

        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        items = fetchItems()
        tableView.reloadData()
    }
    

    //MARK: - CoreData Methods
    
    private func fetchItems(searchText: String? = nil) -> [Places] {
        let fetchRequest: NSFetchRequest<Places> = Places.fetchRequest()
        
        let dateSortDescriptor = NSSortDescriptor(keyPath: \Places.creationDate, ascending: false)
        let titleSortDescriptor = NSSortDescriptor(keyPath: \Places.name, ascending: false)
        
        fetchRequest.sortDescriptors = [dateSortDescriptor, titleSortDescriptor]
//
        let predicate = NSPredicate(format: "%K = %@",
                                    argumentArray: [ #keyPath(Places.categoryLinked), category!])

        fetchRequest.predicate = predicate
        
        if let searchText, !searchText.isEmpty {
            let predicate2 = NSPredicate(format: "%K contains[cd] %@", argumentArray: [#keyPath(Places.name), searchText])
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        }

        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func createItem(name: String) {
        let newItem = Places(context: viewContext)
        newItem.name = name
        newItem.creationDate = Date()
        newItem.modificationDate = Date()
        newItem.categoryLinked = category
        newItem.isFavorite = false
        
        saveContext()
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    // MARK: - UITableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPlace", for: indexPath) as! PlaceCellView
        let item = items[indexPath.row]

        if(item.image != nil) {
            DispatchQueue.main.async {
                cell.img.image = UIImage(data: item.image!)
            }
        }
        else {
            cell.img.image = nil
        }

        cell.textLabel?.text = " "
        cell.nomPlace.text = item.name
        cell.descriptionPlace.text = item.descripionCity
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let item = items[indexPath.row]
        
        viewContext.delete(item)
        saveContext()
        
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK : - User Interactions
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addPlaceSegue") {
            let destView = segue.destination as! AddPlaceViewController
            destView.category = self.category
        }
        if(segue.identifier == "detailSegue") {
            let destView = segue.destination as! DetailPlaceViewController
            destView.place = items[tableView.indexPath(for: sender as! UITableViewCell)!.row]
        }
        
    }
}

extension PlaceViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        items = fetchItems(searchText: searchText)
        tableView.reloadData()
    }
    

    
}
