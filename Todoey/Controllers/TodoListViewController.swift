
import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let defaults = UserDefaults.standard
    
    
    @IBOutlet weak var naslov: UINavigationItem!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        edit.dozvolaZaObavestenja()
        
        UNUserNotificationCenter.current().delegate = self
        
    }
    
    
    
    let edit = EditViewController()
    var bojaa: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == false {
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .dark
            } else {
                // Fallback on earlier versions
            }
        }
        
        
        bojaa = defaults.string(forKey: "NavBoja") ?? "Siva"
        self.navigationController?.navigationBar.barTintColor = vratiBoju()
        
        naslov.title = defaults.string(forKey: "Ime") ?? "ToDo"
    }
    
    
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goToEdit", sender: self)
    }
    
    
    func vratiBoju() -> UIColor{
        switch bojaa {
        case "Siva":
            return UIColor.gray
        case "Crna":
            return UIColor.black
        case "Zelena":
            return UIColor.green
        case "Ljubicasta":
            return UIColor.purple
        case "Roze":
            return UIColor.systemPink
        case "Zuta":
            return UIColor.yellow
        case "Narandzasta":
            return UIColor.orange
        case "Plava":
            return UIColor.blue
        default:
            return UIColor.gray
        }
    }
    
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    
    // za CEKIRANJE
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        saveItems()

        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    // OVO JE FJA ZA BRISANJE
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            
            saveItems()
            //edit.uspesnoSacuvano()
            edit.obrisanoIzBaze()
        }
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Dodaj novu stavku", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Dodaj", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()
            self.edit.uspesnoSacuvano()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Kreiraj novu stavku"
            textField = alertTextField
            
        }
        
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods
    
    func saveItems() {
        
        do {
          try context.save()
            
        } catch {
           print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    
    
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Item> = Item.fetchRequest()
    
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
          
        }
    }
}



extension TodoListViewController: UNUserNotificationCenterDelegate {

    //for displaying notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        //If you don't want to show notification when app is open, do something here else and make a return here.
        //Even you you don't implement this delegate method, you will not see the notification on the specified controller. So, you have to implement this delegate and make sure the below line execute. i.e. completionHandler.

        completionHandler([.alert, .badge, .sound])
    }

    // For handling tap and user actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        switch response.actionIdentifier {
        case "action1":
            print("Action First Tapped")
        case "action2":
            print("Action Second Tapped")
        default:
            break
        }
        completionHandler()
    }

}






