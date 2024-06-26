#if !targetEnvironment(macCatalyst) && canImport(AppKit)
import AppKit

public struct KeyCombo: Equatable, Codable {

	// MARK: - Properties

	public var carbonKeyCode: UInt32
	public var carbonModifiers: UInt32

	public var key: Key? {
		get {
			return Key(carbonKeyCode: carbonKeyCode)
		}

		set {
			carbonKeyCode = newValue?.carbonKeyCode ?? 0
		}
	}

	public var modifiers: NSEvent.ModifierFlags {
		get {
			return NSEvent.ModifierFlags(carbonFlags: carbonModifiers)
		}

		set {
			carbonModifiers = newValue.carbonFlags
		}
	}

	public var isValid: Bool {
		return carbonKeyCode >= 0
	}

	// MARK: - Initializers

	public init(carbonKeyCode: UInt32, carbonModifiers: UInt32 = 0) {
		self.carbonKeyCode = carbonKeyCode
		self.carbonModifiers = carbonModifiers
	}

	public init(key: Key, modifiers: NSEvent.ModifierFlags = []) {
		self.carbonKeyCode = key.carbonKeyCode
		self.carbonModifiers = modifiers.carbonFlags
	}

	// MARK: - Converting Keys

	public static func carbonKeyCodeToString(_ carbonKeyCode: UInt32) -> String? {
		return nil
	}
}

extension KeyCombo {
	public var dictionary: [String: Any] {
		return [
			"keyCode": Int(carbonKeyCode),
			"modifiers": Int(carbonModifiers)
		]
	}

	public init?(dictionary: [String: Any]) {
		guard let keyCode = dictionary["keyCode"] as? Int,
			let modifiers = dictionary["modifiers"] as? Int
		else {
			return nil
		}

		self.init(carbonKeyCode: UInt32(keyCode), carbonModifiers: UInt32(modifiers))
	}
}

extension KeyCombo: CustomStringConvertible {
    public var description: String {
        var output = modifiers.description

        if let keyDescription = key?.description {
            output += keyDescription
        }

        return output
    }
}

// MARK: - UserDefaults

extension UserDefaults {
    open func keyCombo(forKey defaultName: String) -> KeyCombo? {
        guard
            let data = UserDefaults.standard.string(forKey: defaultName)?.data(using: .utf8),
            let decoded = try? JSONDecoder().decode(KeyCombo.self, from: data)
        else {
            return nil
        }

        return decoded
    }

    open func set(_ value: KeyCombo?, forKey defaultName: String) {
        guard
            let value = value,
            let encoded = try? JSONEncoder().encode(value)
        else {
            set("", forKey: defaultName)
            return
        }

        set(String(data: encoded, encoding: .utf8), forKey: defaultName)
    }
}
#endif
