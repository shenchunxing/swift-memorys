//
//  ViewController.swift
//  swift-memorys
//
//  Created by shenchunxing on 09/10/2023.
//  Copyright (c) 2023 shenchunxing. All rights reserved.
//

import UIKit
import swift_memorys

enum TestEnum {
    case test1(Int, Int, Int)
    case test2(Int, Int)
    case test3(Int)
    case test4(Bool)
    case test5
}

struct Date {
    var year = 10
    var test = true
    var month = 20
    var day = 30
}


class Point  {
    var x = 11
    var test = true
    var y = 22
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var int8: Int8 = 10
        show(val: &int8)
        // -------------- Int8 --------------
        // 变量的地址: 0x00007ffeefbff598
        // 变量的内存: 0x0a
        // 变量的大小: 1

        var int16: Int16 = 10
        show(val: &int16)
        // -------------- Int16 --------------
        // 变量的地址: 0x00007ffeefbff590
        // 变量的内存: 0x000a
        // 变量的大小: 2
        
        var e = TestEnum.test1(1, 2, 3)
        show(val: &e)
        // -------------- TestEnum --------------
        // 变量的地址: 0x00007ffeefbff580
        // 变量的内存: 0x0000000000000001 0x0000000000000002 0x0000000000000003 0x0000000000000000
        // 变量的大小: 32

        
        var s = Date()
        show(val: &s)
        // -------------- Date --------------
        // 变量的地址: 0x00007ffeefbff580
        // 变量的内存: 0x000000000000000a 0x0000000000000001 0x0000000000000014 0x000000000000001e
        // 变量的大小: 32
  

        var p = Point()
        show(val: &p)
        // -------------- Point --------------
        // 变量的地址: 0x00007ffeefbff590
        // 变量的内存: 0x0000000101023680
        // 变量的大小: 8

        show(ref: p)
        // -------------- Point --------------
        // 对象的地址: 0x0000000101023680
        // 对象的内存: 0x00000001000072d8 0x0000000200000002 0x000000000000000b 0x0000000000000001 0x0000000000000016 0x3030303030303030
        // 对象的大小: 48
        
        var arr = [1, 2, 3, 4]
        show(val: &arr)
        // -------------- Array<Int> --------------
        // 变量的地址: 0x00007ffeefbff598
        // 变量的内存: 0x0000000101023800
        // 变量的大小: 8

        show(ref: arr)
        // -------------- Array<Int> --------------
        // 对象的地址: 0x0000000101023800
        // 对象的内存: 0x00007fff9c30f848 0x0000000200000002 0x0000000000000004 0x0000000000000008 0x0000000000000001 0x0000000000000002 0x0000000000000003 0x0000000000000004
        // 对象的大小: 64
        
        
        
        var str1 = "123456789"
        // taggerPtr（tagger pointer）
        print(str1.mems.type())
        show(val: &str1)
        // -------------- String --------------
        // 变量的地址: 0x00007ffeefbff580
        // 变量的内存: 0x3837363534333231 0xe900000000000039
        // 变量的大小: 16

        var str2 = "1234567812345678"
        // text（字符串存储在TEXT段）
        print(str2.mems.type())
        show(val: &str2)
        // -------------- String --------------
        // 变量的地址: 0x00007ffeefbff570
        // 变量的内存: 0xd000000000000010 0x8000000100007610
        // 变量的大小: 16

        var str3 = "1234567812345678"
        str3.append("9")
        // heap（字符串存储在堆空间）
        print(str3.mems.type())
        show(val: &str3)
        // -------------- String --------------
        // 变量的地址: 0x00007ffeefbff560
        // 变量的内存: 0xf000000000000011 0x00000001007b6ad0
        // 变量的大小: 16

        show(ref: str3)
        // -------------- String --------------
        // 对象的地址: 0x00000001007b6ad0
        // 对象的内存: 0x00007fff963e9660 0x0000000200000002 0x0000000000000018 0xf000000000000011 0x3837363534333231 0x3837363534333231 0x0000000000200039 0x0000000000000000
        // 对象的大小: 64
    }
    
    func show<T>(val: inout T) {
        print("-------------- \(type(of: val)) --------------")
        print("变量的地址:", Memorys.ptr(ofVal: &val))
        print("变量的内存:", Memorys.memStr(ofVal: &val))
        print("变量的大小:", Memorys.size(ofVal: &val))
        print("")
    }

    func show<T>(ref: T) {
        print("-------------- \(type(of: ref)) --------------")
        print("对象的地址:", Memorys.ptr(ofRef: ref))
        print("对象的内存:", Memorys.memStr(ofRef: ref))
        print("对象的大小:", Memorys.size(ofRef: ref))
        print("")
    }

}

