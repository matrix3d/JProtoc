set path=%path%;"D:\Program Files\protoc-2.5.0-win32"
::protoc simple.proto --plugin=protoc-gen-as3=jprotocas3.bat --as3_out=.
protoc *.proto --plugin=protoc-gen-as3=jprotocas3.bat --as3_out=.
pause