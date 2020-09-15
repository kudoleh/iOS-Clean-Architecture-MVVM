
# Template iOS App using Clean Architecture and MVVM &nbsp; [![CI](https://img.shields.io/travis/kudoleh/iOS-Clean-Architecture-MVVM)](https://travis-ci.com/github/kudoleh/iOS-Clean-Architecture-MVVM)

iOS Project implemented with Clean Layered Architecture and MVVM. (Can be used as Template project by replacing item name “Movie”). **More information in medium post**: <a href="https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3">Medium Post about Clean Architecture + MVVM</a>


![Alt text](README_FILES/CleanArchitecture+MVVM.png?raw=true "Clean Architecture Layers")

## Layers
* **Domain Layer** = Entities + Use Cases + Repositories Interfaces
* **Data Repositories Layer** = Repositories Implementations + API (Network) + Persistence DB
* **Presentation Layer (MVVM)** = ViewModels + Views

### Dependency Direction
![Alt text](README_FILES/CleanArchitectureDependencies.png?raw=true "Modules Dependencies")

**Note:** **Domain Layer** should not include anything from other layers(e.g Presentation — UIKit or SwiftUI or Data Layer — Mapping Codable)

## Architecture concepts used here
* Clean Architecture https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
* Advanced iOS App Architecture https://www.raywenderlich.com/8477-introducing-advanced-ios-app-architecture
* [MVVM](ExampleMVVM/Presentation/MoviesScene/MoviesQueriesList) 
* Data Binding using [Observable](ExampleMVVM/Presentation/Utils/Observable.swift) without 3rd party libraries 
* [Dependency Injection](ExampleMVVM/Application/DIContainer/AppDIContainer.swift)
* [Flow Coordinator](ExampleMVVM/Presentation/MoviesScene/Flows/MoviesSearchFlowCoordinator.swift)
* [Data Transfer Object (DTO)](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Data/Network/DataMapping/MoviesResponseDTO%2BMapping.swift)
* [Response Data Caching](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/master/ExampleMVVM/Data/Repositories/DefaultMoviesRepository.swift)
* [ViewController Lifecycle Behavior](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/3c47e8a4b9ae5dfce36f746242d1f40b6829079d/ExampleMVVM/Presentation/Utils/Extensions/UIViewController%2BAddBehaviors.swift#L7)
* [SwiftUI and UIKit view](ExampleMVVM/Presentation/MoviesScene/MoviesQueriesList/View/SwiftUI/MoviesQueryListView.swift) implementations by reusing same [ViewModel](ExampleMVVM/Presentation/MoviesScene/MoviesQueriesList/ViewModel/MoviesQueryListViewModel.swift) (at least Xcode 11 required)
* Error handling examples: in [ViewModel](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/201de7759e2d5634e3bb4b5ad524c4242c62b306/ExampleMVVM/Presentation/MoviesScene/MoviesList/ViewModel/MoviesListViewModel.swift#L116), in [Networking](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/blob/201de7759e2d5634e3bb4b5ad524c4242c62b306/ExampleMVVM/Infrastructure/Network/NetworkService.swift#L84)
* CI Pipeline ([Travis CI + Fastlane](.travis.yml))
 
## Includes
* [Unit Tests with Quick and Nimble](https://github.com/kudoleh/iOS-Modular-Architecture/blob/master/DevPods/MoviesSearch/MoviesSearch/Tests/Presentation/MoviesScene/MoviesListViewModelSpec.swift), and [View Unit tests with iOSSnapshotTestCase](https://github.com/kudoleh/iOS-Modular-Architecture/blob/master/DevPods/MoviesSearch/MoviesSearch/Tests/Presentation/MoviesScene/MoviesListViewTests.swift)
* Unit Tests for Use Cases(Domain Layer), ViewModels(Presentation Layer), NetworkService(Infrastructure Layer)
* UI test with XCUITests
* Size Classes and UIStackView in Detail view
* Dark Mode
* SwiftUI example, demostration that presentation layer does not change, only UI (at least Xcode 11 required)
* Pagination

## Networking
If you would like to use Networking from this example project as repo I made it availabe [here](https://github.com/kudoleh/SENetworking)


## Requirements
* Xcode Version 11.2.1+  Swift 5.0+

# How to use app
To search a movie, write a name of a movie inside searchbar and hit search button. There are two network calls: request movies and request poster images. Every successful search query is stored persistently.
