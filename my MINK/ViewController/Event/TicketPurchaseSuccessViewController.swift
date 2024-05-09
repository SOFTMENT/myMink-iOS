//
//  TicketPurchaseSuccessViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 18/05/24.
//


import UIKit
import Lottie
import Firebase

class TicketPurchaseSuccessViewController: UIViewController {
    

    @IBOutlet weak var animationView: LottieAnimationView!
    var ticketModel : TicketModel?
    var ticketsModel : [TicketModel] = []
    override func viewDidLoad() {
        
        
        guard let ticketModel = ticketModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            
            return
        }
        
        
        animationView.loopMode = .loop
        animationView.play()
        
        let batch = Firestore.firestore().batch()
        
        ticketsModel.removeAll()
        
       
            let docucmentRef =  Firestore.firestore().collection("Tickets").document()
            do {
                ticketModel.ticketId = docucmentRef.documentID
                ticketsModel.append(ticketModel)
                try batch.setData(from: ticketModel, forDocument:  docucmentRef)
            }
            catch {
                self.showError(error.localizedDescription)
            }
            
        batch.setData(["eventTicketSold" : FieldValue.increment(Int64(ticketModel.quantity!))], forDocument: Firestore.firestore().collection("Events").document(ticketModel.eventId!),merge: true)
       
        
        
        
        batch.commit { error in
          
            if error == nil {
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   
                }
                

                
            }
            else {
                self.animationView.pause()
                self.showError(error!.localizedDescription)
            }
        }
        
    }
    
    
}
