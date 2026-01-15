import CoreData
import Foundation

class FeedDAO {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchPosts() throws -> [PostEntity] {
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return try context.fetch(request)
    }
    
    func savePosts(_ dtos: [PostDTO]) async {
        await context.perform {
            for dto in dtos {
                let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "postId == %@", dto.post_id)
                
                let entity: PostEntity
                if let existing = try? self.context.fetch(fetchRequest).first {
                    entity = existing
                } else {
                    entity = PostEntity(context: self.context)
                    entity.postId = dto.post_id
                }
                
                entity.userName = dto.user_name
                entity.userImageURL = dto.user_image
                entity.postImageURL = dto.post_image
                entity.likeCount = Int64(dto.like_count)
                entity.likedByUser = dto.liked_by_user
                entity.updatedAt = Date()
            }
            try? self.context.save()
        }
    }
    
    func updateLikeState(postId: String, isLiked: Bool) {
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "postId == %@", postId)
        
        if let post = try? context.fetch(request).first {
            post.likedByUser = isLiked
            post.likeCount += isLiked ? 1 : -1
            try? context.save()
        }
    }
}

class ReelsDAO {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchReels() throws -> [ReelEntity] {
        let request: NSFetchRequest<ReelEntity> = ReelEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return try context.fetch(request)
    }
    
    func saveReels(_ dtos: [ReelDTO]) async {
        await context.perform {
            for dto in dtos {
                let fetchRequest: NSFetchRequest<ReelEntity> = ReelEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "reelId == %@", dto.reel_id)
                
                let entity: ReelEntity
                if let existing = try? self.context.fetch(fetchRequest).first {
                    entity = existing
                } else {
                    entity = ReelEntity(context: self.context)
                    entity.reelId = dto.reel_id
                }
                
                entity.userName = dto.user_name
                entity.userImageURL = dto.user_image
                entity.reelVideoURL = dto.reel_video
                entity.likeCount = Int64(dto.like_count)
                entity.likedByUser = dto.liked_by_user
                entity.updatedAt = Date()
            }
            try? self.context.save()
        }
    }
    
    func updateLikeState(reelId: String, isLiked: Bool) {
        let request: NSFetchRequest<ReelEntity> = ReelEntity.fetchRequest()
        request.predicate = NSPredicate(format: "reelId == %@", reelId)
        
        if let reel = try? context.fetch(request).first {
            reel.likedByUser = isLiked
            reel.likeCount += isLiked ? 1 : -1
            try? context.save()
        }
    }
}

class PendingActionsDAO {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func enqueueAction(targetId: String, type: String, isLiked: Bool) {
        let action = PendingLikeActionEntity(context: context)
        action.id = UUID()
        action.targetId = targetId
        action.targetType = type
        action.desiredLikedState = isLiked
        action.createdAt = Date()
        action.retryCount = 0
        try? context.save()
    }
    
    func fetchPendingActions() throws -> [PendingLikeActionEntity] {
        let request: NSFetchRequest<PendingLikeActionEntity> = PendingLikeActionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return try context.fetch(request)
    }
    
    func removeAction(_ action: PendingLikeActionEntity) {
        context.delete(action)
        try? context.save()
    }
}


