public protocol IReviewCommentGenerator {
	func generate(for username: String) -> String
}

// MARK: - Greeting

enum Greeting {
	case empty
	case title(text: String)

	static let all: [Greeting] = [
		empty,
		title(text: "%USERNAME%"),
		title(text: "добрый день"),
		title(text: "здравствуйте"),
		title(text: "здравствуйте, %USERNAME%"),
		title(text: "%USERNAME%, здравствуйте"),
		title(text: "%USERNAME%, добрый день"),
		title(text: "добрый вечер"),
		title(text: "добрый вечер, %USERNAME%")
	]

	var hasUsername: Bool {
		switch self {
		case .empty: return false
		case .title(let text): return text.contains("%USERNAME%")
		}
	}

	var isEmpty: Bool {
		switch self {
		case .empty: return true
		case .title: return false
		}
	}

	var text: String {
		switch self {
		case .empty: return ""
		case .title(let text): return text
		}
	}
}

// MARK: - Mark

enum Mark {
	case emoji(text: String)
	case symbol(text: String)

	static let onGreeting: [Mark] = [
		symbol(text: "."),
		symbol(text: ","),
		symbol(text: "!")
	]

	static let onForWhat: [Mark] = [
		symbol(text: "."),
		symbol(text: ","),
		symbol(text: "!"),
		emoji(text: "😉"),
		emoji(text: "🤗"),
		emoji(text: "😌"),
		emoji(text: "🙏👌"),
		symbol(text: "!!!"),
		emoji(text: "🔥")
	]

	static let onAddition: [Mark] = [
		symbol(text: "."),
		emoji(text: "♥️"),
		emoji(text: "🤗"),
		emoji(text: "😁"),
		emoji(text: "🙏🏼"),
		emoji(text: "🌸"),
		emoji(text: "🤝"),
		symbol(text: "!"),
		emoji(text: "😉")
	]

	var isEmoji: Bool {
		switch self {
		case .emoji: return true
		case .symbol: return false
		}
	}

	var text: String {
		switch self {
		case .symbol(let text): return text
		case .emoji(let text): return text
		}
	}

	var shouldUppercase: Bool {
		switch self {
		case .symbol(let text): return text != ","
		case .emoji: return true
		}
	}
}

// MARK: - Thanks

enum Thanks {
	case title(text: String)

	static let all: [Thanks] = [
		title(text: "благодарим вас"),
		title(text: "спасибо, %USERNAME%,"),
		title(text: "спасибо вам"),
		title(text: "благодарим"),
		title(text: "спасибо"),
		title(text: "спасибо большое"),
		title(text: "спасибо вам большое"),
		title(text: "большое спасибо"),
		title(text: "огромное спасибо")
	]

	var hasUsername: Bool {
		switch self {
		case .title(let text): return text.contains("%USERNAME%")
		}
	}

	var text: String {
		switch self {
		case .title(let text): return text
		}
	}
}

// MARK: - ForWhat

enum ForWhat {

	case empty
	case title(text: String)

	static let all: [ForWhat] = [
		empty,
		title(text: "за отзыв"),
		title(text: ", что оценили"),
		title(text: "за ваш отзыв"),
		title(text: "за высокую оценку"),
		title(text: "за доверие"),
		title(text: "за добрые слова"),
		title(text: "за теплые слова"),
		title(text: "за приятный отзыв"),
		title(text: ", что выбрали нас"),
		title(text: "за ваш отзыв и оценку"),
		title(text: "за отзыв и оценку"),
		title(text: "за отзыв и высокую оценку"),
		title(text: ", что выбираете нас"),
		title(text: "за добрые слова о нашей работе"),
		title(text: "за такой приятный отзыв"),
		title(text: "за приятный отклик"),
		title(text: ", что уделили время и написали отзыв"),
		title(text: ", очень приятно получать обратную связь")
	]

	var text: String {
		switch self {
		case .empty: return ""
		case .title(let text): return text
		}
	}

	var isEmpty: Bool {
		switch self {
		case .empty: return true
		case .title: return false
		}
	}

}

// MARK: - Addition

enum Addition {

	case empty
	case title(text: String)

	static let all: [Addition] = [
		empty,
		title(text: "очень приятно"),
		title(text: "мы старались"),
		title(text: "ждём вас снова"),
		title(text: "успехов вам"),
		title(text: "ждём вас вновь"),
		title(text: "ждём снова"),
		title(text: "приходите в гости ещё"),
		title(text: "рады были вам помочь"),
		title(text: "всегда рады помочь"),
		title(text: "будем вас ждать"),
		title(text: "мы стараемся"),
		title(text: "приезжайте ещё"),
		title(text: "будем ждать вас снова"),
		title(text: "ждём вас снова"),
		title(text: "приходите ещё"),
		title(text: "всегда вам рады"),
		title(text: "были рады помочь"),
		title(text: "рады стараться"),
		title(text: "рады сотрудничеству"),
		title(text: "ждём вас в гости снова"),
		title(text: "нам очень приятно"),
		title(text: "обращайтесь"),
		title(text: "всегда рады вам"),
		title(text: "нам очень приятно"),
		title(text: "будьте здоровы"),
		title(text: "приходите, будем рады вас видеть"),
		title(text: "будем рады вам всегда"),
		title(text: "были рады вас видеть"),
		title(text: "были рады знакомству"),
		title(text: "очень приятно, рады сотрудничать"),
		title(text: "рады работать для вас"),
		title(text: "мы всегда вам рады"),
		title(text: "будем стараться и дальше"),
		title(text: "мы рады, что вам всё понравилось"),
		title(text: "приходите к нам ещё"),
		title(text: "приходите к нам ещё, всегда рады"),
		title(text: "и, конечно же, ждем вас снова"),
		title(text: "приходите к нам почаще"),
		title(text: "ждём вас к нам за новыми покупками"),
		title(text: "ждем вас в гости снова и снова"),
		title(text: "рады видеть вас снова"),
		title(text: "мы работаем для вас"),
		title(text: "будем рады видеть вас в числе наших постоянных клиентов")
	]

	var text: String {
		switch self {
		case .empty: return ""
		case .title(let text): return text
		}
	}

	var isEmpty: Bool {
		switch self {
		case .empty: return true
		case .title: return false
		}
	}

}

// MARK: - Answer

struct Answer {

	let username: String
	let greetingPart: (greeting: Greeting, mark: Mark)
	let thanksPart: (thanks: Thanks, forWhat: ForWhat, mark: Mark)
	let additionPart: (addition: Addition, mark: Mark)

	var text: String {
		var text = ""
		if !greetingPart.greeting.isEmpty {
			text.append(greetingPart.greeting.text)
			text.append(greetingPart.mark.text)
		}

		let thanks = greetingPart.mark.shouldUppercase
			? thanksPart.thanks.text.uppercasedFirst()
			: thanksPart.thanks.text.lowercasedFirst()
		if !text.isEmpty && !thanks.starts(with: ",") { text.append(" ") }
		text.append(thanks)

		if !thanksPart.forWhat.isEmpty {
			if !thanksPart.forWhat.text.starts(with: ",") { text.append(" ") }
			text.append(thanksPart.forWhat.text)
		}

		if !thanksPart.forWhat.isEmpty || !thanksPart.thanks.hasUsername {
			if thanksPart.mark.isEmoji { text.append(" ") }
			text.append(thanksPart.mark.text)
		}

		if !additionPart.addition.isEmpty {
			if !additionPart.addition.text.starts(with: ",") { text.append(" ") }
			let addition = thanksPart.mark.shouldUppercase
				? additionPart.addition.text.uppercasedFirst()
				: additionPart.addition.text.lowercasedFirst()
			text.append(addition)
			if additionPart.mark.isEmoji { text.append(" ") }
			text.append(additionPart.mark.text)
		}

		text = text
			.replacingOccurrences(of: "%USERNAME%", with: username)
			.uppercasedFirst()

		return text
	}
}

// MARK: - ReviewCommentGenerator

class PositiveReviewCommentGenerator: IReviewCommentGenerator {

	required init() {}

	func generate(for username: String) -> String {
		// Структура ответа: Optional Greeting + Mark + Thanks + ForWhat + Mark + Optional Addition + Mark
		// В отзыве не может быть 2 эмоджи. На конце отзыва не может быть запятой.
		// В отзыве не может быть двух %USERNAME%. После точки или эмоджи апперкейсим текст
		let greeting = Greeting.all.randomOrFirst()
		let greetingMark = Mark.onGreeting.randomOrFirst()
		let thanks = Thanks.allowed(for: greeting).randomOrFirst()
		let forWhat = ForWhat.allowed(for: thanks).randomOrFirst()
		let thanksMark = Mark.onForWhat.randomOrFirst()
		let addition = Addition.allowed(for: thanks, thanksMark: thanksMark).randomOrFirst()
		let additionMark = Mark.onAdditionAllowed(forThanksMark: thanksMark).randomOrFirst()

		let answer = Answer(
			username: username,
			greetingPart: (greeting, greetingMark),
			thanksPart: (thanks, forWhat, thanksMark),
			additionPart: (addition, additionMark)
		)

		return generate(for: answer)
	}

	func generate(for answer: Answer) -> String {
		return answer.text
	}

}

struct NegativeAnswer {

	let username: String
	let greetingPart: (greeting: Greeting, mark: Mark)
	let thanksPart: (thanks: Thanks, forWhat: ForWhat, mark: Mark)
	let additionPart: (addition: Addition, mark: Mark)

	var text: String {
		var text = ""
		if !greetingPart.greeting.isEmpty {
			text.append(greetingPart.greeting.text)
			text.append(greetingPart.mark.text)
		}

		let thanks = greetingPart.mark.shouldUppercase
			? thanksPart.thanks.text.uppercasedFirst()
			: thanksPart.thanks.text.lowercasedFirst()
		if !text.isEmpty && !thanks.starts(with: ",") { text.append(" ") }
		text.append(thanks)

		if !thanksPart.forWhat.isEmpty {
			if !thanksPart.forWhat.text.starts(with: ",") { text.append(" ") }
			text.append(thanksPart.forWhat.text)
		}

		if !thanksPart.forWhat.isEmpty || !thanksPart.thanks.hasUsername {
			if thanksPart.mark.isEmoji { text.append(" ") }
			text.append(thanksPart.mark.text)
		}

		if !additionPart.addition.isEmpty {
			if !additionPart.addition.text.starts(with: ",") { text.append(" ") }
			let addition = thanksPart.mark.shouldUppercase
				? additionPart.addition.text.uppercasedFirst()
				: additionPart.addition.text.lowercasedFirst()
			text.append(addition)
			if additionPart.mark.isEmoji { text.append(" ") }
			text.append(additionPart.mark.text)
		}

		text = text
			.replacingOccurrences(of: "%USERNAME%", with: username)
			.uppercasedFirst()

		return text
	}
}

class NegativeReviewCommentGenerator: IReviewCommentGenerator {

	required init() {}

	func generate(for username: String) -> String {
		// Структура ответа: Optional Greeting + Mark + Thanks + ForWhat + Mark + Optional Addition + Mark
		// В отзыве не может быть 2 эмоджи. На конце отзыва не может быть запятой.
		// В отзыве не может быть двух %USERNAME%. После точки или эмоджи апперкейсим текст
		let greeting = Greeting.all.randomOrFirst()
		let greetingMark = Mark.onGreeting.randomOrFirst()
		let thanks = Thanks.allowed(for: greeting).randomOrFirst()
		let forWhat = ForWhat.allowed(for: thanks).randomOrFirst()
		let thanksMark = Mark.onForWhat.randomOrFirst()
		let addition = Addition.allowed(for: thanks, thanksMark: thanksMark).randomOrFirst()
		let additionMark = Mark.onAdditionAllowed(forThanksMark: thanksMark).randomOrFirst()

		let answer = NegativeAnswer(
			username: username,
			greetingPart: (greeting, greetingMark),
			thanksPart: (thanks, forWhat, thanksMark),
			additionPart: (addition, additionMark)
		)

		return generate(for: answer)
	}

	func generate(for answer: NegativeAnswer) -> String {
		return answer.text
	}

}

// MARK: - Thanks Extensions

extension Thanks {
	static func allowed(for greeting: Greeting) -> [Thanks] {
		return Thanks.all.filter { $0.hasUsername != greeting.hasUsername || !greeting.hasUsername }
	}
}

// MARK: - Mark Extensions

extension Mark {
	static func onAdditionAllowed(forThanksMark mark: Mark) -> [Mark] {
		return Mark.onAddition.filter { $0.isEmoji != mark.isEmoji || !mark.isEmoji }
	}
}

// MARK: - ForWhat Extensions

extension ForWhat {
	static func allowed(for thanks: Thanks) -> [ForWhat] {
		return ForWhat.all.filter { !$0.text.starts(with: ",") || !thanks.hasUsername }
	}
}

// MARK: - Addition Extensions

extension Addition {
	static func allowed(for thanks: Thanks, thanksMark: Mark) -> [Addition] {
		return Addition.all.filter { !$0.text.isEmpty || (!thanks.hasUsername && thanksMark.text != ",") }
	}
}

// MARK: - Collection Extensions

extension Collection where Index == Int {
	func randomOrFirst() -> Element {
		return self.randomElement() ?? self[0]
	}
}
