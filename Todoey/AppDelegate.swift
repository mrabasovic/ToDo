
import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {

    let notificationCenter = UNUserNotificationCenter.current()
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { // kod any mozda treba?
        
        //notificationCenter.delegate = self
        
        print("Ovo je putanja do user defaults: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)")
        // samo sto nije documents nego library/preferences
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        let todo = TodoListViewController()
        
        UINavigationBar.appearance().barTintColor = todo.vratiBoju()
        UINavigationBar.appearance().tintColor = todo.vratiBoju()
        
        return true
    }


    
    
    func applicationWillTerminate(_ application: UIApplication) {

        self.saveContext()
    }
    
    // ove dve ispod su za notifikacije
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//            // Override point for customization after application launch.
//            registerForRichNotifications()
//            return true
//        }
    
    func registerForRichNotifications() {

           UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted:Bool, error:Error?) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                if granted {
                    print("Permission granted")
                } else {
                    print("Permission not granted")
                }
            }

            //actions defination
            let action1 = UNNotificationAction(identifier: "action1", title: "Action First", options: [.foreground])
            let action2 = UNNotificationAction(identifier: "action2", title: "Action Second", options: [.foreground])

            let category = UNNotificationCategory(identifier: "actionCategory", actions: [action1,action2], intentIdentifiers: [], options: [])

            UNUserNotificationCenter.current().setNotificationCategories([category])

        }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("Local notification received (tapped, or while app in foreground): \(notification)")
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }



}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

