//
// Flump - Copyright 2012 Three Rings Design

package flump.mold {

import flash.geom.Point;
import flash.geom.Rectangle;

public class AtlasTextureMold
{
    public var name :String;
    public var bounds :Rectangle;
    public var offset :Point;
    public var md5 :String;

    public function toJSON (_:*) :Object {
        return {
            name: name,
            rect: [bounds.x, bounds.y, bounds.width, bounds.height],
            offset: [offset.x, offset.y],
            md5: md5
        };
    }

    public static function fromJSON (o :Object) :AtlasTextureMold {
        const mold :AtlasTextureMold = new AtlasTextureMold();
        mold.name = require(o, "name");
        const rect :Array = require(o, "rect");
        mold.bounds = new Rectangle(rect[0], rect[1], rect[2], rect[3]);
        const off :Array = require(o, "offset");
        mold.offset = new Point(off[0], off[1]);
        mold.md5 = require(o, "md5");
        return mold;
    }

    public function toXML () :XML {
        const json :Object = toJSON(null);
        return <texture name={name} rect={json.rect} offset={json.offset} md5={md5} />;
    }

}
}
