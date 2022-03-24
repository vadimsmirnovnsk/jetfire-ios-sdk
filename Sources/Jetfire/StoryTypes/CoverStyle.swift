import UIKit
import VNEssential

public struct CoverStyle: IPopulatable {

	public typealias T = CoverStyle

	public var size: CGSize
	public var sectionInset: UIEdgeInsets
	public var interItemOffset: CGFloat
	public var bgColor: UIColor

	public var substrate: CoverSubstrate
	public var readSubstrate: CoverSubstrate
	public var image: CoverImage
	public var title: CoverTitle
	public var gradient: CoverGradient?

	public init(
		size: CGSize,
		sectionInset: UIEdgeInsets,
		interItemOffset: CGFloat,
		bgColor: UIColor,
		substrate: CoverSubstrate,
		readSubstrate: CoverSubstrate,
		image: CoverImage,
		title: CoverTitle,
		gradient: CoverGradient? = nil
	) {
		self.size = size
		self.sectionInset = sectionInset
		self.interItemOffset = interItemOffset
		self.bgColor = bgColor
		self.substrate = substrate
		self.readSubstrate = readSubstrate
		self.image = image
		self.title = title
		self.gradient = gradient
	}

	static func instagram() -> CoverStyle {
		let substrate = CoverSubstrate(
			size: CGSize(width: 68, height: 68),
			cornerRadius: 68 / 2,
			width: 4,
			centerInset: CGPoint(x: 0, y: -(100 - 68) / 2 + 8),
			startColor: .gradientYellow,
			endColor: .gradientOrange,
			startPoint: CGPoint(x: 0, y: 0),
			endPoint: CGPoint(x: 1, y: 1)
		)

		let readSubstrate = CoverSubstrate(
			size: CGSize(width: 68, height: 68),
			cornerRadius: 68 / 2,
			width: 2,
			centerInset: CGPoint(x: 0, y: -(100 - 68) / 2 + 8),
			startColor: .lightGray,
			endColor: .lightGray,
			startPoint: CGPoint(x: 0, y: 0),
			endPoint: CGPoint(x: 1, y: 1)
		)

		let image = CoverImage(
			size: CGSize(width: 60, height: 60),
			cornerRadius: 30,
			centerInset: CGPoint(x: 0, y: -(100 - 68) / 2 + 8),
			readAlpha: 0.7
		)

		let title: CoverTitle = CoverTitle(
			textStyle: .system13GraffitBlack,
			textAlignment: .center,
			linesNumber: 1,
			bottomInset: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
		)

		return CoverStyle(
		   size: CGSize(width: 80, height: 100),
		   sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
		   interItemOffset: 8,
		   bgColor: .storiesAlmostWhite,
		   substrate: substrate,
		   readSubstrate: readSubstrate,
		   image: image,
		   title: title
		)
	}

	static func delo() -> CoverStyle {
		let substrate = CoverSubstrate(
			size: CGSize(width: 102, height: 102),
			cornerRadius: 15,
			width: 2,
			centerInset: CGPoint(x: 0, y: 0),
			startColor: .deloBlue,
			endColor: .deloBlue,
			startPoint: CGPoint(x: 0, y: 0),
			endPoint: CGPoint(x: 1, y: 1)
		)

		let readSubstrate =  CoverSubstrate(
			size: CGSize(width: 102, height: 102),
			cornerRadius: 10,
			width: 0,
			centerInset: CGPoint(x: 0, y: 0),
			startColor: .clear,
			endColor: .clear,
			startPoint: CGPoint(x: 0, y: 0),
			endPoint: CGPoint(x: 1, y: 1)
		)

		let image = CoverImage(
			size: CGSize(width: 96, height: 96),
			cornerRadius: 12,
			centerInset: .zero,
			readAlpha: 1
		)

		let title: CoverTitle = CoverTitle(
			textStyle: .system13White,
			textAlignment: .left,
			linesNumber: 4,
			bottomInset: UIEdgeInsets(top: 0, left: 9, bottom: 12, right: 9)
		)

		let gradient = CoverGradient(
			size: CGSize(width: 96, height: 64),
			cornerRadius: 12,
			centerInset: CGPoint(x: 0, y: 16),
			startColor: UIColor.black.withAlphaComponent(0),
			endColor: UIColor.black.withAlphaComponent(0.7),
			startPoint: CGPoint(x: 0.5, y: 0),
			endPoint: CGPoint(x: 0.5, y: 1)
		)

		return CoverStyle(
		   size: CGSize(width: 104, height: 104),
		   sectionInset: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
		   interItemOffset: 8,
		   bgColor: .black,
		   substrate: substrate,
		   readSubstrate: readSubstrate,
		   image: image,
		   title: title,
		   gradient: gradient
		)
	}

}

public struct CoverImage: IPopulatable {

	public typealias T = CoverImage

	public var size: CGSize
	public var cornerRadius: CGFloat
	public var centerInset: CGPoint
	public var readAlpha: CGFloat

	public init(
		size: CGSize,
		cornerRadius: CGFloat,
		centerInset: CGPoint,
		readAlpha: CGFloat
	) {
		self.size = size
		self.cornerRadius = cornerRadius
		self.centerInset = centerInset
		self.readAlpha = readAlpha
	}

}

public struct CoverTitle: IPopulatable {

	public typealias T = CoverTitle

	public var textStyle: TextStyle = .system13GraffitBlack
	public var textAlignment: NSTextAlignment
	public var linesNumber: Int
	public var bottomInset: UIEdgeInsets

	public init(
		textStyle: TextStyle,
		textAlignment: NSTextAlignment,
		linesNumber: Int,
		bottomInset: UIEdgeInsets
	) {
		self.textStyle = textStyle
		self.textAlignment = textAlignment
		self.linesNumber = linesNumber
		self.bottomInset = bottomInset
	}

}

public struct CoverSubstrate: IPopulatable {

	public typealias T = CoverSubstrate

	public var size: CGSize
	public var cornerRadius: CGFloat
	public var width: CGFloat
	public var centerInset: CGPoint
	public var startColor: UIColor
	public var endColor: UIColor
	public var startPoint: CGPoint
	public var endPoint: CGPoint

	init(
		size: CGSize,
		cornerRadius: CGFloat,
		width: CGFloat,
		centerInset: CGPoint,
		startColor: UIColor,
		endColor: UIColor,
		startPoint: CGPoint,
		endPoint: CGPoint
	) {
		self.size = size
		self.cornerRadius = cornerRadius
		self.width = width
		self.centerInset = centerInset
		self.startColor = startColor
		self.endColor = endColor
		self.startPoint = startPoint
		self.endPoint = endPoint
	}

}

public struct CoverGradient: IPopulatable {

	public typealias T = CoverSubstrate

	public var size: CGSize
	public var cornerRadius: CGFloat
	public var centerInset: CGPoint
	public var startColor: UIColor
	public var endColor: UIColor
	public var startPoint: CGPoint
	public var endPoint: CGPoint

	init(
		size: CGSize,
		cornerRadius: CGFloat,
		centerInset: CGPoint,
		startColor: UIColor,
		endColor: UIColor,
		startPoint: CGPoint,
		endPoint: CGPoint
	) {
		self.size = size
		self.cornerRadius = cornerRadius
		self.centerInset = centerInset
		self.startColor = startColor
		self.endColor = endColor
		self.startPoint = startPoint
		self.endPoint = endPoint
	}

}
