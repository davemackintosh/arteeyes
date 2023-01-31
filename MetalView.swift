struct MetalView: UIViewRepresentable {
    // MARK: Lifecycle

    init() {
        let device = MTLCreateSystemDefaultDevice()!
        renderer = .init(device: device)

        view = MTKView()
        view.preferredFramesPerSecond = 60
        view.clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.device = device
        view.contentMode = .scaleAspectFit
        view.contentScaleFactor = UIScreen.main.scale
        view.delegate = renderer
    }

    // MARK: Internal

    let renderer: Renderer!

    private(set) var view: MTKView!

    func makeUIView(context _: Context) -> MTKView {
        view
    }

    func updateUIView(_: MTKView, context _: Context) {}
}
