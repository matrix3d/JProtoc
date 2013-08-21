package lz.jprotoc;
import com.google.protobuf.DescriptorProtos.DescriptorProto;
import com.google.protobuf.DescriptorProtos.FieldDescriptorProto;
import com.google.protobuf.DescriptorProtos.FileDescriptorProto;
import com.google.protobuf.compiler.PluginProtos.CodeGeneratorRequest;
import com.google.protobuf.compiler.PluginProtos.CodeGeneratorResponse;
/**
 * Created with IntelliJ IDEA.
 * User: lizhi
 * Date: 13-8-21
 * Time: 下午12:00
 * To change this template use File | Settings | File Templates.
 */
public class JProtoc {
	public void parser(){
		try {
			CodeGeneratorRequest request = CodeGeneratorRequest.parseFrom(System.in);
			CodeGeneratorResponse.Builder builder=CodeGeneratorResponse.newBuilder();
			for(FileDescriptorProto file: request.getProtoFileList()){
				String pack=file.getPackage();
				String packPath=pack.replaceAll("[.]","/")+"/";
				for(DescriptorProto messageType:file.getMessageTypeList()){
					String code="package "+pack+"{\r\n";
					code+="import lz.jprotoc.Message;\r\n";
					code+="public class "+messageType.getName()+" extends Message{\r\n\r\n";
					String messageEncode="{";
					for(FieldDescriptorProto field:messageType.getFieldList()){
						code+="public var "+field.getName()+":"+getType(field,pack)+";\r\n";
						messageEncode+=field.getNumber()+":[\""+field.getName()+"\","+field.getLabel().getNumber()+","+(field.hasTypeName()?getTypeName(field,pack):field.getType().getNumber())+"],";
					}
					if(messageEncode.endsWith(",")){
						messageEncode=messageEncode.substring(0,messageEncode.length()-1);
					}
					messageEncode+="}";
					code+="\r\npublic function "+messageType.getName()+"(){messageEncode="+messageEncode+"}\r\n";
					code+="}}";
					builder.addFile(CodeGeneratorResponse.File.newBuilder()
							.setName(packPath+messageType.getName()+".as")
							.setContent(code)
					);
				}
			}
			CodeGeneratorResponse response=builder.build();
			response.writeTo(System.out);
			System.out.flush();
		}
		catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	public String getType(FieldDescriptorProto field,String pack){
		if(field.getLabel()== FieldDescriptorProto.Label.LABEL_REPEATED){
			return "Array=[]";
		}
		FieldDescriptorProto.Type type=field.getType();
		switch (type) {
			case TYPE_DOUBLE:
			case TYPE_FLOAT:
				return "Number";
			case TYPE_INT32:
			case TYPE_SFIXED32:
			case TYPE_SINT32:
			case TYPE_ENUM:
				return "int";
			case TYPE_UINT32:
			case TYPE_FIXED32:
				return "uint";
			case TYPE_BOOL:
				return "Boolean";
			case TYPE_INT64:
			case TYPE_SFIXED64:
			case TYPE_SINT64:
				return "Int64";
			case TYPE_UINT64:
			case TYPE_FIXED64:
				return "UInt64";
			case TYPE_STRING:
				return "String";
			case TYPE_MESSAGE:
				return getTypeName(field,pack);
			case TYPE_BYTES:
				return "flash.utils.ByteArray";
		}
		return "*";
	}
	public String getTypeName(FieldDescriptorProto field,String pack){
		String ret=field.getTypeName().replaceFirst(".","");
		int li=ret.lastIndexOf(".");
		if(li>=0&&ret.substring(0,li).equals(pack)){
			return ret.substring(li+1,ret.length());
		}
		return ret;
	}
}
