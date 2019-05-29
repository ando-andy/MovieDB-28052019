//
//  AppDelegate.swift
//  MovieDB
//
//  Created by nguyen.van.hungd on 5/27/19.
//  Copyright © 2019 nguyen.van.hungd. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var assembler: Assembler = DefaultAssembler()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        bindViewModel()
        return true
    }
    
    private func bindViewModel() {
        window = UIWindow()
        let vm: AppViewModel = assembler.resolve(window: window!)
        let input = AppViewModel.Input(loadTrigger: Driver.just(()))
        let output = vm.transform(input)
        output.toMain
            .drive()
            .disposed(by: rx.disposeBag)
    }
}

