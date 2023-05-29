import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let posibilityValue : String = "15%"
    private let photoObjectName : String = "banana"
    
    // MARK: - Configure UI
    
    private let barCameraButton = UIBarButtonItem(systemItem: .camera)
    private let photoGalleryButton = UIBarButtonItem(systemItem: .bookmarks)
    
    private let backgroundImg : UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "background")
        img.clipsToBounds = true
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let mainTitleLabel : UILabel = {
        let lb = UILabel()
        lb.text = "Please add a picture!"
        lb.textAlignment = .center
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 30)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let firstAnswer : UILabel = {
        let lb = UILabel()
        lb.text = "C вероятностью 55% на фото банан"
        lb.textColor = .white
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.font = .systemFont(ofSize: 20)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let secondAnswer : UILabel = {
        let lb = UILabel()
        lb.text = "C вероятностью 22% на фото огурец"
        lb.textColor = .white
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.font = .systemFont(ofSize: 20)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let pickerView : UIImagePickerController = {
        let picker = UIImagePickerController()
        
        return picker
    }()
    
    private let selectedImage : UIImageView = {
        let place = UIImageView()
        place.image = UIImage(named: "selectPhoto")
        place.translatesAutoresizingMaskIntoConstraints = false
        return place
    }()

    private let mainStackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    
    
    private func configureNavBarItems() {
        self.navigationItem.rightBarButtonItem = barCameraButton
        barCameraButton.action = #selector(barCameraButtonTapped)
        barCameraButton.target = self
        self.navigationItem.leftBarButtonItem = photoGalleryButton
        photoGalleryButton.action = #selector(photoGalleryButtonTapped)
        photoGalleryButton.target = self
        self.navigationItem.title = "Simply way to figure what is it!"
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.backgroundColor = .gray
    }
    
    private func configurePicker() {
        pickerView.delegate = self
        pickerView.allowsEditing = false
    }
    
    // MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBarItems()
        configurePicker()
        addSubviews()
        setConstraints()
        firstAnswer.isHidden = true
        secondAnswer.isHidden = true
    }
    
    // MARK: - Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            selectedImage.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage into CoreImageimage")
            }
            detect(image: ciimage)
        }
        pickerView.dismiss(animated: true)
        mainTitleLabel.text = "It can be:"
    }
    
    // MARK: - Buttons Methods
    
    @objc func barCameraButtonTapped() {
        pickerView.sourceType = .camera
        present(pickerView, animated: true)
    }
    
    @objc func photoGalleryButtonTapped() {
        pickerView.sourceType = .photoLibrary
        present(pickerView, animated: true)
    }

    // MARK: - Request Methods
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Loading CoreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) {(request, error) in
            let result = request.results as? [VNClassificationObservation]
            if let posibility = result?.first?.confidence, let answer = result?.first?.identifier {
                
                var transferPosibility = Double(posibility)
                transferPosibility *= 100
                let currentPercent = Int(transferPosibility)
                
                self.firstAnswer.text = "With posibility of \(currentPercent)% it may be \(answer)"
                self.firstAnswer.isHidden = false
            }
            if let secondPosibility = result?[1].confidence , let secondAnswer = result?[1].identifier {
                
                var transferPosibility = Double(secondPosibility)
                transferPosibility *= 100
                let currentPercent = Int(transferPosibility)
                
                self.secondAnswer.text = "Also it can be \(secondAnswer) with chanse of \(currentPercent)%"
                self.secondAnswer.isHidden = false
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Configure UI
    
    private func addSubviews() {
        view.addSubview(backgroundImg)
        view.addSubview(mainTitleLabel)
        view.addSubview(firstAnswer)
        view.addSubview(secondAnswer)
        view.addSubview(selectedImage)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            mainTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            mainTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            firstAnswer.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 20),
            firstAnswer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstAnswer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            secondAnswer.topAnchor.constraint(equalTo: firstAnswer.bottomAnchor, constant: 20),
            secondAnswer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            secondAnswer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            selectedImage.topAnchor.constraint(equalTo: secondAnswer.bottomAnchor, constant: 60),
            selectedImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            selectedImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            selectedImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -140)
        ])
    }
}

