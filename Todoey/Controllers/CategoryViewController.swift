
import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    @IBOutlet weak var naslov: UINavigationItem!
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let edit = EditViewController()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        posaljiNotifikaciju()
        
        edit.dozvolaZaObavestenja()
        
        print("Ovde je baza\(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        // samo sto ne ides na kraju u documents nego u library pa onda application support
        
        
        
    }
    
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
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: vratiBojuSlova(bojaBara: vratiBoju())]
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
    
    func vratiBojuSlova(bojaBara: UIColor) -> UIColor{
        if bojaBara == .black{
            return .white
        }else{
            return .black
        }
    }
    
    func posaljiNotifikaciju(){
       let center = UNUserNotificationCenter.current()
       center.requestAuthorization(options: [.alert, .sound]) { (dozvolio, error) in
           let content = UNMutableNotificationContent()
           content.title = "Podsetnik"
           content.body = "Da li ste uradili sve sto ste planirali danas?"

           let date = Date().addingTimeInterval(8)
           let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
           let trigger =  UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

           let uuidString = UUID().uuidString
           let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

           center.add(request) { (error) in
               // check for error
           }
       }
   }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
        
    }

    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Greska kod cuvanja kategorije \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categories = try context.fetch(request)
        } catch {
            print("Greska kod ucitavanja kategorija \(error)")
        }
       
        tableView.reloadData()
        
    }
    
    
    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Dodaj novu kategoriju", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Dodaj", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategories()
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Dodaj novu kategoriju"
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    

    
    
    
}
