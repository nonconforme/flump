//
// Flump - Copyright 2012 Three Rings Design

package flump.xfl {

public class XflLayer extends XflComponent
{
    use namespace xflns;

    public var name :String;
    public const keyframes :Vector.<XflKeyframe> = new Vector.<XflKeyframe>();
    public var flipbook :Boolean;

    public function XflLayer (baseLocation :String, xml :XML, errors :Vector.<ParseError>,
        flipbook :Boolean) {
        name = new XmlConverter(xml).getStringAttr("name");
        this.flipbook = flipbook;
        super(baseLocation + ":" + name, errors);
        for each (var frameEl :XML in xml.frames.DOMFrame) {
            keyframes.push(new XflKeyframe(location, frameEl, _errors, flipbook));
        }
        if (keyframes.length == 0) addError(ParseError.INFO, "No keyframes on layer");
    }

    public function get frames () :int {
        const lastKf :XflKeyframe = keyframes[keyframes.length - 1];
        return lastKf.index + lastKf.duration;
    }

    public function checkSymbols (lib :XflLibrary) :void {
        for each (var kf :XflKeyframe in keyframes) kf.checkSymbols(lib);
    }

    public function toJSON (_:*) :Object {
        return {
            name: name,
            flipbook: flipbook,
            keyframes: keyframes
        };
    }
}
}