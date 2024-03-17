import UIKit

protocol StoryboardInstantiable: NSObjectProtocol {
    associatedtype T
    static var defaultFileName: String { get }
    static var defaultIdentifier: String { get }
    static func instantiateViewController(_ bundle: Bundle?, _ identifier: String?) -> T
}

extension StoryboardInstantiable where Self: UIViewController {
    static var defaultFileName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    static var defaultIdentifier: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last! + "Identifier"
    }
    
    static func instantiateViewController(_ bundle: Bundle? = nil, _ identifier: String? = nil) -> Self {
        let fileName = defaultFileName
        let storyboard = UIStoryboard(name: fileName, bundle: bundle)
        
        if let storyboardIdentifier = identifier {
            guard let viewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? Self else {
                fatalError("Cannot instantiate view controller \(Self.self) from storyboard with name \(fileName) using identifier \(storyboardIdentifier)")
            }
            return viewController
        }
        
        guard let initialViewController = storyboard.instantiateInitialViewController() as? Self else {
            
            fatalError("Cannot instantiate initial view controller \(Self.self) from storyboard with name \(fileName)")
        }
        return initialViewController
    }
}
