//
//  ViewController.swift
//  ToDo2023Moi
//
//  Created by lpiem on 31/01/2023.
//

import UIKit
import CoreData

class PlaceViewController: UITableViewController {
    
    //ui menu
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Add", image: UIImage(systemName: "add"), handler: { _ in
                self.performSegue(withIdentifier: "addPlaceSegue", sender: nil)
            })
            ,
            UIAction(title: "Sort by name", image: nil, handler: { (_) in
                self.sortType = .name
                self.items = self.fetchItems(searchText: nil)
                self.tableView.reloadData()
            }),
            UIAction(title: "Sort by creation", image: nil, handler: { (_) in
                self.sortType = .date
                self.items = self.fetchItems(searchText: nil)
                self.tableView.reloadData()
            }),
            UIAction(title: "Sort by modif", image: nil, handler: { (_) in
                self.sortType = .dateModif
                self.items = self.fetchItems(searchText: nil)
                self.tableView.reloadData()
            })
        ]
    }

    var sortMenu: UIMenu {
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    enum sort {
        case name
        case date
        case dateModif
    }
    
    private var sortType: sort = .name

    
    public var category: Category?
    private var items: [Places] = []
    
    private var viewContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = category!.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", image: nil, primaryAction: nil, menu: sortMenu)

        
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
        
        switch sortType {
        case .name:
            let titleSortDescriptor = NSSortDescriptor(keyPath: \Places.name, ascending: true)
            
            fetchRequest.sortDescriptors = [titleSortDescriptor]
        case .date:
            let dateSortDescriptor = NSSortDescriptor(keyPath: \Places.creationDate, ascending: false)
            
            fetchRequest.sortDescriptors = [dateSortDescriptor]
        case .dateModif:
            let dateSortDescriptor = NSSortDescriptor(keyPath: \Places.modificationDate, ascending: false)
            
            fetchRequest.sortDescriptors = [dateSortDescriptor]
        }
        
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

        cell.img.image = nil
        
        if(item.image != nil) {
            DispatchQueue.main.async {
                cell.img.image = UIImage(data: item.image!)
            }
        }
        else {
            
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

