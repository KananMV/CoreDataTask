import Foundation
import UIKit
import CoreData
class ToDoActionViewModel: ToDoDataViewModel{
    func navigateToSecondViewController(navigationController: UINavigationController) {
        let secondVC = SecondViewController()
        navigationController.pushViewController(secondVC, animated: true)
    }
}
