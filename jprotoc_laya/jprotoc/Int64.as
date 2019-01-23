package jprotoc 
{
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Int64 
	{
		public var low:uint = 0;
		public var high:int = 0;
		public static const pow232:Number = Math.pow(2,32);
		public function Int64(low:uint=0,high:int=0) 
		{
			this.low = low>>>0;
			this.high = high>>0;
		}
		
		public function equal(v:Int64):Boolean {
			if (v == null) return false;
			return (v.low == low) && (v.high == high);
		}
		
		public function isZero():Boolean {
			return low == 0 && high == 0;
		}
		
		public function toString():String {
			return "high:0x" + high.toString(16)+" low:0x" + low.toString(16);
		}
		public static function numbertoInt64(value:Number):Int64{
			return new Int64(value % pow232,value /pow232);
		}
		public function toString():String {
			return toNumber().toString(36);
		}
	}

}
