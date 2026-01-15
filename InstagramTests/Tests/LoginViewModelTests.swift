import XCTest
@testable import Instagram

class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
        // Reset app storage for test (mocking AppStorage is tricky in Unit Tests, 
        // usually need a wrapper, but for this simple check we assume default)
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
    }
    
    func testLoginSuccess() {
        viewModel.email = "user@example.com"
        viewModel.password = "password123"
        
        viewModel.login()
        
        XCTAssertTrue(viewModel.isLoggedIn)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoginFailure() {
        viewModel.email = "wrong"
        viewModel.password = "wrong"
        
        viewModel.login()
        
        XCTAssertFalse(viewModel.isLoggedIn)
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Invalid credentials. Please try again.")
    }
}


