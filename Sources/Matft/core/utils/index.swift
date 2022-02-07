//
//  index.swift
//  
//
//  Created by Junnosuke Kado on 2022/02/06.
//

import Foundation


/// Get a positive index from a given index
/// - Parameters:
///   - index: An index. Negative index will be converted into positive one as return value
///   - axissize: The axis size of a given index
///   - axis: An axis
/// - Returns: A positive index
internal func get_positive_index(_ index: Int, axissize: Int, axis: Int) -> Int{
    let ret_index = index >= 0 ? index : index + axissize
    precondition(0 <= ret_index && ret_index < axissize, "\(index) is out of bounds for axis \(axis) with \(axissize)")
    
    return ret_index
}


/// Get a positive axis from a given axis
/// - Parameters:
///   - axis: An axis index. Negative axis will be converted into positive one as return value
///   - ndim: The dimension
/// - Returns: A positive axis
internal func get_positive_axis(_ axis: Int, ndim: Int) -> Int{
    let ret_axis = axis >= 0 ? axis : axis + ndim
    precondition(0 <= ret_axis && ret_axis < ndim, "\(axis) is out of bounds")
    
    return ret_axis
}

/// Index sequence for a flatten array
internal struct FlattenIndSequence: Sequence{
    let shape: [Int]
    let strides: [Int]
    
    
    /// Initialization
    /// - Parameters:
    ///   - shape: A shape array
    ///   - strides: A strides array
    public init(shape: inout [Int], strides: inout [Int]){
        assert(!shape.isEmpty && !strides.isEmpty, "shape and strides must not be empty")
        assert(shape.count == strides.count, "shape and strides must be samesize")
        
        self.shape = shape
        self.strides = strides
    }
    
    /// Generate an iterator
    /// - Returns: Iterator on index for a flatten array
    func makeIterator() -> FlattenIndSequenceIterator {
        return FlattenIndSequenceIterator(self)
    }
}

/// Iterator on index for a flatten array from a given shape and strides
internal struct FlattenIndSequenceIterator: IteratorProtocol{
    private let flattenIndSeq: FlattenIndSequence
    public var strides: [Int]{
        return self.flattenIndSeq.strides
    }
    public var shape: [Int]{
        return self.flattenIndSeq.shape
    }
    
    public var indicesOfAxes: [Int]
    public var flattenIndex: Int = 0
    public var upaxis: Int = -1 //indicates which axis will be counted up
    
    public init(_ flattenIndSeq: FlattenIndSequence){
        self.flattenIndSeq = flattenIndSeq
        
        self.indicesOfAxes = Array(repeating: 0, count: flattenIndSeq.shape.count)
        self.flattenIndex = 0
        self.upaxis = -1
    }
    
    mutating func next() -> (flattenIndex: Int, indices: [Int])? {
        if self.upaxis == -1{// flattenIndex = 0, indicesOfAxes = [0,...,0] must be returned
            self.upaxis = self.shape.count - 1
            return (self.flattenIndex, self.indicesOfAxes)
        }
        
        for axis in (0..<self.indicesOfAxes.count).reversed(){
            if self.indicesOfAxes[axis] < self.shape[axis] - 1{
                self.indicesOfAxes[axis] += 1
                self.upaxis = axis
                
                self.flattenIndex += self.strides[axis]
                
                return (self.flattenIndex, self.indicesOfAxes)
            }
            else{// next axis
                self.indicesOfAxes[axis] = 0

                // reset flattenIndex
                self.flattenIndex -= self.strides[axis]*(self.shape[axis] - 1)
            }
        }
        
        return nil
        
    }
}


/// Index sequence for a flatten array
/// Note that this sequence is for print function of leave out version
internal struct FlattenLOIndSequence: Sequence{
    let shape: [Int]
    let strides: [Int]
    let storedSize: Int
    
    public init(storedSize: Int, shape: inout [Int], strides: inout [Int]){
        assert(!shape.isEmpty && !strides.isEmpty, "shape and strides must not be empty")
        assert(shape.count == strides.count, "shape and strides must be samesize")
        
        self.shape = shape
        self.strides = strides
        self.storedSize = storedSize
    }
    
    func makeIterator() -> FlattenLOIndSequenceIterator {
        return FlattenLOIndSequenceIterator(self)
    }
}

/// Iterator on index for a flatten array from a given shape and strides
/// Note that this sequence is for print function of leave out version
internal struct FlattenLOIndSequenceIterator: IteratorProtocol{
    private let flattenLOIndSeq: FlattenLOIndSequence
    public var strides: [Int]{
        return self.flattenLOIndSeq.strides
    }
    public var shape: [Int]{
        return self.flattenLOIndSeq.shape
    }
    public var storedSize: Int{
        return self.flattenLOIndSeq.storedSize
    }
    
    public var indicesOfAxes: [Int]
    public var flattenIndex: Int = 0
    public var isUpAxis: Bool  = true//indicates which axis will be counted up
    
    public init(_ flattenLOIndSeq: FlattenLOIndSequence){
        self.flattenLOIndSeq = flattenLOIndSeq
        
        self.indicesOfAxes = Array(repeating: 0, count: flattenLOIndSeq.shape.count)
        self.flattenIndex = 0
        self.isUpAxis = true
    }
    
    //return (nil nil) indicates skip
    mutating func next() -> (flattenIndex: Int?, indices: [Int]?)? {
        if self.isUpAxis{// flattenIndex = 0, indicesOfAxes = [0,...,0] must be returned
                self.isUpAxis = false
                return (self.flattenIndex, self.indicesOfAxes)
            }
            
        
            
            for axis in (0..<self.indicesOfAxes.count).reversed(){
                
                if self.indicesOfAxes[axis] < self.shape[axis] - 1{
                    
                    if self.indicesOfAxes[axis] < 2 || self.indicesOfAxes[axis] >= self.shape[axis] - 4{ //0<=index<3 and dim-3-1<=index<dim
                        self.indicesOfAxes[axis] += 1
                        
                        self.isUpAxis = false
                        
                        self.flattenIndex += self.strides[axis]
                        
                        return (self.flattenIndex, self.indicesOfAxes)
                    }
                    else{// skip
                        let skipnum = self.shape[axis] - 6
                        
                        if axis == self.indicesOfAxes.count - 1{// last axis
                            self.indicesOfAxes[axis] += skipnum
                            self.flattenIndex += self.strides[axis] * skipnum
                            
                            self.isUpAxis = false
                        }
                        else{
                            self.indicesOfAxes[axis] += skipnum + 1
                            self.flattenIndex += self.strides[axis] * (skipnum + 1)
                            
                            self.isUpAxis = true // once return (nil, nil) (i.e. skip) and then re-start printing
                        }
                        return (nil, nil)
                    }
                }
                else{// next axis, i.e. self.indicesOfAxes[axis] == self.shape[axis] - 1
                    if axis >= 3 && axis < self.indicesOfAxes.count - 3{
                        for _axis in (0..<self.indicesOfAxes.count - 3).reversed(){//shape[_axis] padding for each indicesAxes
                            self.indicesOfAxes[_axis] = self.shape[_axis] - 1
                        }
                        
                        self.isUpAxis = false
                        
                        return (nil, nil)
                    }
                    
                    self.indicesOfAxes[axis] = 0

                    // reset flattenIndex
                    self.flattenIndex -= self.strides[axis]*(self.shape[axis] - 1)
                }
            }
            
            return nil
            
        }
}

