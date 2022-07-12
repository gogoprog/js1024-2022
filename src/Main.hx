@:native("")
extern class Shim {
    @:native("a") static var canvas:js.html.CanvasElement;
    @:native("c") static var context:js.html.CanvasRenderingContext2D;
}

typedef Point = {
    var x:Float;
    var y:Float;
}

class Main {
    static inline var screenSize = 512;
    static function main() {
        Shim.canvas.width = Shim.canvas.height = screenSize;
        var randomSeed = 0;
        var time:Int = 0;
        var walls:Array<Dynamic> = [];
        var halfSize:Int = cast screenSize/ 2;
        var camPos:Point = {x:400, y:300};
        var camAngle:Float = 0;
        /* var keys:Dynamic = {}; */
        var mx:Int = 0;
        var mmove:Int = 0;
        var textureCanvas:js.html.CanvasElement = untyped document.createElement("canvas");
        {
            textureCanvas.width = textureCanvas.height = 64;
            var textureContext = textureCanvas.getContext("2d");
            textureContext.fillRect(0, 0, 64, 64);
            textureContext.fillStyle = '#a22';
            textureContext.fillRect(2, 2, 62, 30);
            textureContext.fillRect(0, 34, 30, 29);
            textureContext.fillRect(32, 34, 32, 29);
            /* var pattern = textureContext.createPattern(textureCanvas, 'repeat'); */
            /* textureCanvas.width = textureCanvas.height = 256; */
            /* textureContext.fillStyle = pattern; */
            /* textureContext.fillRect(0, 0, 256, 256); */
        }
        function random():Float {
            var x = (Math.sin(randomSeed++) + 1) * 99;
            return x - Std.int(x);
        }
        inline function col(n : Dynamic) {
            Shim.context.fillStyle = n;
        }
        function alpha(n) {
            Shim.context.globalAlpha = n;
        }
        inline function drawRect(x:Float, y:Float, w:Float, h:Float) {
            Shim.context.fillRect(x, y, w, h);
        }
        untyped onmousemove = onmousedown = onmouseup = function(e) {
            mx = e.clientX;
            mmove = (e.buttons & 2);
        }
        /* untyped onmousemove = function(e) { */
        /*     mx = e.clientX; */
        /* } */
        /* untyped onkeydown = onkeyup = function(e) { */
        /*     keys[e.key] = e.type[3] == 'd'; */
        /* } */
        Shim.canvas.oncontextmenu = e->false;
        function drawCircle(x, y, r) {
            Shim.context.beginPath();
            Shim.context.arc(x, y, r, 0, 7);
            Shim.context.fill();
        }
        inline function segmentToSegmentIntersection(from1:Point, to1:Point, from2:Point, to2:Point) {
            var dX = to1.x - from1.x;
            var dY = to1.y - from1.y;
            var determinant = dX * (to2.y - from2.y) - (to2.x - from2.x) * dY;
            /* if(determinant == 0) { return null; } */
            var lambda = ((to2.y - from2.y) * (to2.x - from1.x) + (from2.x - to2.x) * (to2.y - from1.y)) / determinant;
            var gamma = ((from1.y - to1.y) * (to2.x - from1.x) + dX * (to2.y - from1.y)) / determinant;

            if(lambda<0 || !(0 <= gamma && gamma <= 1)) { return null; }

            return [lambda, gamma];
        }
        inline function addWall(a, b, c, d) {
            var n = walls.length;
            var len = Math.sqrt((c-a)*(c-a)+(d-b)*(d-b));
            walls[n] = [a, b, c, d, len];
        }
        inline function drawWalls() {
            var farPlane = 1000;
            var wallH = 26;
            /* var hfov = Math.PI * 0.25; */
            /* var d = halfSize / Math.tan(hfov); */
            var d = 256;

            for(x in 0...screenSize) {
                var a2 = Math.atan2(x - halfSize, d);
                var a = camAngle + a2;
                var dx = Math.cos(a) * farPlane;
                var dy = Math.sin(a) * farPlane;
                var camTarget = {x:camPos.x+dx, y:camPos.y+dy};
                var best = null;
                var bestDistance = 100000.0;
                var bestGamma:Float = 0;

                for(w in walls) {
                    var a = {x:w[0], y:w[1]};
                    var b = {x:w[2], y:w[3]};
                    var r = segmentToSegmentIntersection(camPos, camTarget, a, b);

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
                    var tx = Std.int(bestGamma * best[4]) % 64;
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
                var dir = {x:Math.cos(a), y:Math.sin(a)};
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
                camPos.x += dir.x * mmove * s;
                camPos.y += dir.y * mmove * s;
                camAngle = mx * 0.04;
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
            }
            untyped requestAnimationFrame(loop);
            /* untyped setTimeout(loop, 16); */
        }
        {
            var points = [
                             [ 0, 0 ],
                             [ 9, 0 ],
                             [ 9, 9 ],
                             [ 8, 9 ],
                             [ 8, 4 ],
                             [ 3, 4 ],
                             [ 3, 6 ],
                             [ 7, 6 ],
                             [ 7, 7 ],
                             [ 2, 7 ],
                             [ 2, 9 ],
                             [ 0, 9 ],
                         ];
            var len = points.length;
            var f = 100;

            for(p in 0...len) {
                var a = points[p];
                var b = points[(p + 1) % len];
                addWall(a[0] * f, a[1] * f, b[0] * f, b[1] * f);
            }
        }
        loop(0);
    }
}
