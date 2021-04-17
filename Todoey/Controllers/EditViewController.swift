
import UIKit
import UserNotifications



class EditViewController: UIViewController, UIFontPickerViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    let defaults = UserDefaults.standard
    
    
    // broj kolona podataka za picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // broj redova podataka
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
      }
      
      // ova fja u pickeru prikazuje vrednosti iz naseg niza
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
          return pickerData[row]
      }
    
    @IBOutlet weak var picker: UIPickerView!
    
    
    var ime: String = ""
    
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
            
        if #available(iOS 12.0, *) {
            scheduleGroupedNotifications()
        } else {
            // Fallback on earlier versions
        }
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        pickerData = ["Siva", "Crna", "Zelena", "Ljubicasta", "Roze", "Zuta", "Narandzasta", "Plava"]
        
    }
    
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
    }
    
    
    var izabranaBoja: String = ""
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        izabranaBoja = pickerData[row] as String
          
     }
    
    
    func vratiBoju() -> UIColor{
        switch izabranaBoja {
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
    
    func dozvolaZaObavestenja(){
        // Ask for Notification Permissions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    // Handle error or not granted scenario
                }
            }
        }
    }
    
    
    @IBOutlet weak var darkswitch: UISwitch!
    @IBOutlet weak var txtIme: UITextField!
    
    let userDefaults = UserDefaults()
    
    
    @IBAction func dark(_ sender: UISwitch) {
        let isDarkMode = userDefaults.bool(forKey: "isDarkMode")
            if isDarkMode == true {
                UserDefaults.standard.set(false, forKey: "isDarkMode")  // Set the state
            }
            else {
                UserDefaults.standard.set(true, forKey: "isDarkMode")  // Set the state
            }
    }
    
    
    
    
    func uspesnoSacuvano() {

        let content = UNMutableNotificationContent()
        let requestIdentifier = "uspehSacuvano"

        content.badge = 1
        content.title = "Uspeh!"
        
        content.body = "Uspesno dodato u bazu."
        content.categoryIdentifier = "actionCategory"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)

        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in

            if error != nil {
                print(error?.localizedDescription ?? "nepoznat error")
            }
            print("Notification Register Success")
        }
    }
    
    
    func obrisanoIzBaze() {

        let content = UNMutableNotificationContent()
        let requestIdentifier = "uspehObrisano"

        content.badge = 1
        content.title = "Obrisano!"
        
        content.body = "Uspesno obrisano iz baze."
        content.categoryIdentifier = "actionCategory"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in

            if error != nil {
                print(error?.localizedDescription ?? "nepoznat error")
            }
            print("Notification Register Success")
        }
    }
    
    @IBAction func xPritisnut(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func sacuvajPritisnut(_ sender: Any) {

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (dozvolio, error) in
            let content = UNMutableNotificationContent()
            content.title = "Uspeh"
            content.body = "Sacuvano u bazu"

            let date = Date().addingTimeInterval(1)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let trigger =  UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

            center.add(request) { (error) in
                // check for error
            }
        }
       
        
        defaults.setValue(txtIme.text, forKey: "Ime")
        defaults.setValue(izabranaBoja, forKey: "NavBoja")
        
    }
    
    
    
}


@available(iOS 12.0, *)
func scheduleGroupedNotifications() {
    for i in 1...6 {
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.sound = UNNotificationSound.default

        if i % 2 == 0 {
            notificationContent.title = "Budite produktivni"
            notificationContent.body = "Ostvarite sve ciljeve!"
            notificationContent.threadIdentifier = "prva"
            notificationContent.summaryArgument = "prva1"
        } else {
            notificationContent.title = "Pobedite sebe!"
            notificationContent.body = "Dokazite sebi da to mozete!"
            notificationContent.threadIdentifier = "druga"
            notificationContent.summaryArgument = "druga2"
        }

        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        // Schedule the notification.
        let request = UNNotificationRequest(identifier: "\(i)FiveSecond", content: notificationContent, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error: Error?) in
            if let theError = error {
                print(theError)
            }
        }
    }
}



extension EditViewController: UNUserNotificationCenterDelegate {

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



