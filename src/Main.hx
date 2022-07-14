@:native("")
extern class Shim {
    @:native("a") static var canvas:js.html.CanvasElement;
    @:native("c") static var context:js.html.CanvasRenderingContext2D;
}

abstract Point(Array<Float>) from Array<Float> to Array<Float> {
    public var x(get, set):Float;
    inline function get_x() return this[0];
    inline function set_x(value) return this[0] = value;
    public var y(get, set):Float;
    inline function get_y() return this[1];
    inline function set_y(value) return this[1] = value;
}

class Main {
    static function main() {
        var screenSize = 512;
        var halfSize:Int = cast screenSize/ 2;
        Shim.canvas.width = Shim.canvas.height = screenSize;
        var randomSeed = 0;
        var time:Int = 0;
        var walls:Array<Dynamic> = [];
        var camPos:Point = [screenSize, screenSize];
        var camAngle:Float = 0;
        /* var keys:Dynamic = {}; */
        var mx:Int = 0;
        var mmove:Int = 0;
        var textureCanvas:js.html.CanvasElement;
        inline function createTexture() {
            textureCanvas = untyped document.createElement("canvas");
            textureCanvas.width = textureCanvas.height = 64;
            var textureContext = textureCanvas.getContext("2d");
            textureContext.fillRect(0, 0, 64, 64);
            textureContext.fillStyle = '#a22';
            textureContext.fillRect(2, 2, 62, 30);
            textureContext.fillRect(0, 34, 30, 29);
            textureContext.fillRect(32, 50, 32, 13);
            /* textureContext.fillText('Hey!', 32, 44); */
            /* var pattern = textureContext.createPattern(textureCanvas, 'repeat'); */
            /* textureCanvas.width = textureCanvas.height = 256; */
            /* textureContext.fillStyle = pattern; */
            /* textureContext.fillRect(0, 0, 256, 256); */
        }
        createTexture();
        inline function col(n : Dynamic) {
            Shim.context.fillStyle = n;
        }
        inline function drawRect(x:Float, y:Float, w:Float, h:Float) {
            Shim.context.fillRect(x, y, w, h);
        }
        untyped onmousemove = onmousedown = onmouseup = function(e) {
            mx = e.clientX;
            mmove = (e.buttons);
        }
        /* untyped onmousemove = function(e) { */
        /*     mx = e.clientX; */
        /* } */
        /* untyped onkeydown = onkeyup = function(e) { */
        /*     keys[e.key] = e.type[3] == 'd'; */
        /* } */
        /* Shim.canvas.oncontextmenu = e->false; */
        function segmentToSegmentIntersection(from1:Point, to1:Point, from2:Point, to2:Point) {
            var dX = to1.x - from1.x;
            var dY = to1.y - from1.y;
            var determinant = dX * (to2.y - from2.y) - (to2.x - from2.x) * dY;
            /* if(determinant == 0) { return null; } */
            var lambda = ((to2.y - from2.y) * (to2.x - from1.x) + (from2.x - to2.x) * (to2.y - from1.y)) / determinant;
            var gamma = ((from1.y - to1.y) * (to2.x - from1.x) + dX * (to2.y - from1.y)) / determinant;

            if(lambda<0 || !(0 <= gamma && gamma <= 1)) { return null; }

            return [lambda, gamma];
        }
        inline function addWall(a:Float, b:Float, c:Float, d:Float, len:Float) {
            var n = walls.length;
            /* var len = Math.sqrt((c-a)*(c-a)+(d-b)*(d-b)); */
            walls[n] = [[a* 100, b * 100], [c * 100, d * 100], len * 100];
        }
        inline function drawWalls() {
            var wallH = 32;
            /* var hfov = Math.PI * 0.25; */
            /* var d = halfSize / Math.tan(hfov); */
            var d = 256;

            for(x in 0...screenSize) {
                var a2 = Math.atan2(x - halfSize, d);
                var a = camAngle + a2;
                var dx = Math.cos(a) * 1024;
                var dy = Math.sin(a) * 1024;
                var camTarget = [camPos[0]+dx, camPos[1]+dy];
                var best = null;
                var bestDistance = 100000.0;
                var bestGamma:Float = 0;

                for(w in walls) {
                    var r = segmentToSegmentIntersection(camPos, camTarget, w[0], w[1]);

                    if(untyped r) {
                        var f = Math.cos(a2) * r[0];

                        if(f<bestDistance) {
                            bestDistance = f;
                            best = w;
                            bestGamma = r[1];
                        }
                    }
                }

                if(best != null) {
                    var h = (screenSize / wallH) / bestDistance;
                    var tx = Std.int(bestGamma * best[2]) % 64;
                    //drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)
                    Shim.context.drawImage(textureCanvas, tx, 0, 1, 64, x, halfSize - h/2, 1, h);
                    /* drawRect(x, halfSize - h/2, 1, h); */
                }
            }
        }
        function loop(t:Float) {
            // controls
            {
                var a = camAngle;
                var dir:Point = [Math.cos(a), Math.sin(a)];
                /* var lat = {x:Math.cos(a + Math.PI/2), y:Math.sin(a + Math.PI/2)}; */
                /* var move = {x:0, y:0}; */
                /* if(untyped keys['w']) { */
                /*     move.y = 1; */
                /* } */
                /* if(untyped keys['s']) { */
                /*     move.y = -1; */
                /* } */
                /* if(untyped keys['d']) { */
                /*     move.x = 1; */
                /* } */
                /* if(untyped keys['a']) { */
                /*     move.x = -1; */
                /* } */
                var s = 4;
                /* camPos.x += dir.x * move.y * s; */
                /* camPos.y += dir.y * move.y * s; */
                /* camPos.x += lat.x * move.x * s; */
                /* camPos.y += lat.y * move.x * s; */
                var prevPos = [camPos.x, camPos.y];
                camPos.x += dir.x * mmove * 6;
                camPos.y += dir.y * mmove * 6;
                camAngle = mx / 32;//* 0.04;

                for(w in walls) {
                    var r = segmentToSegmentIntersection(prevPos, camPos, w[0], w[1]);

                    if(untyped r && r[0] < 1) {
                        camPos = prevPos;
                    }
                }
            }
            // rendering
            {
                col('#666');
                drawRect(0, 0, screenSize, halfSize);
                col('#999');
                drawRect(0, halfSize, screenSize, halfSize);
                drawWalls();
                /* col('#841'); */
                /* drawRect(halfSize - 12, screenSize * 0.96, 24, screenSize); */
                /* col('#222'); */
                /* drawRect(halfSize - 8, screenSize * 0.95, 16, screenSize); */

                if(camPos.x < -1100) {
                    Shim.context.fillText("WIN !", 32, 32);
                }
            }
            /* untyped requestAnimationFrame(loop); */
            untyped setTimeout(loop, 10);
        }
        {
            /* addWall(0, 0, 9, 0, 9); */
            /* addWall(0, 0, 0, 9, 9); */
            /* addWall(0, 9, 9, 9, 9); */
            /* addWall(9, 0, 9, 9, 9); */
            // T
            addWall(0, 0, 9, 4, 9);
            addWall(9, 4, 6, 4, 3);
            addWall(6, 9, 6, 4, 5);
            addWall(6, 9, 4, 9, 2);
            addWall(4, 4, 4, 9, 5);
            addWall(4, 4, -12, 4, 16);
            addWall(-12, 3, -12, 4, 1);
            addWall(-12, 3, 0, 3, 12);
            addWall(0, 0, 0, 3, 3);
            /* // Pillar */
            /* addWall(1, 1, 8, 1, 7); */
            /* addWall(8, 2, 8, 1, 1); */
            /* addWall(8, 2, 1, 2, 7); */
            /* addWall(1, 1, 1, 2, 1); */
        }
        loop(0);
    }
}
