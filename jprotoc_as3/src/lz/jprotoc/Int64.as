package lz.jprotoc 
{
	import flash.utils.IDataInput;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Int64 
	{
		public var low:uint = 0;
		public var high:uint = 0;
		public function Int64(low:uint=0,high:uint=0) 
		{
			this.low = low;
			this.high = high;
		}
		
		public function equal(v:Int64):Boolean {
			return (v.low == low) && (v.high == high);
		}
		
	}

}