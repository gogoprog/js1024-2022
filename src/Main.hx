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
        var keys:Dynamic = {};
        var startMx:Int;
        var startAngle:Float;
        var mx:Int;
        function random():Float {
            var x = (Math.sin(randomSeed++) + 1) * 99;
            return x - Std.int(x);
        }
        function col(n:Dynamic) {
            Shim.context.fillStyle = n;
        }
        function alpha(n) {
            Shim.context.globalAlpha = n;
        }
        function drawRect(x:Float, y:Float, w:Float, h:Float) {
            Shim.context.fillRect(x, y, w, h);
        }
        untyped onmousemove = onmousedown = function(e) {
            mx = e.clientX;

            if(e.buttons & 1) {
            }

            if(e.buttons & 2) {
                e.preventDefault();

                if(startMx == null) {
                    startMx = mx;
                    startAngle = camAngle;
                }
            } else {
                startMx = null;
            }
        }
        untyped onkeydown = onkeyup = function(e) {
            keys[e.key] = e.type == 'keydown';
        }
        Shim.canvas.oncontextmenu = e -> false;
        function drawCircle(x, y, r) {
            Shim.context.beginPath();
            Shim.context.arc(x, y, r, 0, 7);
            Shim.context.fill();
        }
        inline function segmentToSegmentIntersection(from1:Point, to1:Point, from2:Point, to2:Point) {
            var dX= to1.x - from1.x;
            var dY= to1.y - from1.y;
            var determinant = dX * (to2.y - from2.y) - (to2.x - from2.x) * dY;

            if(determinant == 0) { return null; }

            var lambda = ((to2.y - from2.y) * (to2.x - from1.x) + (from2.x - to2.x) * (to2.y - from1.y)) / determinant;
            var gamma = ((from1.y - to1.y) * (to2.x - from1.x) + dX * (to2.y - from1.y)) / determinant;

            if(!(0 <= lambda && lambda <= 1) || !(0 <= gamma && gamma <= 1)) { return null; }

            return lambda;
        }
        inline function addWall(a, b, c, d, col:String) {
            var n = walls.length;
            walls[n] = [a, b, c, d, col];
        }
        inline function drawWalls() {
            var farPlane = 500;
            var wallH = 26;
            var hfov = Math.PI * 0.25;
            var p = camPos;
            var d = halfSize / Math.tan(hfov);

            for(x in 0...screenSize) {
                var a2 = Math.atan2(x - halfSize, d);
                var a = camAngle + a2;
                var dx = Math.cos(a) * farPlane;
                var dy = Math.sin(a) * farPlane;
                var camTarget = {x:camPos.x+dx, y:camPos.y+dy};
                var best = null;
                var bestDistance = 100000.0;

                for(w in walls) {
                    var a = {x:w[0], y:w[1]};
                    var b = {x:w[2], y:w[3]};
                    var r = segmentToSegmentIntersection(camPos, camTarget, a, b);

                    if(r != null) {
                        var f = Math.cos(a2) * r;

                        if(f<bestDistance) {
                            bestDistance = f;
                            best = w;
                        }
                    }
                }

                if(best != null) {
                    var h = (screenSize / wallH) / bestDistance;
                    col(best[4]);
                    drawRect(x, halfSize - h/2, 1, h);
                }
            }
        }
        function loop(t:Float) {
            // controls
            {
                var a = camAngle;
                var dir = {x:Math.cos(a), y:Math.sin(a)};
                var lat = {x:Math.cos(a + Math.PI/2), y:Math.sin(a + Math.PI/2)};
                var move = {x:0, y:0};

                if(untyped keys['w']) {
                    move.y = 1;
                }

                if(untyped keys['s']) {
                    move.y = -1;
                }

                if(untyped keys['d']) {
                    move.x = 1;
                }

                if(untyped keys['a']) {
                    move.x = -1;
                }

                var s = 4;
                camPos.x += dir.x * move.y * s;
                camPos.y += dir.y * move.y * s;
                camPos.x += lat.x * move.x * s;
                camPos.y += lat.y * move.x * s;

                if(untyped startMx) {
                    var delta = mx - startMx;
                    camAngle = startAngle + delta * 0.01;
                }
            }
            // rendering
            {
                col('#000');
                drawRect(0, 0, screenSize, screenSize);
                col('#88f');
                drawRect(0, 0, screenSize, halfSize);
                col('#666');
                drawRect(0, halfSize, screenSize, halfSize);
                drawWalls();
            }
            untyped requestAnimationFrame(loop);
        }
        addWall(128, 64, 50, 100, 'red');
        addWall(300, 128, 50, 50, 'white');
        addWall(64, 300, 10, 500, 'blue');
        addWall(64, 300, 500, 10, 'green');
        addWall(200, 400, 500, 10, 'yellow');
        loop(0);
    }
}
