import XCTest
import CoreData
@testable import Instagram

class FeedRepositoryTests: XCTestCase {
    var repository: FeedRepository!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        // Use in-memory stack
        coreDataStack = CoreDataStack(inMemory: true)
        let dao = FeedDAO(context: coreDataStack.context)
        // We can pass a mock API client here if we want to test network logic,
        // but let's test the Offline fallback logic or DB logic.
        repository = FeedRepository(dao: dao)
    }
    
    func testSaveAndFetchPosts() async throws {
        let dto = PostDTO(post_id: "1", user_name: "User", user_image: "", post_image: "", like_count: 10, liked_by_user: false)
        let dao = FeedDAO(context: coreDataStack.context)
        
        await dao.savePosts([dto])
        
        let posts = try dao.fetchPosts()
        XCTAssertEqual(posts.count, 1)
        XCTAssertEqual(posts.first?.postId, "1")
    }
    
    func testOptimisticLike() {
        // Setup initial post
        let context = coreDataStack.context
        let post = PostEntity(context: context)
        post.postId = "p1"
        post.likedByUser = false
        post.likeCount = 10
        try? context.save()
        
        let dao = FeedDAO(context: context)
        dao.updateLikeState(postId: "p1", isLiked: true)
        
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        let fetchedPost = try? context.fetch(fetchRequest).first
        
        XCTAssertEqual(fetchedPost?.likedByUser, true)
        XCTAssertEqual(fetchedPost?.likeCount, 11)
    }
}


