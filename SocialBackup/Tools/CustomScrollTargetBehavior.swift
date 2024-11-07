////
////  CustomScrollTargetBehavior.swift
////  SocialBackup
////
////  Created by Alex Coundouriotis on 10/25/24.
////
//
//import Foundation
//import SwiftUI
//
//@available(iOS 17.0, *)
//struct CustomScrollTargetBehavior: ScrollTargetBehavior {
//    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
//        if context.velocity.dy > 0 {
//            target.rect.origin.y = context.originalTarget.rect.maxY
//        } else if context.velocity.dy < 0 {
//            target.rect.origin.y = context.originalTarget.rect.minY
//        }
//    }
//}
//
//@available(iOS 17.0, *)
//extension ScrollTargetBehavior where Self == CustomScrollTargetBehavior {
//    static var custom: CustomScrollTargetBehavior { .init() }
//}
