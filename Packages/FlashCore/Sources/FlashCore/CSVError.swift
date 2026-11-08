public enum CSVError: Error, Equatable {
    /// The file's bytes aren't valid UTF-8; other encodings aren't supported.
    case notUTF8
}
