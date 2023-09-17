import UIKit
import Flutter
import GoogleMaps
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      GMSServices.provideAPIKey("AIzaSyAGNJE2GoZHtxfvfmfXlrIABOQdHX3Yjas")
    //  FirebaseApp.configure()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override   func applicationDidBecomeActive(_ application: UIApplication) {
             print("App is now active mode")
          //   annoyingRuleExample()
             

                // app becomes active
                // this method is called on first launch when app was closed / killed and every time app is reopened or change status from background to foreground (ex. mobile call)
            }
        
        
        
    override func applicationDidEnterBackground(_ application: UIApplication) {
            
            print("App is on Background Mode")


               
            
    //
    //        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(testAPICall), userInfo: nil, repeats: true)
    //       // let timer = Timer(timeInterval: 0.4, repeats: true) { _ in self.testAPICall()}
    //        print(timer)
            
    //        timer2 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(currentlocationmethod), userInfo: nil, repeats: true)
    //       // let timer = Timer(timeInterval: 0.4, repeats: true) { _ in self.testAPICall()}
    //        print(timer2)
    //     //   currentlocationmethod()
    //        doBackgroundTask()
            
        
            }
        
    override func applicationWillEnterForeground(_ application: UIApplication) {
            
            print("App is on Foreground Mode")
            
          //   annoyingRuleExample()
            //currentlocationmethod()
    //        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(currentlocationmethod), userInfo: nil, repeats: true)
    //       // let timer = Timer(timeInterval: 0.4, repeats: true) { _ in self.testAPICall()}
    //        print(timer)


                // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

            }
}


