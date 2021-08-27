# [🇰🇷 Korean ver.] Clean Architecture와 MVVM를 사용한 iOS 앱 템플릿

해당 iOS 프로젝트는 Clean Layered Architecture와 MVVM 방식으로 구현되어있다. ("Movie"라는 아이템 이름으로 해당 템플릿이 사용되었다.) **자세한 정보는 중간 포스트에서 확인해볼 수 있다:** [Medium Post about Clean Architecture + MVVM](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3).



![Alt text](README_FILES/CleanArchitecture+MVVM.png?raw=true "Clean Architecture Layers")



## 계층

- **도메인 계층** = 개체 (Entities) + 유스케이스 (Use Cases) + 레포지토리 인터페이스 부분 (Repositories Interfaces)
- **데이터 레포지토리 계층**: 레포지토리 구현 부분 (Repositories Implementations) + API (네트워크) + 지속되는 DB
-  **프레젠테이션 계층(MVVM)**: 뷰 모델 (View Models) + 뷰 (Views)



### 의존 방향

![Alt text](README_FILES/CleanArchitectureDependencies.png?raw=true "Modules Dependencies")



**주의: 도메인 계층**은 다른 계층의 요소들을 포함할 수 없다. (예시: Presentation - UIKit or SwiftUI or 데이터 계층 - Codable로 매핑)



## 여기에서 사용되는 아키텍처 개념

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



## 포함 요소

* [Unit Tests with Quick and Nimble](https://github.com/kudoleh/iOS-Modular-Architecture/blob/master/DevPods/MoviesSearch/MoviesSearch/Tests/Presentation/MoviesScene/MoviesListViewModelSpec.swift), and [View Unit tests with iOSSnapshotTestCase](https://github.com/kudoleh/iOS-Modular-Architecture/blob/master/DevPods/MoviesSearch/MoviesSearch/Tests/Presentation/MoviesScene/MoviesListViewTests.swift)
* Unit Tests for Use Cases(Domain Layer), ViewModels(Presentation Layer), NetworkService(Infrastructure Layer)
* UI test with XCUITests
* Size Classes and UIStackView in Detail view
* Dark Mode
* SwiftUI example, demostration that presentation layer does not change, only UI (at least Xcode 11 required)
* Pagination



## 네트워킹

만약 레포지토리에 있는 해당 예시에서 네트워킹을 사용하고 싶다면,  [바로가기](https://github.com/kudoleh/SENetworking) 를 참고하면 된다.



## 필수 요소

- Xcode 11.2.1버전 이상, swift 5.0 버전 이상



## 사용 방법

영화를 찾기 위해선 서치바에 이름을 적고 찾기 버튼을 누른다. 

여기서는  영화 요청과 poster image 요청의 두개의 네트워크가 호출된다. 성공된 모든 검색 쿼리는 영구적으로 보존된다.

