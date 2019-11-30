# Sample iOS application using Clean Architecture and MVVM
iOS Project implemented with Clean Layered Architecture and MVVM. (Can be used as Template project by replacing item name “Movie”)

Medium post with detail description about this project: https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3

## Architecture concepts used here:
* Clean Layered Architecture https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
* Advanced iOS App Architecture https://www.raywenderlich.com/8477-introducing-advanced-ios-app-architecture
* MVVM
* Data Binding
* Dependency Injection
* SwiftUI and UKit view implementations by reusing same ViewModel (at least Xcode 11 required)

## Includes:
* Unit Tests for Use Cases(Domain Layer), ViewModels(Presentation Layer), NetworkService(Infrastructure Layer)
* UI test with XCUITests
* Size Classes in Detail view
* SwiftUI example, demostration that presentation layer does not change, only UI (at least Xcode 11 required)


## Requirements: 
* Xcode Version 10.2.1+  Swift 5.0+

# How to use app:
To search a movie, write a name of a movie inside searchbar and hit search button. There are two network calls: request movies and request poster images. Every successful search query is stored persistently.
