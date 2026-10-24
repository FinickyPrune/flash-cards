/// Subtitle lines used as ground truth. Serbian is Latin script (ekavian) and covers
/// č ć š ž đ plus the digraphs dž, lj, nj; English covers apostrophes and punctuation.
enum Corpus {
    static let serbian = [
        "Gde si bio celu noć? Čekala sam te do jutra.",
        "Ne znam šta da kažem, ovo je stvarno čudno.",
        "Đorđe je rekao da će doći kasnije.",
        "Moraćeš da mi veruješ, nemamo vremena.",
        "Žao mi je, nisam htela da te povredim.",
        "Kuća je prazna, svi su otišli na more.",
        "Šta ćeš da radiš sutra posle posla?",
        "Džep mi je pun sitnog novca.",
        "Ćuti i slušaj šta ti govorim.",
        "Njegova žena radi u bolnici već deset godina.",
        "Hajde, požuri, zakasnićemo na voz!",
        "Ljubav nije dovoljna, znaš to i sama.",
        "Čovek koji je živeo ovde umro je prošle zime.",
        "Da li si video moj ključ? Ne mogu da ga nađem.",
        "Đaci su već ušli u učionicu.",
        "Ovo je najlepši dan u mom životu.",
        "Izvini, gospođo, gde je železnička stanica?",
        "Nećeš verovati ko me je zvao jutros.",
        "Treba mi tvoja pomoć, molim te.",
        "Pričaćemo o tome kad se vratiš kući.",
    ]

    static let english = [
        "I don't think we should be here.",
        "What're you doing tonight? Anything fun?",
        "He's been gone for three days, nobody knows where.",
        "You can't just walk away from this.",
        "We'll figure it out tomorrow, I promise.",
        "Where did you put the car keys?",
        "She said it wasn't her fault.",
        "Honestly, I'd rather stay home and sleep.",
        "Don't touch that! It's still hot.",
        "They're waiting for us downstairs.",
        "It's not about the money, it never was.",
        "Could you turn the music down a little?",
        "I've never seen anything like it.",
        "Let's get out of here before it's too late.",
        "Why didn't you tell me the truth?",
    ]

    /// Splits a sentence into one or two subtitle lines, the way players wrap long subtitles.
    static func lines(for sentence: String, maxChars: Int) -> [String] {
        guard sentence.count > maxChars else { return [sentence] }
        let words = sentence.split(separator: " ").map(String.init)
        var best = (index: 1, balance: Int.max)
        for index in 1 ..< words.count {
            let first = words[..<index].joined(separator: " ").count
            let second = words[index...].joined(separator: " ").count
            if abs(first - second) < best.balance {
                best = (index, abs(first - second))
            }
        }
        return [
            words[..<best.index].joined(separator: " "),
            words[best.index...].joined(separator: " "),
        ]
    }
}
