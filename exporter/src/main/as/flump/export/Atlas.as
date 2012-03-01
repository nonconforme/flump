//
// Flump - Copyright 2012 Three Rings Design

package flump.export {

import flash.display.Sprite;
import flash.filesystem.File;
import flash.geom.Rectangle;

import flump.SwfTexture;

public class Atlas
{
    public var name :String;
    public var w :int, h :int, id :int;

    public function Atlas(name :String, w :int, h :int) {
        this.name = name;
        this.w = w;
        this.h = h;

        _root = new Node();
        _root.bounds = new Rectangle(0, 0, w, h);
    }

    // Try to place a texture in this atlas, return true if it fit
    public function place (texture :SwfTexture) :Boolean {
        var node :Node = _root.search(new Rectangle(0, 0, texture.w, texture.h));
        if (node == null) {
            return false;
        }

        node.texture = texture;
        return true;
    }

    public function publish (dir :File) :void {
        var constructed :Sprite = new Sprite();
        _root.forEach(function (node :Node) :void {
            var tex :SwfTexture = node.texture;
            constructed.addChild(tex.holder);
            tex.holder.x = node.bounds.x;
            tex.holder.y = node.bounds.y;
        });
        PngPublisher.publish(dir.resolvePath(name + ".png"), w, h, constructed);
    }

    public function toXml () :String {
        var xml :String = '<atlas name="' + name + '" filename="' + name + '.png">\n';
        _root.forEach(function (node :Node) :void {
            var tex :SwfTexture = node.texture;
            xml += '  <texture name="' + tex.libraryItem + '" xOffset="' + tex.offset.x +
                '" yOffset="' + tex.offset.y + '" md5="' + tex.md5 +
                '" xAtlas="' + node.bounds.x + '" yAtlas="' + node.bounds.y +
                '" wAtlas="' + tex.w + '" hAtlas="' + tex.h + '"/>\n';
        });
        return xml + '</atlas>\n';
    }

    public function toJSON (_:*) :Object {
        var json :Object = {
            file: name + ".png",
            textures: []
        };
        _root.forEach(function (node :Node) :void {
            var tex :SwfTexture = node.texture;
            json.textures.push({
                name: tex.symbol,
                offset: [ tex.offset.x, tex.offset.y ],
                rect: [ node.bounds.x, node.bounds.y, tex.w, tex.h ]
            });
        });
        return json;
    }

    protected var _root :Node;
}
}

import flash.geom.Rectangle;

import flump.SwfTexture;

// A node in a k-d tree
class Node
{
    // The bounds of this node (and its children)
    public var bounds :Rectangle;

    // The texture that is placed here, if any
    public var texture :SwfTexture;

    // This node's two children
    public var left :Node;
    public var right :Node;

    // Find for free node in this tree big enough to fit a rect, or null
    public function search (rect :Rectangle) :Node
    {
        // There's already a texture here, terminate
        if (texture != null) {
            return null;
        }

        if (left != null && right != null) {
            // Try to fit it into this node's children
            var descendent :Node = left.search(rect);
            if (descendent == null) {
                descendent = right.search(rect);
            }
            return descendent;

        } else {
            if (bounds.width == rect.width && bounds.height == rect.height) {
                return this;
            }
            if (bounds.width < rect.width || bounds.height < rect.height) {
                return null;
            }

            left = new Node();
            right = new Node();

            var dw :Number = bounds.width - rect.width;
            var dh :Number = bounds.height - rect.height;

            if (dw > dh) {
                left.bounds = new Rectangle(
                    bounds.x,
                    bounds.y,
                    rect.width,
                    bounds.height);

                right.bounds = new Rectangle(
                    bounds.x + rect.width,
                    bounds.y,
                    bounds.width - rect.width,
                    bounds.height);

            } else {
                left.bounds = new Rectangle(
                    bounds.x,
                    bounds.y,
                    bounds.width,
                    rect.height);

                right.bounds = new Rectangle(
                    bounds.x,
                    bounds.y + rect.height,
                    bounds.width,
                    bounds.height - rect.height);
            }

            return left.search(rect);
        }
    }

    // Iterate over all nodes with textures in this tree
    public function forEach (fn :Function /* Node -> void */) :void {
        if (texture != null) {
            fn(this);
        }

        if (left != null && right != null) {
            left.forEach(fn);
            right.forEach(fn);
        }
    }
}