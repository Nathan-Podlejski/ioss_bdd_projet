//
//  ViewController.swift
//  ToDo2023Moi
//
//  Created by lpiem on 31/01/2023.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    private var items: [Category] = []
    
    private var viewContext: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    //ui menu
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Add", image: UIImage(systemName: "add"), handler: { _ in
                let alertController = UIAlertController(title: "Nouvelle tâche", message: "Ajouter une tache a la liste", preferredStyle: .alert)
                
                alertController.addTextField { textField in
                    textField.placeholder = "Titre"
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                let saveAction = UIAlertAction(title: "Ajouter", style: .default) { [unowned self] _ in
                    guard let textField = alertController.textFields?.first else {
                        return
                    }
                    
                    self.createItem(name: textField.text!)
                    self.items = self.fetchItems()
                    self.tableView.reloadData()
                }
                    
                alertController.addAction(saveAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", image: nil, primaryAction: nil, menu: sortMenu)

        items = fetchItems()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
                
    }

    //MARK: - CoreData Methods
    
    private func fetchItems(searchText: String? = nil) -> [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        switch sortType {
        case .name:
            let titleSortDescriptor = NSSortDescriptor(keyPath: \Category.name, ascending: true)
            
            fetchRequest.sortDescriptors = [titleSortDescriptor]
        case .date:
            let dateSortDescriptor = NSSortDescriptor(keyPath: \Category.creationDate, ascending: false)
            
            fetchRequest.sortDescriptors = [dateSortDescriptor]
        case .dateModif:
            let dateSortDescriptor = NSSortDescriptor(keyPath: \Category.modifDate, ascending: false)
            
            fetchRequest.sortDescriptors = [dateSortDescriptor]
        }
        
        
        if let searchText, !searchText.isEmpty {
            let predicate = NSPredicate(format: "%K contains[cd] %@", argumentArray: [#keyPath(Category.name), searchText])
            fetchRequest.predicate = predicate
        }
        
        do {
            return try viewContext.fetch(fetchRequest)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func createItem(name: String) {
        let newItem = Category(context: viewContext)
        newItem.name = name
        newItem.creationDate = Date()
        newItem.modifDate = Date()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.creationDate?.formatted()
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
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        items = fetchItems(searchText: searchText)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ( segue.identifier == "PlaceSegue") {
            
            let navVC = segue.destination as! UINavigationController
            let destView = navVC.topViewController as! PlaceViewController
            destView.category = items[tableView.indexPath(for: sender as! UITableViewCell)!.row]
        }
    }
    
}
