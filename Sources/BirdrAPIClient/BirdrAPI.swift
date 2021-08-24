import Foundation

public struct BirdrAPI {

    // APIs ----------------------------- /
    public var image: BirdrImageAPI
    public var spotting: BirdrSpottingAPI
    // --------------------------------- /
    
    public var context: BirdrAPIContext {
        didSet {
            // If we change the main context, change all the contexts below as well
            self.image.context = self.context
            self.spotting.context = self.context
        }
    }
    
    public init(
        context: BirdrAPIContext = .init()
    ) {
        self.context = context
        self.image = .init(context: context)
        self.spotting = .init(context: context)
    }
}
