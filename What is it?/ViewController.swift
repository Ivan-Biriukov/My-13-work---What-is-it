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
        lb.textColor = .magenta
        lb.font = .systemFont(ofSize: 30)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let firstAnswer : UILabel = {
        let lb = UILabel()
        lb.text = "C вероятностью 55% на фото банан"
        lb.textColor = .magenta
        lb.font = .systemFont(ofSize: 22)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let secondAnswer : UILabel = {
        let lb = UILabel()
        lb.text = "C вероятностью 22% на фото огурец"
        lb.textColor = .magenta
        lb.font = .systemFont(ofSize: 22)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let pickerView : UIImagePickerController = {
        let picker = UIImagePickerController()
        
        return picker
    }()
    
    private let selectedImage : UIImageView = {
        let place = UIImageView()
        
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
            print(result?.first?.identifier)
            print(result?.first?.confidence)
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
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(mainTitleLabel)
        mainStackView.addArrangedSubview(firstAnswer)
        mainStackView.addArrangedSubview(secondAnswer)
        mainStackView.addArrangedSubview(selectedImage)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }
}

