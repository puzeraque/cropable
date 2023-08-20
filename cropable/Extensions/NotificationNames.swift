import Foundation

extension Notification.Name {
    static let mediaLibraryAccessChanged = Notification.Name(rawValue: "mediaLibraryAccessChanged")
    static let newMediaDidChanged = Notification.Name(rawValue: "newMediaDidChanged")
    static let newMediaCoverAdded = Notification.Name(rawValue: "newMediaCoverAdded")
    static let newAvatarAdded = Notification.Name(rawValue: "newAvatarAdded")
    static let newMediaPostCameraAdded = Notification.Name(rawValue: "newMediaPostCameraAdded")
    static let newCommentMediaAdded = Notification.Name(rawValue: "newCommentMediaAdded")
    static let setSliderValue = Notification.Name(rawValue: "newSliderValue")
    static let videoDone = Notification.Name(rawValue: "videoDone")
    static let videoSaved = Notification.Name(rawValue: "videoSaved")
    static let videoError = Notification.Name(rawValue: "videoError")
    static let multiPhotoSaved = Notification.Name(rawValue: "multiPhotoSaved")
    static let newMediaStartedUploading = Notification.Name(rawValue: "newMediaStartedUploading")
    static let newMediaEndUploading = Notification.Name(rawValue: "newMediaEndUploading")
    
    static let updateUserInfo = Notification.Name(rawValue: "updateUserInfo")
    static let updateUserMedia = Notification.Name(rawValue: "updateUserMedia")
}
