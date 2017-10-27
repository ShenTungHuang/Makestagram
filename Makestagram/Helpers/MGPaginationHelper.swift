//
//  MGPaginationHelper.swift
//  Makestagram
//
//  Created by STH on 2017/7/1.
//  Copyright © 2017年 STH. All rights reserved.
//

import Foundation

protocol MGKeyed {
    var key: String? { get set }
}

class MGPaginationHelper<T: MGKeyed> {
    
    enum MGPaginationState {
        case initial
        case ready
        case loading
        case end
    }
    
    // MARK: - Properties
    let pageSize: UInt // Determines the number of posts that will be on each page
    let serviceMethod: (UInt, String?, @escaping (([T]) -> Void)) -> Void // The service method that will return paginated data
    var state: MGPaginationState = .initial // The current pagination state of the helper
    var lastObjectKey: String? // Firebase uses object keys to determine the last position of the page
    
    // MARK: - Init
    init(pageSize: UInt = 3, serviceMethod: @escaping (UInt, String?, @escaping (([T]) -> Void)) -> Void) {
        self.pageSize = pageSize
        self.serviceMethod = serviceMethod
    }
    
    // use our generic type to enforce that we return type T
    func paginate(completion: @escaping ([T]) -> Void) {
        // switch on our helper's state to determine the behavior of our helper when paginate(completion:) is called
        switch state {
        // make sure that the lastObjectKey is nil use the fallthrough keyword to execute the ready case below
        case .initial:
            lastObjectKey = nil
            fallthrough // fall through to next case (.ready) 
            
        // make sure to change the state to loading and execute our service method to return the paginated data
        case .ready:
            state = .loading
            serviceMethod(pageSize, lastObjectKey) { [unowned self] (objects: [T]) in // use weak/unowned to avoid cyclic reference
                // use the defer keyword to make sure the following code is executed whenever the closure returns
                defer {
                    // If the returned last returned object has a key value, we store that in lastObjectKey to use as a future offset for paginating
                    if let lastObjectKey = objects.last?.key {
                        self.lastObjectKey = lastObjectKey
                    }
                    
                    // We determine if we've paginated through all content because if the number of objects returned is less than the page size, we know that we're only the last page of objects
                    self.state = objects.count < Int(self.pageSize) ? .end : .ready
                }
                
                // If lastObjectKey of the helper doesn't exist, we know that it's the first page of data so we return the data as is
                guard let _ = self.lastObjectKey else {
                    return completion(objects)
                }
                
                // whenever we page with the lastObjectKey, the previous object from the last page is returned
                // Here we need to drop the first object which will be a duplicate post in our timeline
                let newObjects = Array(objects.dropFirst())
                completion(newObjects)
            }
            
        // 10
        case .loading, .end:
            return  
        }
    }
    
    func reloadData(completion: @escaping ([T]) -> Void) {
        state = .initial
        
        paginate(completion: completion)
    }
    
}
