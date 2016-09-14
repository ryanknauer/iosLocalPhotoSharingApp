//
//  QueueDefinition.swift
//  CameraExample
//
//  Created by Ryan Knauer on 8/21/16.
//  Copyright © 2016 RyanKnauer. All rights reserved.
//

import Foundation



class LLNode<I> {
    var key: I?
    var next: LLNode<I>?
    
    init(_ element: I?){
        self.key = element
    }
}

class Queue<I> {
    var front: LLNode<I>!
    var back: LLNode<I>!

    
    func enQueue(key: I){
        // initialize first node
        if front == nil{
            front = LLNode<I>(key)
            back = front
        }else {
            back.next = LLNode<I>(key)
            back = back.next
        }
    }
    
    func deQueue() -> I?{
        let saveKey = front?.key
        front = front?.next
        return saveKey
    }
    
    func peek() -> I?{
       return front?.key
    }
}