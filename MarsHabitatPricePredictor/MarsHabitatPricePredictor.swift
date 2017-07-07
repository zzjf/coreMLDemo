//
//  MarsHabitatPricePredictor.swift
//  MarsHabitatPricePredictor
//
//  Created by zzjf on 2017/7/7.
//  Copyright © 2017年 Apple. All rights reserved.
//

import Foundation
import CoreML

class MarsHabitatPricerInput : MLFeatureProvider {
    var solarPanels: Double
    var greenhouses: Double
    var size: Double
    
    var featureNames: Set<String> {
        get {
            return ["solarPanels", "greenhouses", "size"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "solarPanels") {
            return MLFeatureValue(double: solarPanels)
        }
        if (featureName == "greenhouses") {
            return MLFeatureValue(double: greenhouses)
        }
        if (featureName == "size") {
            return MLFeatureValue(double: size)
        }
        return nil
    }
    
    init(solarPanels: Double, greenhouses: Double, size: Double) {
        self.solarPanels = solarPanels
        self.greenhouses = greenhouses
        self.size = size
    }
}

class MarsHabitatPricerOutput : MLFeatureProvider {
    let price: Double
    
    var featureNames: Set<String> {
        get {
            return ["price"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "price") {
            return MLFeatureValue(double: price)
        }
        return nil
    }
    
    init(price: Double) {
        self.price = price
    }
}

@objc class MarsHabitatPricer:NSObject {
    var model: MLModel

    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    func prediction(input: MarsHabitatPricerInput) throws -> MarsHabitatPricerOutput {
        let outFeatures = try model.prediction(from: input)
        let result = MarsHabitatPricerOutput(price: outFeatures.featureValue(for: "price")!.doubleValue)
        return result
    }
    func prediction(solarPanels: Double, greenhouses: Double, size: Double) throws -> MarsHabitatPricerOutput {
        let input_ = MarsHabitatPricerInput(solarPanels: solarPanels, greenhouses: greenhouses, size: size)
        return try self.prediction(input: input_)
    }
}
