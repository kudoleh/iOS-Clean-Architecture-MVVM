# Template iOS App using Clean Architecture and MVVM
iOS Project implemented with Clean Architecture and MVVM. (Can be used as Template project by replacing item name “Movie”). **More information in medium post**: <a href="https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3">Medium Post about Clean Architecture + MVVM</a>

![Alt text](README_FILES/CleanArchitecture+MVVM.png?raw=true "Modules Dependencies")

## Layers
* **Domain Layer** = Entities + Use Cases + Repositories Interfaces
* **Data Repositories Layer** = Repositories Implementations + API (Network) + Persistence DB
* **Presentation Layer (MVVM)** = ViewModels + Views

### Dependency Direction
**Presentation Layer -> Domain Layer <- Data Repositories Layer**

## Architecture concepts used here
* Clean Architecture https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
* Advanced iOS App Architecture https://www.raywenderlich.com/8477-introducing-advanced-ios-app-architecture
* MVVM
* Data Binding
* Dependency Injection
* SwiftUI and UKit view implementations by reusing same ViewModel (at least Xcode 11 required)
* CI Pipeline (Travis CI + Fastlane)

## Includes
* Unit Tests for Use Cases(Domain Layer), ViewModels(Presentation Layer), NetworkService(Infrastructure Layer)
* UI test with XCUITests
* Size Classes in Detail view
* SwiftUI example, demostration that presentation layer does not change, only UI (at least Xcode 11 required)


## Requirements
* Xcode Version 11.2.1+  Swift 5.0+

# How to use app:
To search a movie, write a name of a movie inside searchbar and hit search button. There are two network calls: request movies and request poster images. Every successful search query is stored persistently.
