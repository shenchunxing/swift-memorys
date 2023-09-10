//
//  Memorys.swift
//  swift-memorys
//
//  Created by 沈春兴 on 2023/9/10.
//

import Foundation

//4种对齐方式
public enum MemoryAlign : Int {
    case one = 1, two = 2, four = 4, eight = 8
}

// 空指针
private let _EMPTY_PTR = UnsafeRawPointer(bitPattern: 0x1)!

/// 辅助查看内存的小工具类
public struct Memorys<T> {
    /// 将内存中的数据以字符串形式表示出来
    private static func _memStr(_ ptr: UnsafeRawPointer,
                                _ size: Int,
                                _ aligment: Int) ->String {
        if ptr == _EMPTY_PTR { return "" }
        
        ///rawPtr ：起始地址
        var rawPtr = ptr
        var string = ""
        /// 格式化字符串，用于指定如何将每个值转换为十六进制字符串。
        /**
         "0x%0\(alignment << 1)lx" 是一个字符串模板，其中包含了占位符 %0\(alignment << 1)lx。
         "0x" 是一个十六进制前缀，表示后面的字符串将被解释为十六进制数字。
         %0 是格式说明符，表示要填充输出值的最小宽度为0。这意味着如果转换后的值不够宽，将在左侧用0进行填充。
         \(alignment << 1) 是一个占位符，用于插入实际的对齐值。在这里，alignment 被左移一位，相当于将其乘以2。这是因为通常对齐值表示的是字节数，而在十六进制表示中，每个字节用两个十六进制数字表示。
         lx 表示要将整数值格式化为长整数（以十六进制表示）。
         */
        let fmt = "0x%0\(aligment << 1)lx"
        /// 表示在给定对齐方式下有多少个值可以从内存块中读取
        let count = size / aligment
        for i in 0..<count {
            if i > 0 {
                string.append(" ")
                rawPtr += aligment
            }
            let value: CVarArg
            //对齐方式
            switch aligment {
            case MemoryAlign.eight.rawValue:
                value = rawPtr.load(as: UInt64.self)
            case MemoryAlign.four.rawValue:
                value = rawPtr.load(as: UInt32.self)
            case MemoryAlign.two.rawValue:
                value = rawPtr.load(as: UInt16.self)
            default:
                value = rawPtr.load(as: UInt8.self)
            }
            string.append(String(format: fmt, value))
        }
        return string
    }
    
    
    /// 从给定的内存地址 ptr 开始，连续读取指定数量的字节（由 size 指定），并将这些字节存储在一个UInt8类型的数组中
    private static func _memBytes(_ ptr: UnsafeRawPointer,
                                  _ size: Int) -> [UInt8] {
        var arr: [UInt8] = []
        if ptr == _EMPTY_PTR { return arr }
        for i in 0..<size {
            arr.append((ptr + i).load(as: UInt8.self))
        }
        return arr
    }
    
    /// 获得变量的内存数据（字节数组格式）
    public static func memBytes(ofVal v: inout T) -> [UInt8] {
        return _memBytes(ptr(ofVal: &v), MemoryLayout.stride(ofValue: v))
    }
    
    /// 获得引用所指向的内存数据（字节数组格式）
    public static func memBytes(ofRef v: T) -> [UInt8] {
        let p = ptr(ofRef: v)
        return _memBytes(p, malloc_size(p))
    }
    
    /// 获得变量的内存数据（字符串格式）
    ///
    /// - Parameter alignment: 决定了多少个字节为一组
    public static func memStr(ofVal v: inout T, alignment: MemoryAlign? = nil) -> String {
        let p = ptr(ofVal: &v)
        return _memStr(p, MemoryLayout.stride(ofValue: v),
                       alignment != nil ? alignment!.rawValue : MemoryLayout.alignment(ofValue: v))
    }
    
    /// 获得引用所指向的内存数据（字符串格式）
    ///
    /// - Parameter alignment: 决定了多少个字节为一组
    public static func memStr(ofRef v: T, alignment: MemoryAlign? = nil) -> String {
        let p = ptr(ofRef: v)
        return _memStr(p, malloc_size(p),
                       alignment != nil ? alignment!.rawValue : MemoryLayout.alignment(ofValue: v))
    }
    
    /// 获得变量的内存地址
    public static func ptr(ofVal v: inout T) -> UnsafeRawPointer {
        // withUnsafePointer : 值类型 v 的引用转换为一个不安全的指向 v 的指针
        return MemoryLayout.size(ofValue: v) == 0 ? _EMPTY_PTR : withUnsafePointer(to: &v) {
            UnsafeRawPointer($0)
        }
    }
    
    /// 获得引用所指向内存的地址
    public static func ptr(ofRef v: T) -> UnsafeRawPointer {
        /// 数组类型、Swift的类、AnyClass
        if v is Array<Any>
            || Swift.type(of: v) is AnyClass
            || v is AnyClass {
            return UnsafeRawPointer(bitPattern: unsafeBitCast(v, to: UInt.self))!
            /// 字符串类型
        } else if v is String {
            var mstr = v as! String
            /// 必须是堆空间的字符串，否则没意义
            if mstr.mems.type() != .heap {
                return _EMPTY_PTR
            }
            // 如果字符串在堆内存中存储，函数使用 unsafeBitCast 将 v 转换为元组 (UInt, UInt) 类型，然后获取元组的第二个值，这个值是字符串在堆内存中的地址。
            //元祖的第一个值是类型描述的值，一般用不到
            return UnsafeRawPointer(bitPattern: unsafeBitCast(v, to: (UInt, UInt).self).1)!
            /// 其他类型
        } else {
            return _EMPTY_PTR
        }
    }
    
    /// 获得变量所占用的内存大小
    public static func size(ofVal v: inout T) -> Int {
        return MemoryLayout.size(ofValue: v) > 0 ? MemoryLayout.stride(ofValue: v) : 0
    }
    
    /// 获得引用所指向内存的大小
    public static func size(ofRef v: T) -> Int {
        return malloc_size(ptr(ofRef: v))
    }
}

public enum StringMemType : UInt8 {
    /// TEXT段（常量区）
    case text = 0xd0
    /// taggerPointer
    case tagPtr = 0xe0
    /// 堆空间
    case heap = 0xf0
    /// 未知
    case unknow = 0xff
}

/// 制定一个结构体MemsWrapper，里面有base属性
public struct MemsWrapper<Base> {
    public private(set) var base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/// 制定协议MemsCompatible，同时支持静态和实例属性mems
public protocol MemsCompatible {}
public extension MemsCompatible {
    static var mems: MemsWrapper<Self>.Type {
        get { return MemsWrapper<Self>.self }
        set {}
    }
    var mems: MemsWrapper<Self> {
        get { return MemsWrapper(self) }
        set {}
    }
}

/// 让String遵守MemsCompatible协议
extension String: MemsCompatible {}
public extension MemsWrapper where Base == String {
    /// 获取字符串的内存类型
    mutating func type() -> StringMemType {
        /// 获取字符串的内存地址
        let ptr = Memorys.ptr(ofVal: &base)
        return StringMemType(rawValue: (ptr + 15).load(as: UInt8.self) & 0xf0) //高地址，对于swift对象来说，前16字节存储着类信息和引用计数
            ?? StringMemType(rawValue: (ptr + 7).load(as: UInt8.self) & 0xf0) //低地址
            ?? .unknow
    }
}
