import SwiftUI
import Charts
import SceneKit

// MARK: - Models
struct Barn: Identifiable, Codable {
    let id: UUID
    var name: String
    var imageName: String
    var currentTemp: Double
    var targetTemp: Double
    var humidity: Int
    var ammoniaPPM: Int
    var ventStatus: String
    var sensors: [Sensor]
    
    init(id: UUID = UUID(), name: String, imageName: String, currentTemp: Double, targetTemp: Double, humidity: Int, ammoniaPPM: Int, ventStatus: String, sensors: [Sensor] = []) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.currentTemp = currentTemp
        self.targetTemp = targetTemp
        self.humidity = humidity
        self.ammoniaPPM = ammoniaPPM
        self.ventStatus = ventStatus
        self.sensors = sensors
    }
}

struct Sensor: Identifiable, Codable {
    let id: UUID
    var name: String
    var status: String
    var ammoniaPPM: Int
    
    init(id: UUID = UUID(), name: String, status: String, ammoniaPPM: Int) {
        self.id = id
        self.name = name
        self.status = status
        self.ammoniaPPM = ammoniaPPM
    }
}

struct AmmoniaReading: Identifiable {
    let id = UUID()
    let date: String
    let safe: Double
    let warning: Double
    let critical: Double
}

// MARK: - Main App
@main
struct BarnMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            AmmoniaDetailView()
                .tabItem {
                    Image(systemName: "cloud.fill")
                    Text("Ammonia")
                }
                .tag(1)
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @State private var barns: [Barn] = [
        Barn(name: "Barn 1", imageName: "https://images.unsplash.com/photo-1500595046743-cd271d694d30?w=400", currentTemp: 22, targetTemp: 25, humidity: 55, ammoniaPPM: 12, ventStatus: "On"),
        Barn(name: "Barn 2", imageName: "https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400", currentTemp: 28, targetTemp: 25, humidity: 62, ammoniaPPM: 35, ventStatus: "On"),
        Barn(name: "Barn 3", imageName: "https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=400", currentTemp: 30, targetTemp: 25, humidity: 68, ammoniaPPM: 18, ventStatus: "On"),
        Barn(name: "Barn 4", imageName: "https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400", currentTemp: 32, targetTemp: 25, humidity: 72, ammoniaPPM: 65, ventStatus: "Off"),
        Barn(name: "Barn 5", imageName: "https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400", currentTemp: 26, targetTemp: 25, humidity: 58, ammoniaPPM: 28, ventStatus: "On")
    ]
    @State private var showingAddBarn = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(barns) { barn in
                        NavigationLink(destination: BarnDetailView(barn: barn)) {
                            BarnCardView(barn: barn)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBarn = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBarn) {
                AddBarnView(barns: $barns)
            }
        }
    }
}

// MARK: - Barn Card View
struct BarnCardView: View {
    let barn: Barn
    
    var statusColor: Color {
        if barn.ammoniaPPM < 20 {
            return .green
        } else if barn.ammoniaPPM < 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Barn Image
            AsyncImage(url: URL(string: barn.imageName)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            .clipped()
            .cornerRadius(12)
            
            // Barn Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(barn.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(barn.ammoniaPPM) ppm")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor)
                        Text("NH₃")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(statusColor)
                            .frame(width: geometry.size.width * min(Double(barn.ammoniaPPM) / 50.0, 1.0), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                // Stats Row
                HStack(spacing: 16) {
                    StatItemView(icon: "drop.fill", value: "\(barn.humidity)%")
                    StatItemView(icon: "thermometer", value: "\(Int(barn.targetTemp))°C")
                    StatItemView(icon: "n.circle.fill", value: "\(barn.ammoniaPPM) ppm", isNH3: true)
                    StatItemView(icon: "fan.fill", value: barn.ventStatus)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Stat Item View
struct StatItemView: View {
    let icon: String
    let value: String
    var isNH3: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            if isNH3 {
                Text("NH₃")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.green)
            }
            Text(value)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Barn Detail View
struct BarnDetailView: View {
    let barn: Barn
    @State private var sensors: [Sensor] = [
        Sensor(name: "Sensor 1", status: "On", ammoniaPPM: 16),
        Sensor(name: "Sensor 2", status: "Off", ammoniaPPM: 0)
    ]
    @State private var temperatureActive = false
    @State private var ammoniaActive = false
    @State private var fanActive = true
    @State private var ventActive = false
    @State private var humidityActive = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with temperature
                VStack(spacing: 8) {
                    Text("Temperature: \(String(format: "%.2f", barn.currentTemp))°C")
                        .font(.headline)
                    
                    HStack {
                        Text("\(barn.ammoniaPPM)%")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(barn.ammoniaPPM < 20 ? .green : barn.ammoniaPPM < 50 ? .orange : .red)
                        
                        Text("Ammonia Level")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // 3D Visualization
                Barn3DHeatMapView(barn: barn, ammoniaPPM: barn.ammoniaPPM)
                    .frame(height: 300)
                    .padding(.horizontal)
                
                // Control Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ControlButton(
                        icon: "thermometer.medium",
                        label: "Temperature",
                        value: "\(Int(barn.currentTemp))°C",
                        isActive: $temperatureActive
                    )
                    ControlButton(
                        icon: "cloud.fill",
                        label: "Ammonia",
                        value: "\(barn.ammoniaPPM) ppm",
                        isActive: $ammoniaActive
                    )
                    ControlButton(
                        icon: "fan.fill",
                        label: "Fan",
                        value: barn.ventStatus,
                        isActive: $fanActive
                    )
                    ControlButton(
                        icon: "wind",
                        label: "Vent",
                        value: "Auto",
                        isActive: $ventActive
                    )
                    ControlButton(
                        icon: "humidity.fill",
                        label: "Humidity",
                        value: "\(barn.humidity)%",
                        isActive: $humidityActive
                    )
                }
                .padding(.horizontal)
                
                // Sensors
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sensors")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(sensors) { sensor in
                        SensorCardView(sensor: sensor)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(barn.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 3D Heat Map View
struct Barn3DHeatMapView: UIViewRepresentable {
    let barn: Barn
    let ammoniaPPM: Int
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene()
        scnView.backgroundColor = UIColor.white
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        
        // Create the barn structure
        createBarnScene(scnView: scnView, ammoniaPPM: ammoniaPPM)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update heat map colors if needed
    }
    
    func createBarnScene(scnView: SCNView, ammoniaPPM: Int) {
        guard let scene = scnView.scene else { return }
        
        // Create barn floor
        let floorGeometry = SCNBox(width: 10, height: 0.2, length: 6, chamferRadius: 0)
        floorGeometry.firstMaterial?.diffuse.contents = UIColor.brown.withAlphaComponent(0.5)
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(floorNode)
        
        // Create barn walls (transparent to see inside)
        let wallMaterial = SCNMaterial()
        wallMaterial.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
        wallMaterial.transparency = 0.2
        
        // Back wall
        let backWall = SCNBox(width: 10, height: 5, length: 0.2, chamferRadius: 0)
        backWall.firstMaterial = wallMaterial
        let backWallNode = SCNNode(geometry: backWall)
        backWallNode.position = SCNVector3(0, 2.5, -3)
        scene.rootNode.addChildNode(backWallNode)
        
        // Side walls
        let sideWall = SCNBox(width: 0.2, height: 5, length: 6, chamferRadius: 0)
        sideWall.firstMaterial = wallMaterial
        
        let leftWallNode = SCNNode(geometry: sideWall)
        leftWallNode.position = SCNVector3(-5, 2.5, 0)
        scene.rootNode.addChildNode(leftWallNode)
        
        let rightWallNode = SCNNode(geometry: sideWall)
        rightWallNode.position = SCNVector3(5, 2.5, 0)
        scene.rootNode.addChildNode(rightWallNode)
        
        // Create roof
        let roofGeometry = SCNBox(width: 10, height: 0.2, length: 6, chamferRadius: 0)
        roofGeometry.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.3)
        let roofNode = SCNNode(geometry: roofGeometry)
        roofNode.position = SCNVector3(0, 5, 0)
        scene.rootNode.addChildNode(roofNode)
        
        // Create heat map particles/zones
        createHeatMapZones(scene: scene, ammoniaPPM: ammoniaPPM)
        
        // Add some cows for context
        createCows(scene: scene)
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 8, y: 8, z: 12)
        cameraNode.look(at: SCNVector3(0, 2, 0))
        scene.rootNode.addChildNode(cameraNode)
        
        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 500
        scene.rootNode.addChildNode(ambientLight)
    }
    
    func createHeatMapZones(scene: SCNScene, ammoniaPPM: Int) {
        // Create a grid of heat zones showing ammonia concentration
        let gridSize = 5
        let spacing: Float = 2.0
        
        for x in 0..<gridSize {
            for z in 0..<gridSize {
                for y in 0..<3 { // 3 vertical layers
                    let xPos = Float(x) * spacing - Float(gridSize - 1) * spacing / 2
                    let yPos = Float(y) * spacing + 1.0
                    let zPos = Float(z) * spacing - Float(gridSize - 1) * spacing / 2
                    
                    // Simulate varying ammonia concentration
                    // Higher concentration near floor and back
                    let heightFactor = Float(3 - y) / 3.0 // More at bottom
                    let depthFactor = (Float(z) + 2) / Float(gridSize + 2) // More at back
                    let randomFactor = Float.random(in: 0.7...1.3)
                    
                    let localPPM = Float(ammoniaPPM) * heightFactor * depthFactor * randomFactor
                    
                    // Create sphere for each zone
                    let sphere = SCNSphere(radius: 0.4)
                    let color = getHeatMapColor(ppm: Int(localPPM))
                    sphere.firstMaterial?.diffuse.contents = color
                    sphere.firstMaterial?.transparency = 0.6
                    sphere.firstMaterial?.emission.contents = color
                    
                    let sphereNode = SCNNode(geometry: sphere)
                    sphereNode.position = SCNVector3(xPos, yPos, zPos)
                    scene.rootNode.addChildNode(sphereNode)
                    
                    // Add pulsing animation
                    let scaleUp = SCNAction.scale(to: 1.2, duration: 1.5)
                    let scaleDown = SCNAction.scale(to: 1.0, duration: 1.5)
                    let pulse = SCNAction.sequence([scaleUp, scaleDown])
                    let repeatPulse = SCNAction.repeatForever(pulse)
                    sphereNode.runAction(repeatPulse)
                }
            }
        }
    }
    
    func createCows(scene: SCNScene) {
        // Add simple cow representations
        let cowPositions = [
            SCNVector3(-3, 0.5, 1),
            SCNVector3(-1, 0.5, -1),
            SCNVector3(2, 0.5, 0),
            SCNVector3(3, 0.5, 2)
        ]
        
        for position in cowPositions {
            // Cow body
            let body = SCNBox(width: 0.8, height: 0.6, length: 1.2, chamferRadius: 0.1)
            body.firstMaterial?.diffuse.contents = UIColor.brown
            let bodyNode = SCNNode(geometry: body)
            bodyNode.position = position
            scene.rootNode.addChildNode(bodyNode)
            
            // Cow head
            let head = SCNBox(width: 0.4, height: 0.4, length: 0.4, chamferRadius: 0.05)
            head.firstMaterial?.diffuse.contents = UIColor.brown
            let headNode = SCNNode(geometry: head)
            headNode.position = SCNVector3(position.x, position.y + 0.3, position.z + 0.8)
            scene.rootNode.addChildNode(headNode)
        }
    }
    
    func getHeatMapColor(ppm: Int) -> UIColor {
        if ppm < 20 {
            // Green to yellow gradient
            let ratio = CGFloat(ppm) / 20.0
            return UIColor(
                red: ratio,
                green: 1.0,
                blue: 0,
                alpha: 1.0
            )
        } else if ppm < 50 {
            // Yellow to orange gradient
            let ratio = CGFloat(ppm - 20) / 30.0
            return UIColor(
                red: 1.0,
                green: 1.0 - (ratio * 0.5),
                blue: 0,
                alpha: 1.0
            )
        } else {
            // Orange to red gradient
            let ratio = min(CGFloat(ppm - 50) / 50.0, 1.0)
            return UIColor(
                red: 1.0,
                green: 0.5 - (ratio * 0.5),
                blue: 0,
                alpha: 1.0
            )
        }
    }
}

// MARK: - Control Button
struct ControlButton: View {
    let icon: String
    let label: String
    let value: String
    @Binding var isActive: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isActive.toggle()
            }
            // Add haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(isActive ? .white : .gray)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isActive ? .white : .gray)
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isActive ? .white.opacity(0.9) : .gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(isActive ? Color.green : Color.gray.opacity(0.2))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isActive ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .scaleEffect(isActive ? 1.0 : 0.98)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Sensor Card View
struct SensorCardView: View {
    let sensor: Sensor
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(sensor.name)
                    .font(.headline)
                Text(sensor.status)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if sensor.status == "On" {
                Text("\(sensor.ammoniaPPM) ppm")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(sensor.ammoniaPPM < 20 ? .green : sensor.ammoniaPPM < 50 ? .orange : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Ammonia Detail View
struct AmmoniaDetailView: View {
    @State private var ventDownTemp: Double = 22.25
    @State private var beddingHeight: Double = 0
    @State private var ammoniaLevel: Double = 8
    
    let ammoniaReadings: [AmmoniaReading] = [
        AmmoniaReading(date: "1/8", safe: 5, warning: 3, critical: 1),
        AmmoniaReading(date: "8/8", safe: 7, warning: 2, critical: 1.5),
        AmmoniaReading(date: "15/8", safe: 4, warning: 4, critical: 2),
        AmmoniaReading(date: "22/8", safe: 6, warning: 3, critical: 1),
        AmmoniaReading(date: "29/8", safe: 8, warning: 2, critical: 1.5),
        AmmoniaReading(date: "5/9", safe: 5, warning: 4, critical: 2)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Vent Down Temperature
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vent Down temperature: \(String(format: "%.2f", ventDownTemp))°C")
                            .font(.headline)
                        
                        HStack {
                            Text("0 °C")
                                .font(.caption)
                            
                            Slider(value: $ventDownTemp, in: 0...40)
                                .accentColor(.green)
                            
                            Text("40 °C")
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Bedding Height
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bedding height")
                            .font(.headline)
                        
                        HStack {
                            Text("0 °C")
                                .font(.caption)
                            
                            Slider(value: $beddingHeight, in: 0...100)
                                .accentColor(.green)
                            
                            Text("100")
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Ammonia Level
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ammonia level")
                            .font(.headline)
                        
                        Text("\(Int(ammoniaLevel)) %")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("0 °C")
                                .font(.caption)
                            
                            Slider(value: $ammoniaLevel, in: 0...50)
                                .accentColor(.green)
                            
                            Text("50")
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Ammonia Trend Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ammonia Trend")
                            .font(.headline)
                        
                        Chart {
                            ForEach(ammoniaReadings) { reading in
                                LineMark(
                                    x: .value("Date", reading.date),
                                    y: .value("Safe", reading.safe)
                                )
                                .foregroundStyle(.green)
                                
                                LineMark(
                                    x: .value("Date", reading.date),
                                    y: .value("Warning", reading.warning)
                                )
                                .foregroundStyle(.orange)
                                
                                LineMark(
                                    x: .value("Date", reading.date),
                                    y: .value("Critical", reading.critical)
                                )
                                .foregroundStyle(.red)
                            }
                        }
                        .frame(height: 200)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        
                        // Legend
                        HStack(spacing: 16) {
                            LegendItem(color: .green, label: "Healthy (< 20ppm)")
                            LegendItem(color: .orange, label: "Medium (20-50ppm)")
                            LegendItem(color: .red, label: "Critical (> 50ppm)")
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Ammonia")
        }
    }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
}

// MARK: - Add Barn View
struct AddBarnView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var barns: [Barn]
    
    @State private var barnName = ""
    @State private var targetTemp = 25.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Barn Information") {
                    TextField("Barn Name", text: $barnName)
                    
                    HStack {
                        Text("Target Temperature")
                        Spacer()
                        Text("\(Int(targetTemp))°C")
                    }
                    Slider(value: $targetTemp, in: 15...35, step: 1)
                }
            }
            .navigationTitle("Add Barn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newBarn = Barn(
                            name: barnName.isEmpty ? "Barn \(barns.count + 1)" : barnName,
                            imageName: "barn\(barns.count + 1)",
                            currentTemp: targetTemp,
                            targetTemp: targetTemp,
                            humidity: 50,
                            ammoniaPPM: 5,
                            ventStatus: "Off"
                        )
                        barns.append(newBarn)
                        dismiss()
                    }
                }
            }
        }
    }
}
