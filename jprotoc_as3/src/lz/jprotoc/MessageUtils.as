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
	public class MessageUtils 
	{
		public static function readFrom(msg:Message, bytes:IDataInput, len:int = -1):void {
			var affterLen:int = 0;
			if (len > 0) affterLen = bytes.bytesAvailable-len;
			while (bytes.bytesAvailable>affterLen) {
				var tag:uint = readVarint(bytes);
				var number:int = tag >>> 3;
				var body:Array = msg.messageEncode[number];
				var name:String = body[0];
				var label:int = body[1];
				var typeObj:Object = body[2];
				if (typeObj is Class) {
					var type:int = TYPE_MESSAGE;
				}else {
					type = typeObj as int;
				}
				var value:Object = (MessageUtils["readtype" + type] || MessageUtils["readtype0"])(tag, bytes, typeObj);
				if(name){
					if (label == 3) {
						msg[name].push(value);
					}else {
						msg[name] = value;
					}
				}
			}
		}
		
		private static function readtype0(tag:int, bytes:IDataInput, typeObj:Object):Object {
			var wrieType:int = tag & 7;
			var value:Object;
			switch(wrieType) {
				case 0://Varint	int32, int64, uint32, uint64, sint32, sint64, bool, enum
					value = readVarint(bytes);
					break;
				case 2://Length-delimi	string, bytes, embedded messages, packed repeated fields
					var blen:int = readVarint(bytes);
					var temp:ByteArray = new ByteArray;
					temp.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(temp, 0, blen);
					value = temp;
					break;
				case 5://32-bit	fixed32, sfixed32, float
					value = bytes.readInt();
					break;
				case 1://64-bit	fixed64, sfixed64, double
					value = bytes.readDouble();
					break;
				//case 3://Start group	Groups (deprecated)
					//break;
				//case 4://End group	Groups (deprecated)
					//break;
				default:
					trace("read error");
			}
			return value;
		}
		private static function readtype1(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return bytes.readDouble();
		}
		private static function readtype2(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return bytes.readFloat();
		}
		private static function readtype3(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return readVarint64(bytes);
		}
		private static function readtype4(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return readVarint64(bytes);
		}
		private static function readtype5(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return readVarint(bytes);
		}
		private static function readtype6(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return bytes.readDouble();
		}
		private static function readtype7(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return bytes.readInt();
		}
		private static function readtype8(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return readVarint(bytes)>0;;
		}
		private static function readtype9(tag:int, bytes:IDataInput, typeObj:Object):Object {
			var blen:int = readVarint(bytes);
			var temp:ByteArray = new ByteArray;
			temp.endian = Endian.LITTLE_ENDIAN;
			bytes.readBytes(temp, 0, blen);
			return temp + "";
		}
		private static function readtype10(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return null;
		}
		private static function readtype11(tag:int, bytes:IDataInput, typeObj:Object):Object {
			var blen:int = readVarint(bytes);
			var msg:Message = new typeObj as Message;
			msg.readFrom(bytes, blen);
			return msg;
		}
		private static function readtype12(tag:int, bytes:IDataInput, typeObj:Object):Object {
			var blen:int = readVarint(bytes);
			var temp:ByteArray = new ByteArray;
			temp.endian = Endian.LITTLE_ENDIAN;
			bytes.readBytes(temp, 0, blen);
			return temp;
		}
		private static function readtype13(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return readVarint(bytes);
		}
		private static function readtype14(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return readVarint(bytes);
		}
		private static function readtype15(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return bytes.readUnsignedInt();
		}
		private static function readtype16(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return bytes.readDouble();
		}
		private static function readtype17(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return readVarint(bytes);
		}
		private static function readtype18(tag:int, bytes:IDataInput, typeObj:Object):Object {
			return readVarint64(bytes);
		}
		
		public static function writeTo(msg:Message,bytes:IDataOutput):IDataOutput {
			if (msg.messageEncode==null) {
				throw "not implemented"
			}
			bytes ||= new ByteArray;
			bytes.endian = Endian.LITTLE_ENDIAN;
			for (var numberStr:String in msg.messageEncode) {
				var number:int = int(numberStr);
				var body:Array = msg.messageEncode[number];
				var name:String = body[0];
				var value:Object = msg[name];
				if (value==null) {
					continue;
				}
				var label:int = body[1];
				var typeObj:Object = body[2];
				if (typeObj is Class) {
					var type:int = TYPE_MESSAGE;
				}else {
					type = typeObj as int;
				}
				
				var wrieType:int = type2WrieType(type);
				var tag:int = (number << 3) | wrieType;
				if (label==3) {
					for each(var element:Object in value) {
						writeElementTo(element, type, tag, bytes);
					}
				}else {
					writeElementTo(value, type, tag, bytes);
				}
			}
			return bytes;
		}
		
		public static function writeElementTo(value:Object,type:int,tag:int,bytes:IDataOutput):void {
			writeVarint(bytes, tag);
			switch (type) {
				case TYPE_FIXED32:
					bytes.writeInt(value as int);
					break;
				case TYPE_SFIXED32:
					bytes.writeUnsignedInt(value as uint);
					break;
				case TYPE_FLOAT:
					bytes.writeFloat(value as Number);
					break;
				case TYPE_DOUBLE:
				case TYPE_FIXED64:
				case TYPE_SFIXED64:
					bytes.writeDouble(value as Number);
					break;
				case TYPE_INT32:
				case TYPE_SINT32:
				case TYPE_ENUM:
				case TYPE_UINT32:
					writeVarint(bytes, value as int);
					break;
				case TYPE_INT64:
				case TYPE_SINT64:
				case TYPE_UINT64:
					writeVarint64(bytes, value as Int64);
					break;
				case TYPE_BOOL:
					writeVarint(bytes, value?1:0);
					break;
				case TYPE_STRING:
				case TYPE_BYTES:
				case TYPE_MESSAGE:
					if (type==TYPE_MESSAGE) {
						var temp:ByteArray = value.writeTo(null);
					}else if (type==TYPE_BYTES) {
						temp = value as ByteArray;
					}else {
						temp = new ByteArray;
						temp.endian = Endian.LITTLE_ENDIAN;
						temp.writeMultiByte(value as String, "utf-8");
					}
					writeVarint(bytes, temp.length);
					bytes.writeBytes(temp, 0, temp.length);
			}
		}
		
		public static function readVarint(input:IDataInput):uint {
			var r:uint = 0,i:uint=0,v:uint=0;
			do {
				v = input.readUnsignedByte();
				r |= (v&0x7f) << i;
				i += 7;
			}while (v & 0x80)
			return r;
		}
		public static function readVarint64(input:IDataInput):Int64 {
			var r:Int64 = new Int64,i:int=0,v:uint=0,v1:uint=0;
			do {
				v = input.readUnsignedByte();
				v1 = v & 0x7f;
				if (i<=24) {
					r.low |= v1 << i;
				}else if (i>32) {
					r.high |= v1 << (i - 32);
				}else {
					r.low |= v1 << i;
					r.high |= v1 >>> (32 - i);
				}
				i += 7;
			}while (v & 0x80)
			return r;
		}
		public static function writeVarint(output:IDataOutput,value:int):void {
			while(value > 0x80){
				output.writeByte((value & 0x7F) | 0x80)
				value >>>= 7;
			}
			output.writeByte(value);
		}
		public static function writeVarint64(output:IDataOutput,value:Int64):void {
			 if (value.high == 0) {
				writeVarint(output, value.low)
			} else {
				for (var i:uint = 0; i < 4; ++i) {
					output.writeByte((value.low & 0x7F) | 0x80)
					value.low >>>= 7
				}
				if ((value.high & (0xFFFFFFF << 3)) == 0) {
					output.writeByte((value.high << 4) | value.low)
				} else {
					output.writeByte((((value.high << 4) | value.low) & 0x7F) | 0x80)
					writeVarint(output, value.high >>> 3)
				}
			}
		}
		public static function type2WrieType(type:int):int {
			switch (type) {
				case TYPE_FIXED32:
				case TYPE_SFIXED32:
				case TYPE_FLOAT:
					return 5;
				case TYPE_DOUBLE:
				case TYPE_FIXED64:
				case TYPE_SFIXED64:
					return 1;
				case TYPE_INT32:
				case TYPE_SINT32:
				case TYPE_ENUM:
				case TYPE_UINT32:
				case TYPE_INT64:
				case TYPE_SINT64:
				case TYPE_UINT64:
				case TYPE_BOOL:
					return 0;
				case TYPE_STRING:
				case TYPE_MESSAGE:
				case TYPE_BYTES:
					return 2;
			}
			return -1;
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