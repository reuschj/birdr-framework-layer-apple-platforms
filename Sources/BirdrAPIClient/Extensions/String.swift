extension String {
    var escaped: String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    }
}
