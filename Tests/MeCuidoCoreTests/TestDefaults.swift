import Foundation

/// UserDefaults aislado por prueba, para no tocar los datos reales ni mezclar pruebas.
func makeTestDefaults(_ name: String = #function) -> UserDefaults {
    let suite = "mecuido.tests.\(name).\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}
