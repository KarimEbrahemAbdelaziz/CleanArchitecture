//
//  ProductsViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

struct ProductsViewModel {
    let navigator: ProductsNavigatorType
    let useCase: ProductsUseCaseType
}

// MARK: - ViewModelType
extension ProductsViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
    }
    
    final class Output: ObservableObject {
        @Published var products = [Product]()
        @Published var error: Error = AppError.none
        @Published var isLoading = false
        @Published var isReloading = false
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let result = getList(
            loadTrigger: input.loadTrigger,
            getItems: { [useCase] _ in
                useCase.getProducts(page: 1)
                    .map { $0.items }
                    .eraseToAnyPublisher()
            },
            reloadTrigger: input.reloadTrigger,
            reloadItems: { [useCase] _ in
                useCase.getProducts(page: 1)
                    .map { $0.items }
                    .eraseToAnyPublisher()
            }, mapper: { $0 }
        )
        
        let (products, error, isLoading, isReloading) = result.destructured
        
        let output = Output()
        
        products
            .assign(to: \.products, on: output)
            .store(in: cancelBag)
        
        error
            .assign(to: \.error, on: output)
            .store(in: cancelBag)
        
        isLoading
            .assign(to: \.isLoading, on: output)
            .store(in: cancelBag)
        
        isReloading
            .assign(to: \.isReloading, on: output)
            .store(in: cancelBag)
        
        return output
    }
}
