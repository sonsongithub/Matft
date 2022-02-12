//
//  conversion+method.swift
//  
//
//  Created by Junnosuke Kado on 2022/02/06.
//

import Foundation

extension MfArray{
    
    /// Create another typed mfarray. Created mfarray will be different object from original one
    /// - Parameters:
    ///   - newtype: A new type
    ///   - mforder: (Optional) An order
    /// - Returns: New typed mfarray
    public func astype<U: MfTypeUsable>(newtype: U.Type, mforder: MfOrder = .Row) -> MfArray<U>{
        return Matft.astype(self, newtype: newtype, mforder: mforder)
    }
    
    /// Create any ordered transposed mfarray. Created mfarray will be sharing data with original one
    /// - Parameters:
    ///   - axes: (Optional) the indices of shape. In case this is left out, get transposed mfarray
    /// - Returns: A transposed mfarray
    public func transpose(axes: [Int]? = nil) -> MfArray<T>{
        return Matft.transpose(self, axes: axes)
    }
    /// Create any ordered transposed mfarray. Created mfarray will be sharing data with original one
    /// - Parameters:
    /// - Returns: A transposed mfarray
    public var T: MfArray<T>{
        return Matft.transpose(self)
    }
    
    /// Create broadcasted mfarray.
    /// - Parameters:
    ///   - shape: A new shape
    /// - Returns: The broadcasted mfarray
    public func broadcast_to(shape: [Int]) -> MfArray{
        return Matft.broadcast_to(self, shape: shape)
    }
    
    /// Convert a given mfarray into a contiguous one
    /// - Parameters:
    ///   - mforder: An order
    /// - Returns: The contiguous mfarray
    public func to_contiguous(mforder: MfOrder) -> MfArray<T>{
        return Matft.to_contiguous(self, mforder: mforder)
    }
    
    /// Flatten to 1d-mfarray
    /// - Parameters:
    ///   - mforder: An order
    /// - Returns: The flatten mfarray
    public func flatten(mforder: MfOrder = .Row) -> MfArray<T>{
        return Matft.flatten(self, mforder: mforder)
    }
}
