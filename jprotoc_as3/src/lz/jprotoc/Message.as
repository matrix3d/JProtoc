package lz.jprotoc 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Message 
	{
		public var messageEncode:Object;
		public function readFrom(bytes:IDataInput,len:int=-1):void {
			var affterLen:int = 0;
			if (len > 0) affterLen = bytes.bytesAvailable-len;
			while (bytes.bytesAvailable>affterLen) {
				var tag:uint = readVarint(bytes);
				var number:int = tag >> 3;
				var type:int = tag & 7;
				var body:Array = messageEncode[number];
				var name:String = body[0];
				var label:int = body[1];
				var typeObj:Object = body[2];
				var value:Object;
				switch(type) {
					case 0://Varint	int32, int64, uint32, uint64, sint32, sint64, bool, enum
						value = readVarint(bytes);
						break;
					case 1://64-bit	fixed64, sfixed64, double
						value = bytes.readDouble();
						break;
					case 2://Length-delimi	string, bytes, embedded messages, packed repeated fields
						var len:int = readVarint(bytes);
						var lendelimi:ByteArray = new ByteArray;
						lendelimi.endian = Endian.LITTLE_ENDIAN;
						bytes.readBytes(lendelimi, 0, len);
						break;
					case 3://Start group	Groups (deprecated)
						break;
					case 4://End group	Groups (deprecated)
						break;
					case 5://32-bit	fixed32, sfixed32, float
						value = bytes.readFloat();
						break;
					default:
						trace("read error");
				}
				this[name] = value;
			}
		}
		
		public function writeTo(bytes:IDataOutput):IDataOutput {
			if (messageEncode==null) {
				throw "not implemented"
			}
			bytes ||= new ByteArray;
			bytes.endian = Endian.LITTLE_ENDIAN;
			for (var numberStr:String in messageEncode) {
				var number:int = int(numberStr);
				var body:Array = messageEncode[number];
				var name:String = body[0];
				var label:int = body[1];
				var typeObj:Object = body[2];
				if (typeObj is Message) {
					var type:int = TYPE_MESSAGE;
				}else {
					type = typeObj as int;
				}
				switch (type) {
					case TYPE_DOUBLE:
					case TYPE_FLOAT:
					case TYPE_INT32:
					case TYPE_SFIXED32:
					case TYPE_SINT32:
					case TYPE_ENUM:
					case TYPE_UINT32:
					case TYPE_FIXED32:
					case TYPE_BOOL:
					case TYPE_INT64:
					case TYPE_SFIXED64:
					case TYPE_SINT64:
					case TYPE_UINT64:
					case TYPE_FIXED64:
					case TYPE_STRING:
					case TYPE_MESSAGE:
					case TYPE_BYTES:
				}
			}
			return bytes;
		}
		
		public function readVarint(input:IDataInput):uint {
			var r:uint = 0,i:uint=0,v:uint=0;
			do {
				v = input.readUnsignedByte();
				r |= (v&0x7f) << i;
				i += 7;
			}while (v & 0x80)
			return r;
		}
		
		public function writeVarint(output:IDataOutput,value:int):void {
			for (;;) {
				if (value < 0x80) {
					output.writeByte(value);
					return;
				} else {
					output.writeByte((value & 0x7F) | 0x80)
					value >>>= 7;
				}
			}
		}
		
		private static const TYPE_DOUBLE:int=1;
		private static const TYPE_FLOAT:int=2;
		private static const TYPE_INT64:int=3;
		private static const TYPE_UINT64:int=4;
		private static const TYPE_INT32:int=5;
		private static const TYPE_FIXED64:int=6;
		private static const TYPE_FIXED32:int=7;
		private static const TYPE_BOOL:int=8;
		private static const TYPE_STRING:int=9;
		private static const TYPE_GROUP:int=10;
		private static const TYPE_MESSAGE:int=11;
		private static const TYPE_BYTES:int=12;
		private static const TYPE_UINT32:int=13;
		private static const TYPE_ENUM:int=14;
		private static const TYPE_SFIXED32:int=15;
		private static const TYPE_SFIXED64:int=16;
		private static const TYPE_SINT32:int=17;
		private static const TYPE_SINT64:int=18;
	}

}