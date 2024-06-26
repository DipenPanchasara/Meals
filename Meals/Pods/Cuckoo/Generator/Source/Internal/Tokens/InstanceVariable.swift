public struct InstanceVariable: Token, HasAccessibility, HasAttributes {
    public struct Effects {
        public var isThrowing = false
        public var isAsync = false
    }

    public var name: String
    public var type: WrappableType
    public var accessibility: Accessibility
    public var setterAccessibility: Accessibility?
    public var effects: Effects
    public var range: CountableRange<Int>
    public var nameRange: CountableRange<Int>
    public var overriding: Bool
    public var attributes: [Attribute]

    public var readOnly: Bool {
        if let setterAccessibility = setterAccessibility {
            return !setterAccessibility.isAccessible
        } else {
            return true
        }
    }

    public func isEqual(to other: Token) -> Bool {
        guard let other = other as? InstanceVariable else { return false }
        return self.name == other.name
    }

    public func serialize() -> [String: Any] {
        let readOnlyVerifyString = readOnly ? "ReadOnly" : ""
        let readOnlyStubString = effects.isThrowing ? "" : readOnlyVerifyString
        let optionalString = type.isOptional && !readOnly ? "Optional" : ""
        let throwingString = effects.isThrowing ? "Throwing" : ""

        return [
            "name": name,
            "type": type.sugarized,
            "nonOptionalType": type.unoptionaled.sugarized,
            "accessibility": accessibility.sourceName,
            "isReadOnly": readOnly,
            "isAsync": effects.isAsync,
            "isThrowing": effects.isThrowing,
            "stubType": (overriding ? "Class" : "Protocol") + "ToBeStubbed\(readOnlyStubString)\(optionalString)\(throwingString)Property",
            "verifyType": "Verify\(readOnlyVerifyString)\(optionalString)Property",
            "attributes": attributes.filter { $0.isSupported },
            "hasUnavailablePlatforms": hasUnavailablePlatforms,
            "unavailablePlatformsCheck": unavailablePlatformsCheck
        ]
    }
}
