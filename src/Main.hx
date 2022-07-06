@:native("")
extern class Shim {
    @:native("a") static var canvas:js.html.CanvasElement;
    @:native("c") static var context:js.html.CanvasRenderingContext2D;
}

class Main {
    static inline var screenSize = 512;
    static function main() {
        Shim.canvas.width = Shim.canvas.height = screenSize;
        var randomSeed = 0;
        var time:Int = 0;
        var w = 256;
        var mx:Int;
        var walls = [];
        var halfSize:Int = cast screenSize/ 2;
        walls[0] = [0, 0, 32, 32];
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
            mx = Std.int(e.clientX / 2);

            if(e.buttons) {
                stick = false;
            }
        }
        function drawCircle(x, y, r) {
            Shim.context.beginPath();
            Shim.context.arc(x, y, r, 0, 7);
            Shim.context.fill();
        }
        inline function drawWalls() {
            for(x in 0...screenSize) {
                var r = random() * 32 + 32;
                drawRect(x, halfSize - r/2, 1, r);
            }
        }
        function loop(t:Float) {
            {
                col('#000');
                Shim.context.fillRect(0, 0, screenSize, screenSize);
                col('#a44');
                drawCircle(128, 128, 64);
                col('#11f');
                drawWalls();
            }
            // untyped setTimeout(loop, 10);
            untyped requestAnimationFrame(loop);
        }
        loop(0);
    }
}
