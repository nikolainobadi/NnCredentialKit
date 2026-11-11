struct DefaultNonceProvider: NonceProvider {
    func make() -> String {
        return NonceFactory.randomNonceString()
    }
    
    func hash(_ value: String) -> String {
        return NonceFactory.sha256(value)
    }
}
