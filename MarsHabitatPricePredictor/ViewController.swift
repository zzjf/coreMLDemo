/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the MarsHabitatPricer app. Uses a `UIPickerView` to gather user inputs.
   The model's output is the predicted price.
*/

import UIKit
import CoreML
import ZipArchive

class ViewController: UIViewController {
    // MARK: - Properties
    
    var model: MarsHabitatPricer?
    var modelPath: URL?
    /// Data source for the picker.
    let pickerDataSource = PickerDataSource()
    
    /// Formatter for the output.
    let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    // MARK: - Outlets

    /// Label that will be updated with the predicted price.
    @IBOutlet weak var priceLabel: UILabel!

    /**
         The UI that users will use to select the number of solar panels,
         number of greenhouses, and acreage of the habitat.
    */
    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = pickerDataSource

            let features: [Feature] = [.solarPanels, .greenhouses, .size]
            for feature in features {
                pickerView.selectRow(2, inComponent: feature.rawValue, animated: false)
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    /// Updated the predicted price, when created.
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadModel()
    }
    func downloadModel() {
        if let url = URL(string: "http://localhost/MarsHabitatPricer.mlmodelc.zip") {
            URLSession.shared.dataTask(with: url){ data, response, error in
                let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
                let mlmodelcZipPath = docPath?.appending("/MarsHabitatPricer.mlmodelc.zip")
                let url = URL(fileURLWithPath: mlmodelcZipPath!)
                if (FileManager.default.fileExists(atPath: mlmodelcZipPath!)) {
                    try! FileManager.default.removeItem(atPath: mlmodelcZipPath!)
                }
                try! data?.write(to: url)
                SSZipArchive.unzipFile(atPath: mlmodelcZipPath!, toDestination: docPath!)
                
                self.modelPath = URL(fileURLWithPath: (docPath?.appending("/MarsHabitatPricer.mlmodelc"))!)
                
                self.model = try! MarsHabitatPricer(contentsOf: self.modelPath!)
                DispatchQueue.main.async {
                    self.updatePredictedPrice()
                }
                }.resume()
            
        }
    }
    /**
         The main logic for the app, performing the integration with Core ML.
         First gather the values for input to the model. Then have the model generate
         a prediction with those inputs. Finally, present the predicted value to
         the user.
    */
    func updatePredictedPrice() {
        func selectedRow(for feature: Feature) -> Int {
            return pickerView.selectedRow(inComponent: feature.rawValue)
        }

        let solarPanels = pickerDataSource.value(for: selectedRow(for: .solarPanels), feature: .solarPanels)
        let greenhouses = pickerDataSource.value(for: selectedRow(for: .greenhouses), feature: .greenhouses)
        let size = pickerDataSource.value(for: selectedRow(for: .size), feature: .size)

        guard let marsHabitatPricerOutput = try? model?.prediction(solarPanels: solarPanels, greenhouses: greenhouses, size: size) else {
            fatalError("Unexpected runtime error.")
        }

        let price = marsHabitatPricerOutput?.price
        priceLabel.text = priceFormatter.string(for: price)
    }
}
