//
//  vDSP.swift
//  
//
//  Created by Junnosuke Kado on 2022/02/05.
//

import Foundation
import Accelerate

public typealias vDSP_convert_func<T, U> = (UnsafePointer<T>, vDSP_Stride, UnsafeMutablePointer<U>, vDSP_Stride, vDSP_Length) -> Void

public typealias vDSP_biopvv_func<T> = (UnsafePointer<T>, vDSP_Stride, UnsafePointer<T>, vDSP_Stride, UnsafeMutablePointer<T>, vDSP_Stride, vDSP_Length) -> Void

public typealias vDSP_biopvs_func<T> = (UnsafePointer<T>, vDSP_Stride, UnsafePointer<T>, UnsafeMutablePointer<T>, vDSP_Stride, vDSP_Length) -> Void

public typealias vDSP_biopsv_func<T> = (UnsafePointer<T>, UnsafePointer<T>, vDSP_Stride, UnsafeMutablePointer<T>, vDSP_Stride, vDSP_Length) -> Void

public typealias vDSP_vcmprs_func<T> = (UnsafePointer<T>, vDSP_Stride, UnsafePointer<T>, vDSP_Stride, UnsafeMutablePointer<T>, vDSP_Stride, vDSP_Length) -> Void

public typealias vDSP_vminmg_func<T> = (UnsafePointer<T>, vDSP_Stride, UnsafePointer<T>, vDSP_Stride, UnsafeMutablePointer<T>, vDSP_Stride, vDSP_Length) -> Void

public typealias vDSP_viclip_func<T> = (UnsafePointer<T>, vDSP_Stride, UnsafePointer<T>,  UnsafePointer<T>, UnsafeMutablePointer<T>, vDSP_Stride, vDSP_Length) -> Void

/// Wrapper of vDSP conversion function
/// - Parameters:
///   - size: A size to be copied
///   - srcptr: A source pointer
///   - srcStride: A source stride
///   - dstptr: A destination pointer
///   - dstStride: A destination stride
///   - vDSP_func: The vDSP conversion function
@inline(__always)
internal func wrap_vDSP_convert<T, U>(_ size: Int, _ srcptr: UnsafePointer<T>, _ srcStride: Int, _ dstptr: UnsafeMutablePointer<U>, _ dstStride: Int, _ vDSP_func: vDSP_convert_func<T, U>){
    vDSP_func(srcptr, vDSP_Stride(srcStride), dstptr, vDSP_Stride(dstStride), vDSP_Length(size))
}

/// Wrapper of vDSP binary operation function
/// - Parameters:
///   - size: A size
///   - lsrcptr: A left  source pointer
///   - lsrcStride: A left source stride
///   - rsrcptr: A right source pointer
///   - rsrcStride: A right source stride
///   - dstptr: A destination pointer
///   - dstStride: A destination stride
///   - vDSP_func: The vDSP conversion function
@inline(__always)
internal func wrap_vDSP_biopvv<T>(_ size: Int, _ lsrcptr: UnsafePointer<T>, _ lsrcStride: Int, _ rsrcptr: UnsafePointer<T>, _ rsrcStride: Int, _ dstptr: UnsafeMutablePointer<T>, _ dstStride: Int, _ vDSP_func: vDSP_biopvv_func<T>){
    vDSP_func(rsrcptr, vDSP_Stride(rsrcStride), lsrcptr, vDSP_Stride(lsrcStride), dstptr, vDSP_Stride(dstStride), vDSP_Length(size))
}


/// Wrapper of vDSP binary operation function
/// - Parameters:
///   - size: A size
///   - srcptr: A source pointer
///   - srcStride: A source stride
///   - scalar: A source scalar pointer
///   - dstptr: A destination pointer
///   - dstStride: A destination stride
///   - vDSP_func: The vDSP conversion function
@inline(__always)
internal func wrap_vDSP_biopvs<T>(_ size: Int, _ srcptr: UnsafePointer<T>, _ srcStride: Int, _ scalar: UnsafePointer<T>, _ dstptr: UnsafeMutablePointer<T>, _ dstStride: Int, _ vDSP_func: vDSP_biopvs_func<T>){
    vDSP_func(srcptr, vDSP_Stride(srcStride), scalar, dstptr, vDSP_Stride(dstStride), vDSP_Length(size))
}

/// Wrapper of vDSP binary operation function
/// - Parameters:
///   - size: A size
///   - scalar: A source scalar pointer
///   - srcptr: A source pointer
///   - srcStride: A source stride
///   - dstptr: A destination pointer
///   - dstStride: A destination stride
///   - vDSP_func: The vDSP conversion function
@inline(__always)
internal func wrap_vDSP_biopsv<T>(_ size: Int, _ scalar: UnsafePointer<T>, _ srcptr: UnsafePointer<T>, _ srcStride: Int, _ dstptr: UnsafeMutablePointer<T>, _ dstStride: Int, _ vDSP_func: vDSP_biopsv_func<T>){
    vDSP_func(scalar, srcptr, vDSP_Stride(srcStride), dstptr, vDSP_Stride(dstStride), vDSP_Length(size))
}

/// Wrapper of vDSP boolean conversion function
/// - Parameters:
///   - size: A size to be converted
///   - srcptr: A source pointer
///   - dstptr: A destination pointer
///   - vDSP_vminmg_func: The vDSP vminmg function
///   - vDSP_viclip_func: The vDSP viclip function
@inline(__always)
internal func wrap_vDSP_toBool<T: MfStoredTypeUsable>(_ size: Int, _ srcptr: UnsafePointer<T>, _ dstptr: UnsafeMutablePointer<T>, _ vDSP_vminmg_func: vDSP_vminmg_func<T>, _ vDSP_viclip_func: vDSP_viclip_func<T>){
    // if |src| <= 1  => dst = |src|
    //    |src| > 1   => dst = 1
    // Note that the 0<= dst <= 1
    var one = T.from(1)
    vDSP_vminmg_func(srcptr, vDSP_Stride(1), &one, vDSP_Stride(0), dstptr, vDSP_Stride(1), vDSP_Length(size))
    
    var zero = T.zero
    one = T.from(1)
    // if src <= 0, 1 <= src   => dst = src
    //    0 < src <= 1         => dst = 1
    vDSP_viclip_func(dstptr, vDSP_Stride(1), &zero, &one, dstptr, vDSP_Stride(1), vDSP_Length(size))
}

/// Wrapper of vDSP sign generation function
/// - Parameters:
///   - size: A size to be converted
///   - srcptr: A source pointer
///   - dstptr: A destination pointer
///   - vDSP_vminmg_func: The vDSP vminmg function
///   - vDSP_viclip_func: The vDSP viclip function
///   - vForce_copysign_func: The vForce copysign function
@inline(__always)
internal func wrap_vDSP_sign<T: MfStoredTypeUsable>(_ size: Int, _ srcptr: UnsafePointer<T>, _ dstptr: UnsafeMutablePointer<T>, _ vDSP_vminmg_func: vDSP_vminmg_func<T>, _ vDSP_viclip_func: vDSP_viclip_func<T>, _ vForce_copysign_func: vForce_copysign_func<T>){
    var i32size = Int32(size)
    
    // if |src| <= 1  => dst = |src|
    //    |src| > 1   => dst = 1
    // Note that the 0<= dst <= 1
    var one = T.from(1)
    vDSP_vminmg_func(srcptr, vDSP_Stride(1), &one, vDSP_Stride(0), dstptr, vDSP_Stride(1), vDSP_Length(size))
    
    var zero = T.zero
    one = T.from(1)
    // if src <= 0, 1 <= src   => dst = src
    //    0 < src <= 1         => dst = 1
    vDSP_viclip_func(dstptr, vDSP_Stride(1), &zero, &one, dstptr, vDSP_Stride(1), vDSP_Length(size))
    vForce_copysign_func(dstptr, dstptr, srcptr, &i32size)
}


/// Pre operation mfarray by vDSP
/// - Parameters:
///   - mfarray: An input mfarray
///   - vDSP_func: vDSP_convert_func
/// - Returns: Pre operated mfarray
internal func preop_by_vDSP<T: MfTypeUsable>(_ mfarray: MfArray<T>, _ vDSP_func: vDSP_convert_func<T.StoredType, T.StoredType>) -> MfArray<T>{
    //return mfarray must be either row or column major
    var mfarray = mfarray
    //print(mfarray)
    mfarray = check_contiguous(mfarray)
    //print(mfarray)
    //print(mfarray.strides)
    
    let newdata: MfData<T> = MfData(size: mfarray.storedSize)
    wrap_vDSP_convert(mfarray.storedSize, mfarray.mfdata.storedPtr.baseAddress!, 1, newdata.storedPtr.baseAddress!, 1, T.StoredType.vDSP_neg_func)
    
    
    let newmfstructure = MfStructure(shape: mfarray.shape, strides: mfarray.strides)
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}


/// Boolean conversion by vDSP
/// - Parameter mfarray: An input mfarray
/// - Returns: Converted mfarray
internal func toBool_by_vDSP<T: MfTypeUsable>(_ mfarray: MfArray<T>) -> MfArray<Bool> where T.StoredType == Float{
    
    let size = mfarray.storedSize
    let newdata: MfData<Bool> = MfData(size: mfarray.storedSize)

    wrap_vDSP_toBool(size, mfarray.mfdata.storedPtr.baseAddress!, newdata.storedPtr.baseAddress!, Bool.StoredType.vDSP_vminmg_func, Bool.StoredType.vDSP_viclip_func)
    
    let newmfstructure = MfStructure(shape: mfarray.shape, strides: mfarray.strides)
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}

/// Boolean conversion by vDSP
/// - Parameter mfarray: An input mfarray
/// - Returns: Converted mfarray
internal func toBool_by_vDSP<T: MfTypeUsable>(_ mfarray: MfArray<T>) -> MfArray<Bool> where T.StoredType == Double{
    //let mfarray = mfarray.astype(Float.self)
    
    let size = mfarray.storedSize
    let newdata: MfData<Bool> = MfData(size: mfarray.storedSize)
    // Double to Float
    wrap_vDSP_convert(mfarray.storedSize, mfarray.mfdata.storedPtr.baseAddress!, 1, newdata.storedPtr.baseAddress!, 1, vDSP_vdpsp)
    wrap_vDSP_toBool(size, newdata.storedPtr.baseAddress!, newdata.storedPtr.baseAddress!, Bool.StoredType.vDSP_vminmg_func, Bool.StoredType.vDSP_viclip_func)
    
    let newmfstructure = MfStructure(shape: mfarray.shape, strides: mfarray.strides)
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}

/// Generate sign by vDSP
/// - Parameter mfarray: An input mfarray
/// - Returns: Converted mfarray
internal func sign_by_vDSP<T: MfTypeUsable>(_ mfarray: MfArray<T>) -> MfArray<T>{
    let mfarray = check_contiguous(mfarray)
    
    let size = mfarray.storedSize
    let newdata: MfData<T> = MfData(size: mfarray.storedSize)
    wrap_vDSP_sign(size, mfarray.mfdata.storedPtr.baseAddress!, newdata.storedPtr.baseAddress!, T.StoredType.vDSP_vminmg_func, T.StoredType.vDSP_viclip_func,
        T.StoredType.vForce_copysign_func)
    
    let newmfstructure = MfStructure(shape: mfarray.shape, strides: mfarray.strides)
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}


/// Binary operation by vDSP
/// - Parameters:
///   - l_mfarray: The left mfarray
///   - r_mfarray: The right mfarray
///   - vDSP_func: The vDSP biop function
/// - Returns: The result mfarray
internal func biopvv_by_vDSP<T: MfNumeric>(_ l_mfarray: MfArray<T>, _ r_mfarray: MfArray<T>, vDSP_func: vDSP_biopvv_func<T.StoredType>) -> MfArray<T>{
    // biggerL: flag whether l is bigger than r
    // return mfarray must be either row or column major
    let (l_mfarray, r_mfarray, biggerL, retsize) = check_biop_contiguous(l_mfarray, r_mfarray, .Row, convertL: true)
    
    let newdata: MfData<T> = MfData(size: retsize)
    l_mfarray.withUnsafeMutableStartPointer{
        [unowned l_mfarray] (lptr) in
        r_mfarray.withUnsafeMutableStartPointer{
            [unowned r_mfarray] (rptr) in
            if biggerL{ // l is bigger
                for vDSPPrams in OptOffsetParamsSequence(shape: l_mfarray.shape, bigger_strides: l_mfarray.strides, smaller_strides: r_mfarray.strides){
                    wrap_vDSP_biopvv(vDSPPrams.blocksize, lptr + vDSPPrams.b_offset, vDSPPrams.b_stride, rptr + vDSPPrams.s_offset, vDSPPrams.s_stride, newdata.storedPtr.baseAddress! + vDSPPrams.b_offset, vDSPPrams.b_stride, vDSP_func)
                }
            }
            else{ // r is bigger
                for vDSPPrams in OptOffsetParamsSequence(shape: r_mfarray.shape, bigger_strides: r_mfarray.strides, smaller_strides: l_mfarray.strides){
                    wrap_vDSP_biopvv(vDSPPrams.blocksize, lptr + vDSPPrams.s_offset, vDSPPrams.s_stride, rptr + vDSPPrams.b_offset, vDSPPrams.b_stride, newdata.storedPtr.baseAddress! + vDSPPrams.b_offset, vDSPPrams.b_stride, vDSP_func)
                }
            }
        }
    }
    
    let newstructure: MfStructure
    if biggerL{
        newstructure = MfStructure(shape: l_mfarray.shape, strides: l_mfarray.strides)
    }
    else{
        newstructure = MfStructure(shape: r_mfarray.shape, strides: r_mfarray.strides)
    }
    return MfArray(mfdata: newdata, mfstructure: newstructure)
}


/// Binary operation by vDSP
/// - Parameters:
///   - l_mfarray: The left mfarray
///   - r_scalr: The right scalar
///   - vDSP_func: The vDSP biop function
/// - Returns: The result mfarray
internal func biopvs_by_vDSP<T: MfNumeric>(_ l_mfarray: MfArray<T>, _ r_scalar: T.StoredType, vDSP_func: vDSP_biopvs_func<T.StoredType>) -> MfArray<T>{
    let l_mfarray = check_contiguous(l_mfarray)
    var r_scalar = r_scalar
    
    let newdata: MfData<T> = MfData(size: l_mfarray.storedSize)
    l_mfarray.withUnsafeMutableStartPointer{
        [unowned l_mfarray] in
        wrap_vDSP_biopvs(l_mfarray.storedSize, $0, 1, &r_scalar, newdata.storedPtr.baseAddress!, 1, vDSP_func)
    }
    
    let newstructure = MfStructure(shape: l_mfarray.shape, strides: l_mfarray.strides)
    
    return MfArray(mfdata: newdata, mfstructure: newstructure)
}

/// Binary operation by vDSP
/// - Parameters:
///   - l_scalar: The left scalar
///   - r_mfarray: The right mfarray
///   - vDSP_func: The vDSP biop function
/// - Returns: The result mfarray
internal func biopsv_by_vDSP<T: MfNumeric>(_ l_scalar: T.StoredType, _ r_mfarray: MfArray<T>, vDSP_func: vDSP_biopsv_func<T.StoredType>) -> MfArray<T>{
    let r_mfarray = check_contiguous(r_mfarray)
    var l_scalar = l_scalar
    
    let newdata: MfData<T> = MfData(size: r_mfarray.storedSize)
    r_mfarray.withUnsafeMutableStartPointer{
        [unowned r_mfarray] in
        wrap_vDSP_biopsv(r_mfarray.storedSize, &l_scalar, $0, 1, newdata.storedPtr.baseAddress!, 1, vDSP_func)
    }
    
    let newstructure = MfStructure(shape: r_mfarray.shape, strides: r_mfarray.strides)
    
    return MfArray(mfdata: newdata, mfstructure: newstructure)
}

/*
internal func boolget_by_vDSP<T: MfTypeUsable>(_ src_mfarray: MfArray<T>, _ indices: MfArray<Bool>, _ vDSP_func: vDSP_vcmprs_func<T.StoredType>) -> MfArray<T>{
    
    /*
     Note that returned shape must be (true number in original indices, (mfarray's shape - original indices' shape));
     i.e. returned dim = 1(=true number in original indices) + mfarray's dim - indices' dim
     */
    let true_num = Float.toInt(indices.sum().scalar!)
    let orig_ind_dim = indices.ndim
    
    // broadcast
    let indices = bool_broadcast_to(indices, shape: mfarray.shape)

    // must be row major
    let indicesU: MfArray<U> = check_contiguous(indices.astype(U.self), .Row)
    let mfarray = check_contiguous(mfarray, .Row)
    
    
    let lastShape = Array(mfarray.shape.suffix(mfarray.ndim - orig_ind_dim))
    var retShape = [true_num] + lastShape
    let retSize = shape2size(&retShape)
    
    let newdata = withDummyDataMRPtr(T.self, storedSize: retSize){
        dstptr in
        let dstptrU = dstptr.bindMemory(to: U.self, capacity: retSize)
        
        indicesU.withDataUnsafeMBPtrT(datatype: U.self){
            [unowned indicesU](indptr) in
            // note that indices and mfarray is row contiguous
            mfarray.withDataUnsafeMBPtrT(datatype: U.self){
                srcptr in
                vDSP_func(srcptr.baseAddress!, vDSP_Stride(1), indptr.baseAddress!, vDSP_Stride(1), dstptrU, vDSP_Stride(1), vDSP_Length(indicesU.size))
            }
        }
    }
    
}*/
